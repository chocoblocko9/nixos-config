{
  lib,
  fetchFromGitHub,
  rustPlatform,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oxmgr";
  version = "0.4.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Vladimir-Urik";
    repo = "OxMgr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+6asoef2KRvH1/p458/s4nDHpnC2TXUejQNlcWiJaS4=";
  };

  cargoHash = "sha256-U/YZh0+UjNojJ9K/vHjgKlqKcRExxF8IMmtsjrfF1dg=";

  # 3 tests require git
  nativeCheckInputs = [ git ];

  meta = {
    description = "A lightweight, cross-platform Rust process manager and PM2 alternative";
    homepage = "https://github.com/Vladimir-Urik/OxMgr";
    changelog = "https://github.com/Vladimir-Urik/OxMgr/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ choco98 ];
    mainProgram = "oxmgr";
  };
})
