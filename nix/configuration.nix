{ config, pkgs, ... }:

{
  imports =
    [ 
        ./hardware-configuration.nix 
    ];

  # =============== Версия системы ==================
  system.stateVersion = "25.05"; 

  # ================= Загрузчик =====================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ======== Экспериментальные настройки ============
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ==================== Кэши =======================
  substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ]; 

  # ========== Чистка от старых снимков =============
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ==================== Сеть =======================
  networking.hostName = "fighter-name-pc"; 
  networking.networkmanager.enable = true;

  # =========== Часовой пояс и локаль ===============
  time.timeZone = "Europe/Moscow"; 
  i18n.defaultLocale = "en_US.UTF-8";

  # ============= Системные пакеты ==================
  environment.systemPackages = with pkgs; [
    vim            # Простенький аварийный vim редактор 
    git            # Система контроля версий
    curl           # Скачивание и запуск скриптов
    wget           # Рекурсивное скачивание, стойкость к обрывам 
    distrobox      # Обёртка для контейнеров podman
    qemu_kvm       # Виртуальная машина
  ];

  # ========= Разрешить несвободный софт ============
  nixpkgs.config.allowUnfree = true;

  # ============== Звук (Pipewire) ==================
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # =============== Графика (OpenGL) ================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  # =============== Консоль fish ====================
  programs.fish.enable = true;

  # ================= Hyprland ======================
  programs.hyprland.enable = true; 
  
  # ==== Display Manager (Экран входа SDDM) =========
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # ============= Сервис флатпаков ==================
  services.flatpak.enable = true;

  # =============== Виртуализация ===================
  virtualisation.podman.enable = true; 
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # ================ Пользователь ===================
  users.users.fighter-name = {
    isNormalUser = true;
    description = "fighter-name";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "video" "audio" ];
    shell = pkgs.fish;
    };
}
