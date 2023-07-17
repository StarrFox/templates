{
  description = "My code project templates";

  inputs = {};

  outputs = {self}: {
    templates = {
      python = {
        path = ./python;
        description = "Basic python project";
      };

      rust = {
        path = ./rust;
        description = "Basic rust project";
      };

      packwiz = {
        path = ./packwiz;
        description = "Packwiz template";
      };
    };
  };
}
