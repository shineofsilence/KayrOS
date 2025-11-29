{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix>
    ./configuration.nix
    # ./nvidia.nix # Включи, если нужен драйвер в ISO
    
    # Импортируем Home Manager
    <home-manager/nixos>
  ];

  # === 1. Оптимизация ISO ===
  isoImage.squashfsCompression = "zstd -Xcompression-level 15";
  system.installer.channel.enable = false;

  # === 2. Встраиваем репозиторий ===
  # Копируем твой текущий репо внутрь ISO в папку /etc/kayros
  environment.etc."kayros".source = ../.;

  # === 3. Настройка пользователя Live CD (nixos) ===
  users.users.nixos.shell = pkgs.fish;
  
  # === 4. Подключаем твой HOME.NIX к Live-пользователю ===
  home-manager.users.nixos = { pkgs, ... }: {
    imports = [ ./home.nix ];

    # ПЕРЕОПРЕДЕЛЯЕМ параметры пользователя для Live-режима
    # (так как в home.nix у тебя жестко задан "fighter-name")
    home.username = lib.mkForce "nixos";
    home.homeDirectory = lib.mkForce "/home/nixos";
    
    # Отключаем Git-настройки, чтобы не мешали в Live
    programs.git.enable = lib.mkForce false; 
  };

  # === 5. МАГИЯ КОНФИГОВ (Симлинк) ===
  # Мы говорим системе: "Сделай так, чтобы папка .config у пользователя nixos
  # смотрела на наш вшитый репозиторий /etc/kayros".
  # L+ означает "Создать симлинк, перезаписав, если что-то было".
  systemd.tmpfiles.rules = [
    "L+ /home/nixos/.config - - - - /etc/kayros"
  ];

  # === 6. Скрипт установки ===
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-system" ''
       sudo bash /etc/kayros/install_KayrOS.sh
    '')
  ];

  # === 7. Автологин и права ===
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "nixos";
  security.sudo.wheelNeedsPassword = false;
  
  # Сеть
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
}
