{
  adwaita-icon-theme,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  bintools,
  bzip2,
  cairo,
  coreutils,
  curl,
  cups,
  dbus,
  expat,
  fetchurl,
  flac,
  fontconfig,
  freetype,
  gcc-unwrapped,
  gdk-pixbuf,
  gitMinimal,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  gnugrep,
  gnused,
  harfbuzz,
  icu,
  jq,
  lib,
  libcap,
  libdrm,
  libexif,
  libglvnd,
  libkrb5,
  libopus,
  libpng,
  libpulseaudio,
  libva,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  libgbm,
  makeWrapper,
  nix,
  nixfmt,
  nspr,
  nss,
  pango,
  patchelf,
  pciutils,
  pipewire,
  snappy,
  speechd-minimal,
  stdenvNoCC,
  systemd,
  util-linux,
  vulkan-loader,
  wayland,
  wget,
  writeShellApplication,
  xdg-utils,
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
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-bin_${version}-1_arm64.deb";
      hash = "sha256-GzuX/NBiRRCwKcOQBGYdnKb89CdH3/9rVU0pfKugb+g=";
    };
    x86_64-linux = {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-bin_${version}-1_amd64.deb";
      hash = "sha256-xb4AhHoTY/AE+B07jnDKJmsVrgKgKdLLHhG2TThTaSk=";
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

  linuxDependencies = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bzip2
    cairo
    coreutils
    cups
    curl
    dbus
    expat
    flac
    fontconfig
    freetype
    gcc-unwrapped.lib
    gdk-pixbuf
    glib
    harfbuzz
    icu
    libcap
    libdrm
    libexif
    libglvnd
    libkrb5
    libpng
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    libgbm
    nspr
    nss
    (libopus.override { withCustomModes = true; })
    pango
    pciutils
    pipewire
    snappy
    speechd-minimal
    systemd
    util-linux
    vulkan-loader
    wayland
    wget
    libpulseaudio
    libva
    gtk3
    gtk4
  ];

  linux = stdenvNoCC.mkDerivation {
    inherit
      meta
      passthru
      pname
      src
      version
      ;

    nativeBuildInputs = [
      makeWrapper
      patchelf
    ];
    buildInputs = [
      adwaita-icon-theme
      glib
      gsettings-desktop-schemas
      gtk3
      gtk4
    ];

    unpackPhase = ''
      runHook preUnpack

      ${lib.getExe' bintools "ar"} x $src
      tar xf data.tar.xz

      runHook postUnpack
    '';

    installPhase =
      let
        binPath = lib.makeBinPath linuxDependencies;
        libraryPath =
          lib.makeLibraryPath linuxDependencies
          + ":"
          + lib.makeSearchPathOutput "lib" "lib64" linuxDependencies;
      in
      ''
        runHook preInstall

        mkdir -p $out/bin $out/opt $out/share
        cp -R opt/helium $out/opt/
        cp -R usr/share/applications usr/share/metainfo $out/share/
        install -Dm444 $out/opt/helium/product_logo_256.png \
          $out/share/icons/hicolor/256x256/apps/helium.png

        for executable in helium helium_crashpad_handler chromedriver; do
          patchelf \
            --set-interpreter ${bintools.dynamicLinker} \
            --set-rpath ${libraryPath} \
            $out/opt/helium/$executable
        done

        makeWrapper $out/opt/helium/helium $out/bin/helium \
          --set CHROME_VERSION_EXTRA nix \
          --set CHROME_WRAPPER $out/bin/helium \
          --prefix LD_LIBRARY_PATH : "$out/opt/helium:${libraryPath}" \
          --prefix PATH : ${binPath} \
          --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
          --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH" \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

        runHook postInstall
      '';

    dontBuild = true;

    installCheckPhase = ''
      $out/bin/helium --version
    '';
    doInstallCheck = true;
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
