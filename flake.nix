{
  description = "My code project templates";

  outputs = { self }: {
    templates = {
      python = {
        path = ./python;
        description = "Basic python project";
      };
    };
  };
}