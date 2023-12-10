{
  description = "{{ cookiecutter.description }}";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts/";
    nix-systems.url = "github:nix-systems/default";
    {% if cookiecutter.use_poetry2nix %}
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    {% endif %}
    {% if cookiecutter.use_precommit %}
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    {% endif %}
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nix-systems,
    {% if cookiecutter.use_poetry2nix %}
    poetry2nix,
    {% endif %}
    {% if cookiecutter.use_precommit %}
    pre-commit-hooks,
    {% endif %}
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
        {% if cookiecutter.use_poetry2nix %}
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
        {% else %}
        pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);
        {% endif %}

        packageName = "{{ cookiecutter.project_slug }}";
      in {
        {% if cookiecutter.use_poetry2nix %}
        packages.${packageName} = poetry2nix'.mkPoetryApplication {
          projectDir = ./.;
          preferWheels = true;
          python = pkgs.python311;
          overrides = [
            poetry2nix'.defaultPoetryOverrides
            customOverrides
          ];
        };
        {% else %}
        packages.${packageName} = python.pkgs.buildPythonPackage {
          src = ./.;
          pname = packageName;
          version = pyproject.tool.poetry.version;
          format = "pyproject";
          pythonImportsCheck = [packageName];
          nativeBuildInputs = [
            python.pkgs.poetry-core
          ];
          propagatedBuildInputs = with python.pkgs; [];

          meta.mainProgram = packageName;
        };
        {% endif %}

        packages.default = self'.packages.${packageName};

        {% if cookiecutter.use_precommit %}
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              black.enable = true;
              alejandra.enable = true;
              statix.enable = true;
            };
          };
        };
        {% endif %}

        devShells.default = pkgs.mkShell {
          name = packageName;
          {% if cookiecutter.use_precommit %}
          inherit (self'.checks.pre-commit-check) shellHook;
          {% endif %}
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
