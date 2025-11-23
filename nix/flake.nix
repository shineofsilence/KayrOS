{
  description = "KayrOS";
  inputs = {
    # Unstable ветка для свежего софта
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Home Manager для управления софтом пользователя
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # Имя хоста - 'KayrOS'
      KayrOS = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kayros = import ./home.nix;
          }
        ];
      };
    };
  };
}
