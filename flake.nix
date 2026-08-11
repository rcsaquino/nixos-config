{
  description = "rcsaquino's NixOS Config";
  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    trcc-linux.url = "github:Lexonight1/thermalright-trcc-linux";
  };

  outputs = inputs: {
    nixosConfigurations = {
      main-pc = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.trcc-linux.nixosModules.default
          ./modules/hosts/main-pc/default.nix
          ./modules/hosts/main-pc/hardware.nix

          inputs.chaotic.nixosModules.default
          inputs.noctalia.nixosModules.default
          inputs.noctalia-greeter.nixosModules.default
          ./modules/apps.nix
          ./modules/configuration.nix
          ./modules/extras.nix
        ];
      };
    };
  };
}
