{ 
  lib,
  stdenv,
  fetchurl,
  patchelf,
  gcc-unwrapped,
  icu,
  openssl,
  sqlite,
  musl, 
 }:

stdenv.mkDerivation (finalAttrs: {
  pname = "sonarr";
  version = "4.0.19.2979";

  src = fetchurl {
    url = "https://github.com/Sonarr/Sonarr/releases/download/v${finalAttrs.version}/Sonarr.main.${finalAttrs.version}.linux-musl-x64.tar.gz";
    hash = "sha256-35Wq+jY9cmIM3OEkRX4vF7l/0E659yK22xahNwTfk6Q=";
  };

  nativeBuildInputs = [ patchelf ];

  # Stop nix from stripping out the rpath
  dontPatchELF = true;

  installPhase =
    let
      interpreter = "${musl}/lib/ld-musl-x86_64.so.1";
      rpath = lib.makeLibraryPath [
        gcc-unwrapped.lib
        icu.out
        openssl.out
      ];
    in
    ''
      mkdir -p $out/share/sonarr
      cp -r . $out/share/sonarr

      patchelf \
        --set-interpreter ${interpreter} \
        --set-rpath "${rpath}" \
        $out/share/sonarr/Sonarr

      # i swear to god it actually looks for this
      ln -s ${sqlite.out}/lib/libsqlite3.so.0 $out/share/sonarr/liblibsqlite3.so.0

      mkdir -p $out/bin
      ln -s $out/share/sonarr/Sonarr $out/bin/sonarr
    '';
})
