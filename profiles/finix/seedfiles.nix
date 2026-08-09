{
  lib,
  stdenv,
  fetchFromCodeberg,
  nix-update-script,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seedfiles";
  version = "1.7";

  __structuredAttrs = true;

  src = fetchFromCodeberg {
    owner = "Gardenhouse";
    repo = "seedfiles";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3cCj7KD3aqiViEStLeHxP0JxBcvERzSG44SgmvNnKig=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://codeberg.org/Gardenhouse/libudev-garden";
    description = "Portable drop-in reimplementation of systemd-tmpfiles";
    maintainers = with lib.maintainers; [
      aanderse
      choco98
    ];
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
  };
})
