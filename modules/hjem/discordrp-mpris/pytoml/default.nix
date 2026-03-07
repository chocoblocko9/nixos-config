{ lib
, buildPythonPackage
, fetchPypi
, setuptools
}:

buildPythonPackage rec {
  pname = "pytoml";
  version = "0.1.21";  # Check actual version
  pyproject = true;
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-juz3yNCtz/OzdbCf5ANAeqm2RcSZ5auMrGcKxKNfYec=";  # Run once to get real hash
  };
  
  nativeBuildInputs = [ 
    setuptools
  ];
  
  buildInputs = [ 
  ];
  
  # Might need this if it has C extensions
  # that need to find dbus headers
  
  meta = with lib; {
    description = "Python bindings for D-Bus";
    homepage = "https://github.com/ldo/dbussy";
    license = licenses.lgpl21Plus;
  };
}
