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
    
  /*
  stdenv = prev.stdenv.override (old: {
    extraAttrs = (old.extraAttrs or {}) // {
      NIX_CFLAGS_COMPILE = (old.extraAttrs.NIX_CFLAGS_COMPILE or "") 
        + " -O3 -pipe -fno-plt";
    };
  });
  */

  /*
  firefox = prev.firefox.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.mold ];
  env = (old.env or {}) // {
    NIX_LDFLAGS = "-fuse-ld=mold -Wl,--threads=3";
    RUSTFLAGS = "-C link-arg=-fuse-ld=mold -C link-args=-Wl,--threads=3";
  };
});
*/

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

  fish = prev.fish.overrideAttrs (old: {
    doCheck = false;
  });

  pytest-timeout = prev.pytest-timeout.overrideAttrs (old: {
    doCheck = false;
  });

  wireplumber = prev.wireplumber.override {
    pipewire = final.pipewire;
  };

  seatd = prev.seatd.override { systemdSupport = false; };

  libfaketime = prev.libfaketime.overrideAttrs (old: {
    doCheck = false;
  });

  perl = prev.perl.overrideAttrs (old: {
    doCheck = false;
    dontCheck = true;
    LC_ALL = "C.UTF-8";
  });

  # Upstreamed! 
  # Waiting for staging-next merge
  sdl2-compat = prev.sdl2-compat.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      (prev.lib.cmakeFeature "CMAKE_BUILD_RPATH" (prev.lib.makeLibraryPath [ final.sdl3 ]))
    ];
  });

  ffmpeg_7 = prev.ffmpeg.overrideAttrs (old: {
    doCheck = false;
  });

  adw-gtk3 = (prev.adw-gtk3.override {
    dart-sass = prev.sass; 
  }).overrideAttrs (old: {
  postPatch = (prev.postPatch or "") + ''
    substituteInPlace src/theme-{dark,light}/meson.build \
      --replace-fail '--no-source-map' '--sourcemap=none'
    '';
  });

  # PR made
  glaze = prev.glaze.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or []) ++ [
      "-Dglaze_ENABLE_FUZZING=OFF"
    ];
  });

  /*
  firefox-unwrapped = prev.firefox-unwrapped.overrideAttrs (old: {
nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
  prev.llvmPackages_21.lld
];
env = (old.env or {}) // {
  # NIX_LDFLAGS = "-fuse-ld=lld -Wl,--threads=3";
  # RUSTFLAGS = "-C link-arg=-fuse-ld=lld -C link-args=-Wl,--threads=3 -C codegen-units=4";
  MOZ_MAKE_FLAGS = "-j3";
  # CARGO_BUILD_JOBS = "3";
};
    patches = (old.patches or []) ++ [
      ./ff-patches/single-threaded-header.patch
      ./ff-patches/mallinfo.patch
      ./ff-patches/firefox-148-mach-clobber.patch
      ./ff-patches/firefox-148-webrtc-missing-includes.patch
      ./ff-patches/firefox-146-musl-linux-sys-prctl-conflict.patch
    ];
  });
  */

  libcanberra = prev.libcanberra.overrideAttrs (old: {
    # musl doesn't provide ldconfig, so bypass it
    #
    # also bypass relinking as we dont need to do so
    postConfigure = (old.postConfigure or "") + ''
      substituteInPlace libtool \
        --replace-fail 'ldconfig' 'true'
      substituteInPlace libtool \
        --replace-fail 'relink_command=' 'true; relink_command='
    '';
  });

  # Upstreamed :)
  # Waiting for new release
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

  /*
  libfyaml = prev.libfyaml.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      sed -i 's/none required//g' \
        $dev/lib/pkgconfig/libfyaml.pc
    '';
  });
  */

  lua-language-server = prev.lua-language-server.overrideAttrs (old: {
    doCheck = false;
  });

  perlPackages = prev.perlPackages // {
    Test2Harness = prev.perlPackages.Test2Harness.overrideAttrs { 
      doCheck = false; 
    };
  };
})
