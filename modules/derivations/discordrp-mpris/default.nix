{ lib
, buildPythonPackage
, fetchFromGitHub
, dbus
, pkg-config
, setuptools
, callPackage
}:

let
  dbussy = callPackage ./dbussy { };
  pytoml = callPackage ./pytoml { };
in
buildPythonPackage rec {
  pname = "discordrp-mpris";
  version = "0.3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "FichteFoll";
    repo = "discordrp-mpris";
    rev = "v${version}";
    sha256 = "sha256-o4utv6yhDoE1iVFkwRKWZZLGQUCAPL/2Pz58SBVZZhM=";
  };
    
  nativeBuildInputs = [ 
    pkg-config
    setuptools
    pytoml
    dbussy
  ];
  
  buildInputs = [ 
    dbus
  ];

  propagatedBuildInputs = [ 
    dbussy
    pytoml
  ];
  
  meta = with lib; {
    description = "Discord Rich Presence for media players providing the mpris2 dbus interface ";
    homepage = "https://github.com/ldo/dbussy";
    license = licenses.lgpl21Plus;
  };
}
