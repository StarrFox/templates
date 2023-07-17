{
  description = throw "change description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts/";
    nix-systems.url = "github:nix-systems/default";
    naersk.url = "github:nix-community/naersk";
    starrpkgs = {
      url = "github:StarrFox/packages";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nix-systems.follows = "nix-systems";
      };
    };
  };

  outputs = inputs @ {self, flake-parts, nix-systems, naersk, nixpkgs, starrpkgs, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = import nix-systems;
      perSystem = {pkgs, system, self', ...}: let
        spkgs = starrpkgs.packages.${system};
        naersk' = pkgs.callPackage naersk {};
        projectCargo = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        packageName = throw "change package name";
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
            spkgs.commitizen
            alejandra
          ];
        };
      };
    };
}
