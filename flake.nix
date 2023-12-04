{
  description = "My code project templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts/";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ {flake-parts, nix-systems, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = import nix-systems;
      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          name = "templates";
          packages = with pkgs; [
            cookiecutter
          ];
        };
      };
    };
}
