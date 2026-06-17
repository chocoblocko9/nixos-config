{
  lib,
  stdenv,
  fetchFromCodeberg,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libudev-garden";
  version = "0.2.1";

  __structuredAttrs = true;

  src = fetchFromCodeberg {
    owner = "Gardenhouse";
    repo = "libudev-garden";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+95+3Hb6lkIhpNZF0pQdM9y5GxZCplp/o2nemZJb5Wc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  meta = {
    homepage = "https://codeberg.org/Gardenhouse/libudev-garden";
    description = "Daemonless replacement for libudev";
    maintainers = with lib.maintainers; [
      aanderse
      choco98
    ];
    license = lib.licenses.isc;
    pkgConfigModules = [ "libudev" ];
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
