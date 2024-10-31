{
  description = "A very basic flake";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }: rec {
    nixosModules = rec {
      default = tasks;
      tasks = import ./tasks.nix;
      home-manager = import ./tasks.nix;
    };
    nixosConfigurations.host1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./example.nix nixosModules.default ];
    };
    formatter = let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-classic);
  };
}
