(final: prev: {
  # what
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

  # Included in 2.2.8 upstream, waiting on release
  ddcutil = prev.ddcutil.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/util/linux_util.c \
        --replace-fail "#include <execinfo.h>      // for segv handler" ""
    '';
  });

  # PR'd
  # merged
  breakpad = prev.breakpad.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [
      "--disable-tools"
    ];
  });

  /*
   wayland = prev.wayland.overrideAttrs (old: {
    mesonFlags = (old.mesonFlags or []) ++ [
      "-Ddocumentation=false"
    ];
    outputs = ["out" "dev" ];
  });
  */

  protobuf_33 = prev.protobuf_33.overrideAttrs (old: {
    doCheck = false;
  });

  fish = prev.fish.overrideAttrs (old: {
    doCheck = false;
  });

  pytest-timeout = prev.pytest-timeout.overrideAttrs (old: {
    doCheck = false;
  });

  libfaketime = prev.libfaketime.overrideAttrs (old: {
    doCheck = false;
  });

  perl = prev.perl.overrideAttrs (old: {
    doCheck = false;
    dontCheck = true;
    LC_ALL = "C.UTF-8";
  });

  gcr = prev.gcr.overrideAttrs (old: {
    env.NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") 
      + " -Wno-error=implicit-function-declaration -Wno-error=int-conversion";
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

  # Outdated, use pr
  /*
  firefox-unwrapped = prev.firefox-unwrapped.overrideAttrs (old: {
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

  level-zero = prev.level-zero.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./other-patches/Fix-incompatible-strerror_r-for-non-gnu-windows-libc.patch
      ./other-patches/meow.patch
    ];

    src = old.src.override {
      tag = "v1.32.0";
      hash = "sha256-u8q8VOuJKUCFNJ8aLR/BrVx9lU5vD+hwkHRmy77vFe8=";
    };
  });

  /*
  sqlite = prev.sqlite.overrideAttrs (old: {
    doCheck = false;
  });
  */

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

  # related to this, there was like a half fix
  # but cba to look into it 

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


  # ==================== Not necessary for pkgsMusl ====================
  
  # Tests don't even fail they just take FOREVER
  # I don't wanna run them
  openssl_3_6 = prev.openssl_3_6.overrideAttrs (old: {
    doCheck = false;
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
})
