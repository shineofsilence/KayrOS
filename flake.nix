{
  description = "KayrOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Общие модули для всех конфигураций
      baseModules = [
        ./nix/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.kayros = import ./nix/home.nix;
        }
      ];
    in
    {
      # 1. Конфигурации системы (Варианты установки)
      nixosConfigurations = {
        
        # Вариант А: Графика AMD или Intel, виртуалки (nixos-install --flake .#KayrOS-Main)
        KayrOS-Main = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules;
        };

        # Вариант Б: Графика Nvidia (nixos-install --flake .#KayrOS-Nvidia)
        KayrOS-Nvidia = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ [
            ./nix/nvidia.nix 
          ];
        };

        # 3. СБОРКА ISO: Команда: nix build .#iso
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ [
          ./nix/iso.nix
        ];
      };
    };
}
