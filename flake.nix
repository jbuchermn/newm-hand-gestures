{
  description = "newm-hand-gestures";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (
    system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (self: super: rec {
            python3 = super.python3.override {
              packageOverrides = self1: super1: {
                opencv4 = (super1.opencv4.override { enableGtk3 = true; });
                mediapipe = super.callPackage ./mediapipe.nix {
                  inherit (super1) buildPythonPackage isPy38 isPy39 absl-py attrs matplotlib numpy six wheel fetchPypi;
                  python = python3;
                };
              };
            };
            python3Packages = python3.pkgs;
          })
        ];
      };

      dasbuspkg = {
        dasbus = pkgs.python3.pkgs.buildPythonPackage rec {
          pname = "dasbus";
          version = "1.6";

          src = pkgs.python3.pkgs.fetchPypi {
            inherit pname version;
            sha256 = "sha256-FJrY/Iw9KYMhq1AVm1R6soNImaieR+IcbULyyS5W6U0=";
          };

          setuptoolsCheckPhase = "true";

          propagatedBuildInputs = with pkgs.python3Packages; [ pygobject3 ];
        };
      };
    in
    {
      devShell = let
        my-python = pkgs.python3;
        python-with-my-packages = my-python.withPackages (ps: with ps; [
          opencv4
          tensorflow
          mediapipe
          dasbuspkg.dasbus

          python-lsp-server
          pylsp-mypy
          mypy
        ]);
      in
        pkgs.mkShell {
          buildInputs = [ python-with-my-packages ];
        };
    }
  );
}
