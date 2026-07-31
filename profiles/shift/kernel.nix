{ pkgs, lib, ... }:

let
  kernel = pkgs.stdenv.mkDerivation rec {
    pname = "linux";
    version = "7.1.3";

    target = "bzImage"; # nixpkgs broke stuff for no reason

    src = pkgs.linux_latest.src;

    nativeBuildInputs = [
      pkgs.bc
      pkgs.bison
      pkgs.flex
      pkgs.openssl.dev
      pkgs.elfutils
      pkgs.perl
      pkgs.python3
      pkgs.rsync
      pkgs.kmod
      pkgs.cpio
      pkgs.pahole
      pkgs.zstd
      # pkgs.zlib
    ];

    buildPhase = ''
      patchShebangs scripts/
      cp ${./kernel.config} .config
      make ARCH=x86_64 KCFLAGS="-march=znver3 -mtune=znver3" olddefconfig # big performance
      make ARCH=x86_64 KCFLAGS="-march=znver3 -mtune=znver3" -j$(nproc)   # gains trust
    '';

    installPhase = ''
      mkdir -p $out
      cp arch/x86/boot/bzImage $out/bzImage
      make ARCH=x86_64 INSTALL_MOD_PATH=$out modules_install
      rm -f $out/lib/modules/*/build
      rm -f $out/lib/modules/*/source
    '';

    passthru = {
      kernelAtLeast = v: lib.versionAtLeast version v;
      modDirVersion = version;
      features = {
        ia32Emulation = true;
      };
    };
  };
in kernel
