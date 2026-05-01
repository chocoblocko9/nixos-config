{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  mlspp,
  nlohmann_json,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdave";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "discord";
    repo = "libdave";
    rev = "v${finalAttrs.version}/cpp";
    hash = "sha256-ALDmtAjSkjnLDcmtpvcwiN7dPvpOgOTNFolr/H3SqsE=";
  };

  sourceRoot = "source/cpp";

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    mlspp
    openssl
    nlohmann_json
  ];

  meta = {
    description = "Discord's End-to-End Audio Visual Encryption (DAVE) library";
    homepage = "https://github.com/discord/libdave";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ chocoblocko9 ];
  };
})
