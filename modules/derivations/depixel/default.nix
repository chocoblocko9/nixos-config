{
  stdenvNoCC,
  lib,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "depixel";
  version = "1.0";

  src = fetchurl {
    url = "dl.dafont.com/dl/?f=depixel";
    hash = "sha256-YmvBlMHO6GzZyRCWSF1LP/te7fb1Me38Xvhuce2tlRY=";
  };

  nativeBuildInputs = [ unzip ];

  dontUnpack = true;

  installPhase = ''
    unzip $src

    runHook preInstall
    install -Dm644 *.ttf -t $out/share/fonts/truetype
      
    runHook postInstall
  '';

  meta = {
    description = "Pixelated fonts";
    homepage = "https://github.com/IdreesInc/Miracode";
    license = lib.licenses.ofl; # I'm lying
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ choco98 ];
  };
})
