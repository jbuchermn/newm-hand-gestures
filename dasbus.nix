{ buildPythonPackage
, fetchPypi
, pygobject3}:

buildPythonPackage rec {
  pname = "dasbus";
  version = "1.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-FJrY/Iw9KYMhq1AVm1R6soNImaieR+IcbULyyS5W6U0=";
  };

  setuptoolsCheckPhase = "true";

  propagatedBuildInputs = [
    pygobject3
  ];
}
