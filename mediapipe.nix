{ lib, stdenv, buildPythonPackage, fetchPypi, autoPatchelfHook
, python, isPy38, isPy39, absl-py, attrs, matplotlib, numpy, opencv4, protobuf, six, wheel
, unzip, zip }:

buildPythonPackage rec {
  pname = "mediapipe";
  version = "0.8.9.1";
  format = "wheel";

  disabled = !(isPy38 || isPy39);

  pyInterpreterVersion = "cp${builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion}";

  src = fetchPypi {
    inherit pname version format;
    python = pyInterpreterVersion;
    abi = pyInterpreterVersion;
    dist = pyInterpreterVersion;
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    sha256 = "sha256-MZxyfvL9YzukfXAv38YQMEoW+Hxkm+Y3MKnT5/AVEAw=";
  };

  nativeBuildInputs = [ unzip zip autoPatchelfHook ];

  postPatch = ''
    # Patch out requirement for static opencv so we can substitute it with the nix version
    METADATA=mediapipe-${version}.dist-info/METADATA
    unzip $src $METADATA
    substituteInPlace $METADATA \
      --replace "Requires-Dist: opencv-contrib-python" ""
    chmod +w dist/*.whl
    zip -r dist/*.whl $METADATA
  '';

  propagatedBuildInputs = [
    absl-py
    attrs
    matplotlib
    numpy
    opencv4
    protobuf
    six
    wheel
  ];

  pythonImportsCheckPhase = "true";

  pythonImportsCheck = [ "mediapipe" ];
}
