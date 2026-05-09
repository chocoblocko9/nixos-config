{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  alsa-lib,
  curl-impersonate,
  libdave,
  libopus,
  libpulseaudio,
  libsodium,
  nlohmann_json,
  pcre2,
  qt6Packages,
  spdlog,
}:

let
  miniaudio-src = fetchFromGitHub {
    owner = "mackron";
    repo = "miniaudio";
    rev = "13d161bc8d856ad61ae46b798bbeffc0f49808e8";
    hash = "sha256-IUhyDD24HfTRbj8xQi1RNmlvVmvBWmBznKnrydGDQfk=";
  };

  emoji-segmenter-src = fetchFromGitHub {
    owner = "google";
    repo = "emoji-segmenter";
    rev = "1cada87c62550446fca6a42a69743688b4539a4c";
    hash = "sha256-qdcb5Tw9MOc40udLqxs+mB+Duz4d3PLdwky+0hnGt9E=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "acheron";
  version = "0-unstable-2026-05-04";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ouwou";
    repo = "acheron";
    rev = "ac7bd2829baee30001539c17c7a29e276c6739cd";
    hash = "sha256-QsQO1suP8ezqOoNR0ZQTxtey5MTBuqNo05N6P9WZUrU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    curl-impersonate
    libdave
    libopus
    libsodium
    nlohmann_json
    pcre2
    qt6Packages.qtbase
    qt6Packages.qtimageformats
    qt6Packages.qtkeychain
    qt6Packages.qttools
    spdlog
  ];
  
  cmakeFlags = [
    # We're not using vcpkg, so disable it.
    "-DCMAKE_TOOLCHAIN_FILE="
    "-DCURL_LIBRARY=${curl-impersonate}/lib/libcurl-impersonate.so"
  ];

   postPatch = ''
    rm -rf vendor/emoji-segmenter vendor/miniaudio
    ln -sf ${emoji-segmenter-src} vendor/emoji-segmenter
    # There is a miniaudio package on nixpkgs, but acheron just uses
    # #include "miniaudio.h" so the package cannot be used.
    ln -sf ${miniaudio-src} vendor/miniaudio

    substituteInPlace CMakeLists.txt \
      --replace-fail "find_package(unofficial-sodium CONFIG REQUIRED)" \
        "pkg_check_modules(sodium REQUIRED IMPORTED_TARGET libsodium)" \
      --replace-fail "find_package(Opus CONFIG REQUIRED)" \
        "pkg_check_modules(opus REQUIRED IMPORTED_TARGET opus)" \
      --replace-fail "add_subdirectory(vendor/libdave/cpp EXCLUDE_FROM_ALL)" \
        "pkg_check_modules(libdave REQUIRED IMPORTED_TARGET libdave)"

    sed -i \
      -e '/pkg_check_modules/!s|\<libdave\>|PkgConfig::libdave|' \
      -e 's|unofficial-sodium::sodium|PkgConfig::sodium|' \
      -e 's|Opus::opus|PkgConfig::opus|' \
      CMakeLists.txt  
    '';

  # Upstream cmake has no install rules, so we do it ourselves.
  installPhase = ''
    runHook preInstall

    install -Dm755 acheron $out/bin/acheron

    wrapProgram $out/bin/acheron \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ alsa-lib libpulseaudio ]}"

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
    description = "An alternative Discord client with voice support made with C++ and Qt 6 Widgets";
    mainProgram = "acheron";
    homepage = "https://github.com/ouwou/acheron";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ chocoblocko9 ];
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
