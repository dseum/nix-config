# shellcheck shell=bash

GREEN="$(printf '\033[1;32m')"
RED="$(printf '\033[1;31m')"

println() {
  printf '\033[1mnix-config: %s%s\n\033[0m' "$1" "$2"
}

die() {
  println "$RED" "helium: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)" || die "run this command from the nix-config repository"
package_file="$repo_root/packages/helium/default.nix"
[[ -f "$package_file" ]] || die "missing $package_file"

curl_args=(
  --fail
  --silent
  --show-error
  --location
  --header "Accept: application/vnd.github+json"
  --header "X-GitHub-Api-Version: 2022-11-28"
)

github_token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
unset GITHUB_TOKEN GH_TOKEN

github_api() {
  if [[ -n "$github_token" ]]; then
    [[ "$github_token" != *$'\n'* && "$github_token" != *$'\r'* ]] || die "invalid GitHub token"
    printf 'Authorization: Bearer %s\n' "$github_token" |
      curl "${curl_args[@]}" --header @- "$1"
  else
    curl "${curl_args[@]}" "$1"
  fi
}

latest_version() {
  github_api "https://api.github.com/repos/$1/releases/latest" |
    jq -er '.tag_name | select(type == "string" and test("^[0-9]+([.][0-9]+){3}$"))'
}

version_count="$(grep -Ec '^  version = "[^"]+";$' "$package_file" || true)"
[[ "$version_count" == 1 ]] || die "expected exactly one version assignment in $package_file"
current_version="$(sed -n 's/^  version = "\([^"]*\)";$/\1/p' "$package_file")"
[[ "$current_version" =~ ^[0-9]+([.][0-9]+){3}$ ]] ||
  die "invalid current version $current_version"

systems=(
  aarch64-darwin
  aarch64-linux
  x86_64-linux
)

for system in "${systems[@]}"; do
  hash_count="$(
    sed -n "/^    $system = {$/,/^    };$/p" "$package_file" |
      grep -Ec '^      hash = "sha256-[A-Za-z0-9+/]+={0,2}";$' || true
  )"
  [[ "$hash_count" == 1 ]] || die "expected exactly one hash for $system in $package_file"
done

linux_version="$(latest_version imputnet/helium-linux)" || die "could not determine the latest Linux version"
darwin_version="$(latest_version imputnet/helium-macos)" || die "could not determine the latest macOS version"
[[ "$linux_version" == "$darwin_version" ]] ||
  die "release mismatch: Linux is $linux_version, macOS is $darwin_version"
version="$linux_version"

if [[ "$version" == "$current_version" ]]; then
  println "$GREEN" "helium is current"
  exit 0
fi

declare -A urls=(
  [aarch64-darwin]="https://github.com/imputnet/helium-macos/releases/download/$version/helium_${version}_arm64-macos.dmg"
  [aarch64-linux]="https://github.com/imputnet/helium-linux/releases/download/$version/helium-${version}-arm64.AppImage"
  [x86_64-linux]="https://github.com/imputnet/helium-linux/releases/download/$version/helium-${version}-x86_64.AppImage"
)

declare -A hashes=()
for system in "${systems[@]}"; do
  println "" "prefetching helium $version for $system..."
  hashes["$system"]="$(
    nix store prefetch-file --json "${urls[$system]}" |
      jq -er '.hash | select(type == "string" and startswith("sha256-"))'
  )" || die "could not prefetch $system"
done

tmp_file="$(mktemp "${package_file%.nix}.XXXXXX.nix")"
trap 'rm -f -- "$tmp_file"' EXIT
cp --preserve=mode "$package_file" "$tmp_file"

sed -i "s|^  version = \".*\";$|  version = \"$version\";|" "$tmp_file"
for system in "${systems[@]}"; do
  sed -i \
    "/^    $system = {$/,/^    };$/ s|^      hash = \".*\";$|      hash = \"${hashes[$system]}\";|" \
    "$tmp_file"
done

nixfmt "$tmp_file"

mv "$tmp_file" "$package_file"
trap - EXIT
println "$GREEN" "updated helium to $version"
