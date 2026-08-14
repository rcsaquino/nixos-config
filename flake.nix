{
  description = "rcsaquino's NixOS Config";

  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    trcc-linux.url = "github:Lexonight1/thermalright-trcc-linux";
  };

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
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
