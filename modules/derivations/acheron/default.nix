{
  lib,
  fetchFromGitHub,
  stdenv,
  cacert,
  cmake,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  alsa-lib,
  curl-impersonate,
  libopus,
  libpulseaudio,
  mlspp,
  nlohmann_json,
  libsodium,
  pcre2,
  qt6Packages,
  spdlog,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "acheron";
  version = "unstable-2026-04-09";

  src = fetchFromGitHub {
    owner = "ouwou";
    repo = "acheron";
    rev = "21f6f11544b1a2067d88d8cad0b6f45247fc7cdb";
    hash = "sha256-bGrdyuXPuiN3R6Y5UjP13ryTCexaWVKtlF3lGH5NMiU="; 
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    cacert
    curl-impersonate
    libopus
    libsodium
    mlspp
    nlohmann_json
    pcre2
    qt6Packages.qtbase
    qt6Packages.qtimageformats
    qt6Packages.qtkeychain
    qt6Packages.qttools
    spdlog
  ];
  
  cmakeFlags = [
    "-DCMAKE_TOOLCHAIN_FILE="
    "-DCURL_LIBRARY=${curl-impersonate}/lib/libcurl-impersonate.so"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "if(ENABLE_VOICE)" \
        "if(ENABLE_VOICE)
         find_package(PkgConfig REQUIRED)" \
      --replace-fail "find_package(unofficial-sodium CONFIG REQUIRED)" \
        "pkg_check_modules(sodium REQUIRED IMPORTED_TARGET libsodium)" \
      --replace-fail "find_package(Opus CONFIG REQUIRED)" \
        "pkg_check_modules(opus REQUIRED IMPORTED_TARGET opus)" \
      --replace-fail "unofficial-sodium::sodium" "PkgConfig::sodium" \
      --replace-fail "Opus::opus" "PkgConfig::opus"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp acheron $out/bin/acheron

    # acheron looks for certs here, so we need to provide them
    mkdir -p $out/bin/certs
    ln -s ${cacert}/etc/ssl/certs/ca-bundle.crt $out/bin/certs/cacert.pem

    wrapProgram $out/bin/acheron \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ alsa-lib libpulseaudio ]}" \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set OPENSSL_CONF ""

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      exec = finalAttrs.pname;
      desktopName = "Acheron";
      genericName = finalAttrs.meta.description;
      startupWMClass = finalAttrs.pname;
      categories = [
        "Network"
        "InstantMessaging"
      ];
      mimeTypes = [ "x-scheme-handler/discord" ];
    })
  ];

  meta = {
    description = "An alternative Discord client with voice support made with C++ and Qt 6 Widgets ";
    mainProgram = "acheron";
    homepage = "https://github.com/ouwou/acheron";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ chocoblocko9 ];
    platforms = lib.platforms.linux;
  };
})
