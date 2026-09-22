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

releases=(darwin linux)
declare -A release_labels=(
  [darwin]=macOS
  [linux]=Linux
)
declare -A release_repositories=(
  [darwin]=imputnet/helium-macos
  [linux]=imputnet/helium-linux
)
declare -A current_versions=()
declare -A latest_versions=()

for release in "${releases[@]}"; do
  version_count="$(grep -Ec "^    $release = \"[^\"]+\";$" "$package_file" || true)"
  [[ "$version_count" == 1 ]] ||
    die "expected exactly one $release version assignment in $package_file"

  current_versions["$release"]="$(
    sed -n "s/^    $release = \"\([^\"]*\)\";$/\1/p" "$package_file"
  )"
  [[ "${current_versions[$release]}" =~ ^[0-9]+([.][0-9]+){3}$ ]] ||
    die "invalid current ${release_labels[$release]} version ${current_versions[$release]}"

  latest_versions["$release"]="$(latest_version "${release_repositories[$release]}")" ||
    die "could not determine the latest ${release_labels[$release]} version"
done

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

changed_releases=()
for release in "${releases[@]}"; do
  if [[ "${latest_versions[$release]}" != "${current_versions[$release]}" ]]; then
    changed_releases+=("$release")
  fi
done

if (( ${#changed_releases[@]} == 0 )); then
  println "$GREEN" "helium: current"
  exit 0
fi

declare -A system_releases=(
  [aarch64-darwin]=darwin
  [aarch64-linux]=linux
  [x86_64-linux]=linux
)
declare -A urls=(
  [aarch64-darwin]="https://github.com/imputnet/helium-macos/releases/download/${latest_versions[darwin]}/helium_${latest_versions[darwin]}_arm64-macos.dmg"
  [aarch64-linux]="https://github.com/imputnet/helium-linux/releases/download/${latest_versions[linux]}/helium-bin_${latest_versions[linux]}-1_arm64.deb"
  [x86_64-linux]="https://github.com/imputnet/helium-linux/releases/download/${latest_versions[linux]}/helium-bin_${latest_versions[linux]}-1_amd64.deb"
)

declare -A hashes=()
for system in "${systems[@]}"; do
  release="${system_releases[$system]}"
  [[ "${latest_versions[$release]}" != "${current_versions[$release]}" ]] || continue

  println "" "helium: prefetching ${latest_versions[$release]} for $system..."
  hashes["$system"]="$(
    nix store prefetch-file --json "${urls[$system]}" |
      jq -er '.hash | select(type == "string" and startswith("sha256-"))'
  )" || die "could not prefetch $system"
done

tmp_file="$(mktemp "${package_file%.nix}.XXXXXX.nix")"
trap 'rm -f -- "$tmp_file"' EXIT
cp --preserve=mode "$package_file" "$tmp_file"

for release in "${changed_releases[@]}"; do
  sed -i \
    "s|^    $release = \".*\";$|    $release = \"${latest_versions[$release]}\";|" \
    "$tmp_file"
done
for system in "${systems[@]}"; do
  release="${system_releases[$system]}"
  [[ "${latest_versions[$release]}" != "${current_versions[$release]}" ]] || continue

  sed -i \
    "/^    $system = {$/,/^    };$/ s|^      hash = \".*\";$|      hash = \"${hashes[$system]}\";|" \
    "$tmp_file"
done

nixfmt "$tmp_file"

mv "$tmp_file" "$package_file"
trap - EXIT
for release in "${changed_releases[@]}"; do
  println "$GREEN" "helium: updated ${release_labels[$release]} to ${latest_versions[$release]}"
done
