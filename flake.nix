{
  description = "KayrOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
          home-manager.users.fighter-name = import ./nix/home.nix;
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
      };

      # 2. Приложение установщика
      apps.${system}.default = {
        type = "app";
        program = "${pkgs.writeShellScriptBin "install-KayrOS" ''
          export PATH=${pkgs.lib.makeBinPath [ 
            pkgs.whois
            pkgs.parted 
            pkgs.btrfs-progs
            pkgs.pciutils
            pkgs.util-linux
            pkgs.git 
            pkgs.gum 
            pkgs.nixos-install-tools
            pkgs.kbd
          ]}:$PATH

          bash ${self}/install_KayrOS.sh
        ''}/bin/install-KayrOS";
      };
    };
}
