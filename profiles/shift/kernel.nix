{ pkgs, lib, ... }:

let
  kernel = pkgs.stdenv.mkDerivation rec {
    pname = "linux";
    version = "7.0.3";

    src = pkgs.linux_latest.src;

    nativeBuildInputs = with pkgs; [
      bc
      bison
      flex
      openssl.dev
      elfutils
      perl
      python3
      rsync
      kmod
      cpio
      pahole
      zstd
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
    };
  };
in kernel
