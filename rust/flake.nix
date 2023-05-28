{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    starrpkgs = {
      url = "github:Starrfox/packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, flake-utils, naersk, nixpkgs, starrpkgs}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        spkgs = starrpkgs.packages.${system};

        naersk' = pkgs.callPackage naersk {};
        project_cargo = builtins.fromTOML (builtins.readFile ./Cargo.toml);

      in rec {
        defaultPackage = naersk'.buildPackage {
          name = throw "Need to set name";
          src = ./.;
          # extra built inputs here
          buildInputs = with pkgs; [];
          version = project_cargo.package.version;
        };

        devShell = pkgs.mkShell {
          packages = with pkgs; [rustc cargo just spkgs.commitizen];
        };
      }
    );
}
