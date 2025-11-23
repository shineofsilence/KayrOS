{ config, pkgs, ... }:

{
  imports =
    [ 
      # ./hardware-configuration.nix 
    ];

  # =============== Версия системы ==================
  system.stateVersion = "24.05"; 

  # ================= Загрузчик =====================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ==================== Сеть =======================
  networking.hostName = "kayros-pc"; 
  networking.networkmanager.enable = true;

  # =========== Часовой пояс и локаль ===============
  time.timeZone = "Europe/Moscow"; 
  i18n.defaultLocale = "en_US.UTF-8";

  # ============= Системные пакеты ==================
  environment.systemPackages = with pkgs; [
    vim            # Простенький vim редактор 
    git            # Система контроля версий
    curl           # Скачивание и запуск скриптов
    wget           # Рекурсивное скачивание, стойкость к обрывам 
    distrobox      # Обёртка для контейнеров podman
    qemu_full      # Виртуальная машина
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

  # ================== Nvidia =======================
  # Раскомментировать блок ниже ТОЛЬКО на реальном железе.
  /*
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # Используем проприетарные драйверы
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  */

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
  users.users.kayros = {
    isNormalUser = true;
    description = "Кайрос";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "video" "audio" ];
    shell = pkgs.fish;
    };
}
