{ pkgs, lib, ... }:

let
  kitty' = (pkgs.pkgsMusl.kitty.override {
    simde = simde';
    zsh = zsh';
    fish = fish';
  }).overrideAttrs (oldAttrs: {
    # 1. Add the dev packages to buildInputs
    buildInputs = (oldAttrs.buildInputs or []) ++ [
      pkgs.libXrender.dev
      pkgs.libXext.dev
      pkgs.libX11.dev
    ];

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeBinaryWrapper ];

    NIX_CFLAGS_COMPILE = (oldAttrs.NIX_CFLAGS_COMPILE or "") 
      + " -O3 -march=native -flto ";

    dopreBuild = ''
    # This is so messed up but like, gotta give those deps! idk why but we do!
    for pkg in ${lib.concatStringsSep " " (map (p: lib.getDev p) (oldAttrs.buildInputs or []) ++ [
        pkgs.libXrender.dev
        pkgs.libXfixes.dev
        pkgs.libXi.dev
        pkgs.libXext.dev
        pkgs.xorgproto
        pkgs.zlib.dev
        pkgs.libpng.dev
        pkgs.libxkbcommon
      ])}; do
      if [ -d "$pkg/include" ]; then
        # Link every sub-directory found in the dependency's include folder
        find "$pkg/include" -maxdepth 1 -mindepth 1 -type d -exec ln -sf {} . \;
        # Also link top-level files like zlib.h (how is this necessary)
        find "$pkg/include" -maxdepth 1 -type f -name "*.h" -exec ln -sf {} . \;
      fi
    done
    '';

    postInstall = (oldAttrs.postInstall or "") + ''
      wrapProgram $out/bin/kitty \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.libGL pkgs.wayland pkgs.libxkbcommon ]}"
    '';

  doCheck = false;
  });

  zsh' = pkgs.pkgsMusl.zsh.overrideAttrs (oldZsh: {
    # Drop -O3 and LTO for Zsh to avoid the GIMPLE ICE
    NIX_CFLAGS_COMPILE = "-O2 -march=native";
    # 'fortify' to stop 'objsz' build failure
    hardeningDisable = [ "fortify" ]; 
  });

  fish' = (pkgs.fish.overrideAttrs (oldAttrs: {
    doCheck = false;
  }));

  simde' = pkgs.pkgsMusl.simde.overrideAttrs (old: {
    pname = "simde-unstable";
    version = "0.8.2-unstable-2026-04-28";
    src = pkgs.fetchFromGitHub {
      owner = "simd-everywhere";
      repo = "simde";
      rev = "1747b2482589fe894d49989159421da08c2a8bcd"; 
      hash = "sha256-GyntWt+bBOtkJOgLeWjYeSPnwCUlH1bmYXy7MbH/2MI=";
    };
    doCheck = false;
  });
in
{
 hjem.users.conor = {
    packages = [ kitty' ];

    files.".config/kitty/kitty.conf".text = ''
      font_family JetBrainsMono Nerd Font
      font_size 14

      shell_integration no-rc

      background #001e26
      background_blur 32
      background_opacity 0.700000
      confirm_os_window_close 0
    '';
  };
}
