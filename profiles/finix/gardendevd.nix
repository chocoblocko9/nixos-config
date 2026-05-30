{
  lib,
  stdenv,
  fetchFromCodeberg,
  acl,
  elogind,
  mdevd,
  meson,
  ninja,
  pkg-config,
  util-linux,
  kmod,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gardendevd";
  version = "0.1";

  src = fetchFromCodeberg {
    owner = "Gardenhouse";
    repo = "gardendevd";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-8G6Omeia1W+4dZOVHGtY/9CnKEpqD2x/W8Zkjt7fK/Q=";
  };

  nativeBuildInputs = [
    acl
    elogind
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ mdevd ];

  postPatch = ''
    substituteInPlace src/rules-builtin.c \
      --replace '/sbin/blkid' '${util-linux}/bin/blkid' \
      --replace '/sbin/modprobe' '${kmod}/bin/modprobe'
    substituteInPlace src/rules-parse.c \
      --replace '/usr/lib/udev/rules.d' "$out/lib/udev/rules.d"
    substituteInPlace src/spawn.c \
      --replace '/usr/lib/udev/' "$out/lib/udev/"

    patchShebangs scripts/
  '';

  meta = {
    homepage = "https://codeberg.org/Gardenhouse/gardendevd";
    description = "Daemonless replacement for libudev";
    maintainers = with lib.maintainers; [
      aanderse 
      choco98 
    ];
    license = lib.licenses.mit; # no license in repo im pretty sure lol
    pkgConfigModules = [ "libudev" ];
    platforms = lib.platforms.linux;
  };
})
