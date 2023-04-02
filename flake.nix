{
  description = "My code project templates";

  inputs = {
    nixCargo.url = "github:yusdacra/nix-cargo-integration";
  };

  outputs = { self, nixCargo }: {
    templates = {
      python = {
        path = ./python;
        description = "Basic python project";
      };

      rust = {
        path = ./rust;
        description = "Basic rust project";
      };

      rust-crate = nixCargo.templates.simple-crate;
    };
  };
}