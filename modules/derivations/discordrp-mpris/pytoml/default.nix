{ lib
, buildPythonPackage
, fetchPypi
, setuptools
}:

buildPythonPackage rec {
  pname = "pytoml";
  version = "0.1.21";
  pyproject = true;
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-juz3yNCtz/OzdbCf5ANAeqm2RcSZ5auMrGcKxKNfYec=";
  };
  
  nativeBuildInputs = [ 
    setuptools
  ];
  
  meta = with lib; {
    description = "Python bindings for D-Bus";
    homepage = "https://github.com/ldo/dbussy";
    license = licenses.lgpl21Plus;
  };
}
