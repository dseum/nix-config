{
  appimageTools,
  coreutils,
  curl,
  fetchurl,
  gitMinimal,
  gnugrep,
  gnused,
  jq,
  lib,
  makeWrapper,
  nix,
  nixfmt,
  stdenvNoCC,
  writeShellApplication,
  _7zz,
}:
let
  pname = "helium";
  version = "0.17.2.1";

  sources = {
    aarch64-darwin = {
      url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
      hash = "sha256-8aP+zePAglTxse7DDjbs0l+YzzeZZEQn+879bmvq+s8=";
    };
    aarch64-linux = {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-arm64.AppImage";
      hash = "sha256-Fno/dpgXm5zS5SGMOq0W7JwT1BWbGjHcHUsnkXhfMCg=";
    };
    x86_64-linux = {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
      hash = "sha256-DFyqK6nrjZhsc1OoduquJETeByVneWg6B18ybIYWk7Q=";
    };
  };

  src = fetchurl (
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "helium: unsupported system ${stdenvNoCC.hostPlatform.system}")
  );

  meta = {
    description = "Private, fast, and user-friendly web browser";
    homepage = "https://helium.computer";
    license = with lib.licenses; [
      bsd3
      gpl3Only
    ];
    mainProgram = "helium";
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-helium";
    runtimeInputs = [
      coreutils
      curl
      gitMinimal
      gnugrep
      gnused
      jq
      nix
      nixfmt
    ];
    text = builtins.readFile ./update.sh;
  });

  linux = appimageTools.wrapType2 {
    inherit
      meta
      passthru
      pname
      src
      version
      ;

    extraInstallCommands =
      let
        appimageContents = appimageTools.extract {
          inherit pname src version;
        };
      in
      ''
        install -Dm444 ${appimageContents}/helium.desktop \
          $out/share/applications/helium.desktop
        install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/helium.png \
          $out/share/icons/hicolor/256x256/apps/helium.png
      '';
  };

  darwin = stdenvNoCC.mkDerivation {
    inherit
      meta
      passthru
      pname
      src
      version
      ;

    nativeBuildInputs = [
      makeWrapper
      _7zz
    ];
    sourceRoot = ".";

    unpackPhase = ''
      runHook preUnpack

      7zz x -snld $src

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications $out/bin
      cp -R Helium/Helium.app $out/Applications/
      makeWrapper \
        $out/Applications/Helium.app/Contents/MacOS/Helium \
        $out/bin/helium

      runHook postInstall
    '';

    dontBuild = true;
    dontFixup = true;
  };
in
if stdenvNoCC.hostPlatform.isLinux then
  linux
else if stdenvNoCC.hostPlatform.isDarwin then
  darwin
else
  throw "helium: unsupported operating system ${stdenvNoCC.hostPlatform.system}"
