(final: prev: {
  musl = prev.musl.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
      prev.buildPackages.stdenv.cc.bintools
      # prev.buildPackages.binutils-unwrapped 
    ];

    makeFlags = (old.makeFlags or []) ++ [
      "CROSS_COMPILE=x86_64-unknown-linux-musl-"
    ];

    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") 
      + " -Wno-error=implicit-function-declaration -Wno-error=int-conversion";
  });
    
  stdenv = prev.stdenv.override (old: {
    extraAttrs = (old.extraAttrs or {}) // {
      NIX_CFLAGS_COMPILE = (old.extraAttrs.NIX_CFLAGS_COMPILE or "") 
        + " -O3 -pipe -fno-plt";
    };
  });

  # Turn off tests because they fail like 1/493 on musl
  boehm-gc = prev.boehm-gc.overrideAttrs (old: {
    doCheck = false;
  });

  wayland = prev.wayland.overrideAttrs (old: {
    mesonFlags = (old.mesonFlags or []) ++ [
      "-Ddocumentation=false"
    ];
    outputs = ["out" "dev" ];
  });

  pipewire = (prev.pipewire.override {
    enableSystemd = false;
    udev = prev.libudev-zero;
  }).overrideAttrs (o: {
    doCheck = false;
    NIX_CFLAGS_COMPILE = (o.NIX_CFLAGS_COMPILE or "") + " -Wno-error=nonnull -Wno-error=stringop-overread";
    patches = o.patches or [] ++ [ ./pipewire.patch ];
  });

  wireplumber = prev.wireplumber.override {
    pipewire = final.pipewire;
  };

  seatd = prev.seatd.override { systemdSupport = false; };

  gnutls = prev.gnutls.overrideAttrs (old: {
    doCheck = false;
  });

  libfaketime = prev.libfaketime.overrideAttrs (old: {
    doCheck = false;
    
    # use the 'env' attribute to consolidate flags cus modern or smth
    env = (old.env or {}) // {
      NIX_CFLAGS_COMPILE = toString [
        "-include pthread.h"
        "-Wno-implicit-function-declaration"
        "-Wno-int-conversion"
        "-Dforce_stat=1"
      ];
    };

    # no -Werror
    postPatch = (old.postPatch or "") + ''
      sed -i 's/-Werror//g' src/Makefile
    '';
  });

  perl = prev.perl.overrideAttrs (old: {
    doCheck = false;
    dontCheck = true;
    LC_ALL = "C.UTF-8";
  });

  # bad SDL :<
  sdl2-compat = prev.sdl2-compat.overrideAttrs (old: {
    doCheck = false;
  });

  sdl3 = prev.sdl3.overrideAttrs (old: {
    doCheck = false;
  });

  enlightenment.efl = prev.enlightenment.efl.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i 's/ino64_t/uint64_t/g; s/off64_t/uint64_t/g' \
      src/lib/eina/eina_file_posix.c
    '';
  });

  appstream = prev.appstream.overrideAttrs (old: {
    # none and required leaked into the meson file and
    # it thinks they're files I guess? not sure
    #
    # I'm surprised this built but it works
    postConfigure = ''
      sed -i 's/ none required / /g' build.ninja
      sed -i 's/ none$//g; s/ required$//g' build.ninja
    '';
  });

  hyprshutdown = prev.hyprshutdown.overrideAttrs (old: {
    # Append the disabling flags to CMake
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-Dglaze_ENABLE_TESTING=OFF"
      "-DBUILD_TESTING=OFF"
    ];
  });

  lua-language-server = prev.lua-language-server.overrideAttrs (old: {
    doCheck = false;
  });

  perlPackages = prev.perlPackages // {
    Test2Harness = prev.perlPackages.Test2Harness.overrideAttrs { 
      doCheck = false; 
    };
  };
})
