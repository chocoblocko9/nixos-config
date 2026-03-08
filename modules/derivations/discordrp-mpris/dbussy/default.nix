{ lib
, buildPythonPackage
, fetchFromGitLab
, dbus  # The actual D-Bus library
, pkg-config
, setuptools
}:

buildPythonPackage rec {
  pname = "dbussy";
  version = "1.3";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "ldo";
    repo = "dbussy";
    rev = "v${version}";
    sha256 = "sha256-FSJpbsOGHfpafy9hfOENDyPDmolmjFDDpJEKnI4pkFc=";
  };
    
  nativeBuildInputs = [ 
    pkg-config
    setuptools
  ];
  
  buildInputs = [ 
    dbus.lib
  ];

  postPatch = ''
    substituteInPlace dbussy.py \
      --replace 'ct.cdll.LoadLibrary("libdbus-1.so.3")' \
                'ct.cdll.LoadLibrary("${dbus.lib}/lib/libdbus-1.so.3")'
  '';

  meta = with lib; {
    description = "Python bindings for D-Bus";
    homepage = "https://github.com/ldo/dbussy";
    license = licenses.lgpl21Plus;
  };
}
