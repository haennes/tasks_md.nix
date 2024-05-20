{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    tasks_md.url = "git+file:///home/hannses/programming/nix/tasks";
  };

  outputs = { self, nixpkgs, tasks_md }: {
    nixosConfigurations.host1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./example.nix
        tasks_md.nixosModules.default
      ];
    };
  };
}
