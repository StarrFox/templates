{
  description = "{{ cookiecutter.description }}";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts/";
    nix-systems.url = "github:nix-systems/default";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = inputs @ {
    flake-parts,
    nix-systems,
    naersk,
    nixpkgs,
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
        naersk' = pkgs.callPackage naersk {};
        projectCargo = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        packageName = "{{ cookiecutter.project_slug }}";
      in {
        packages.${packageName} = naersk'.buildPackage {
          name = packageName;
          src = ./.;
          version = projectCargo.package.version;
        };

        packages.default = self'.packages.${packageName};

        devShells.default = pkgs.mkShell {
          name = packageName;
          packages = with pkgs; [
            rustc
            cargo
            just
            alejandra
          ];
        };
      };
    };
}
