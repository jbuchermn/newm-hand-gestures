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
                opencv4 = (opencv4.override { enableGtk3 = true; });
                mediapipe =  super.callPackage ./mediapipe.nix {
                  inherit (python3Packages) buildPythonPackage isPy38 isPy39 absl-py attrs matplotlib numpy six wheel fetchPypi opencv4;
                  python = python3;
                };
              };
            };
            python3Packages = python3.pkgs;
          })
        ];
      };
    in
    {
      devShell = let
        my-python = pkgs.python3;
        python-with-my-packages = my-python.withPackages (ps: with ps; [
          tensorflow
          mediapipe
          opencv4

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
