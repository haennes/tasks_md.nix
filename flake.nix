{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = rec {
      default = tasks;
      tasks = import ./tasks.nix;
      home-manager = import ./tasks.nix;
    };
  };
}
