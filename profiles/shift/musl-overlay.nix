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

  /*
  sonarr = prev.sonarr.override {
      dotnet-sdk_8 = prev.dotnetCorePackages.sdk_8_0-source;
    };
    radarr = prev.radarr.override {
      dotnet-sdk_8 = prev.dotnetCorePackages.sdk_8_0-source;
    };
  */

  # FIXME: lame as fuck
  dotnet-sdk_8 = prev.dotnet-sdk_8.overrideAttrs (old: {
    src = final.fetchurl {
      url = "https://dotnetcli.azureedge.net/dotnet/Sdk/8.0.422/dotnet-sdk-8.0.422-linux-musl-x64.tar.gz";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    nativeBuildInputs = builtins.filter
    (x: x != final.autoPatchelfHook)
    old.nativeBuildInputs;
  });

  # Included in 2.2.8 upstream, waiting on release
  ddcutil = prev.ddcutil.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/util/linux_util.c \
        --replace-fail "#include <execinfo.h>      // for segv handler" ""
    '';
  });

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

  # Upstreamed! 
  # Waiting for staging-next merge
  sdl2-compat = prev.sdl2-compat.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      (prev.lib.cmakeFeature "CMAKE_BUILD_RPATH" (prev.lib.makeLibraryPath [ final.sdl3 ]))
    ];
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

  # PR merged!
  # (in nixos-unstable yet?) 
  glaze = prev.glaze.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or []) ++ [
      "-Dglaze_ENABLE_FUZZING=OFF"
    ];
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
