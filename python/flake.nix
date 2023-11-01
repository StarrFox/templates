{
  description = throw "change description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts/";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nix-systems,
    poetry2nix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = import nix-systems;
      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: let
        python = pkgs.python311;

        customOverrides = self: super: {
          # looks like this:
          # buildInputs = needed to build wheel
          # propagatedBuildInputs = needed for running
          # uwuify = super.uwuify.overridePythonAttrs (
          #   old: {
          #     buildInputs = (old.buildInputs or []) ++ [super.poetry];
          #   }
          # );
        };

        poetry2nix' = poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};

        packageName = throw "change package name";
      in {
        packages.${packageName} = poetry2nix'.mkPoetryApplication {
          projectDir = ./.;
          preferWheels = true;
          python = pkgs.python311;
          overrides = [
            poetry2nix'.defaultPoetryOverrides
            customOverrides
          ];
        };

        packages.default = self'.packages.${packageName};

        devShells.default = pkgs.mkShell {
          name = packageName;
          packages = with pkgs; [
            (poetry.withPlugins(ps: with ps; [poetry-plugin-up]))
            python
            just
            alejandra
            python.pkgs.black
            python.pkgs.isort
            python.pkgs.vulture
          ];
        };
      };
    };
}
