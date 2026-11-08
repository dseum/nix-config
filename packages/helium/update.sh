# shellcheck shell=bash

GREEN=
RED=
if [[ -z ${NO_COLOR:-} && -t 1 ]]; then
  GREEN=$(printf '\033[1;32m')
fi
if [[ -z ${NO_COLOR:-} && -t 2 ]]; then
  RED=$(printf '\033[1;31m')
fi

println() {
  if [[ -n $1 ]]; then
    printf 'nix-config: %s%s\033[0m\n' "$1" "$2"
  else
    printf 'nix-config: %s\n' "$2"
  fi
}

die() {
  println "$RED" "helium: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)" || die "run this command from the nix-config repository"
sources_file="$repo_root/packages/helium/sources.json"
sources="$(jq . "$sources_file")"

curl_args=(
  --fail
  --silent
  --show-error
  --location
  --connect-timeout 15
  --max-time 120
  --retry 3
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

declare -A repositories=(
  [darwin]=imputnet/helium-macos
  [linux]=imputnet/helium-linux
)
declare -A asset_suffixes=(
  [aarch64-darwin]=_arm64-macos.dmg
  [aarch64-linux]=_arm64.deb
  [x86_64-linux]=_amd64.deb
)
changes=()

for platform in darwin linux; do
  release="$(github_api "https://api.github.com/repos/${repositories[$platform]}/releases/latest")" ||
    die "could not fetch the latest $platform release"
  version="$(jq -er '.tag_name' <<< "$release")" || die "missing $platform release version"

  while IFS= read -r system; do
    current_version="$(jq -er --arg system "$system" '.[$system].version' <<< "$sources")"
    [[ "$version" != "$current_version" ]] || continue

    asset="$(
      jq -ce --arg suffix "${asset_suffixes[$system]}" '
        .assets[] | select(.name | endswith($suffix))
      ' <<< "$release"
    )" || die "could not find the release asset for $system"
    url="$(jq -er '.browser_download_url' <<< "$asset")"
    digest="$(jq -r '.digest // empty' <<< "$asset")"

    if [[ -n "$digest" ]]; then
      hash="$(nix hash convert --to sri "$digest")" || die "invalid release digest for $system"
    else
      println "" "helium: no release digest; prefetching $version for $system..."
      hash="$(nix store prefetch-file --json "$url" | jq -er '.hash')" ||
        die "could not prefetch $system; leaving $sources_file unchanged"
    fi

    sources="$(
      jq --arg system "$system" --arg version "$version" --arg url "$url" --arg hash "$hash" '
        .[$system] = {version: $version, url: $url, hash: $hash}
      ' <<< "$sources"
    )"
    changes+=("$system: $current_version → $version")
  done < <(jq -r --arg platform "$platform" 'keys[] | select(endswith("-" + $platform))' <<< "$sources")
done

if (( ${#changes[@]} == 0 )); then
  println "$GREEN" "helium: up to date"
  exit 0
fi

tmp_file="$(mktemp "$sources_file.XXXXXX")"
trap 'rm -f -- "$tmp_file"' EXIT
printf '%s\n' "$sources" > "$tmp_file"
chmod --reference="$sources_file" "$tmp_file"
mv "$tmp_file" "$sources_file"
trap - EXIT

for change in "${changes[@]}"; do
  println "$GREEN" "helium: updated $change"
done
