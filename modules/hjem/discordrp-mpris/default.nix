{ lib
, buildPythonPackage
, fetchFromGitHub
, dbus  # The actual D-Bus library
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
    rev = "v${version}";  # or just version, check tags         =
    sha256 = "sha256-o4utv6yhDoE1iVFkwRKWZZLGQUCAPL/2Pz58SBVZZhM=";
  };
    
  # buildSystem = [ setuptools ]; 
  
  nativeBuildInputs = [ 
    pkg-config  # Needed to find dbus
    setuptools
    pytoml
    dbussy
  ];
  
  buildInputs = [ 
    dbus  # The C library it binds to
  ];

  propagatedBuildInputs = [ 
    dbussy
    pytoml
    # any other deps from requirements.txt
  ];
  
  meta = with lib; {
    description = "Discord Rich Presence for media players providing the mpris2 dbus interface ";
    homepage = "https://github.com/ldo/dbussy";
    license = licenses.lgpl21Plus;
  };
}
