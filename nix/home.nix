{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";
  home.username = "kayros";
  home.homeDirectory = "/home/kayros";

  # =========== Джентельменский набор приложений =============
  home.packages = with pkgs; [
    # =========== Hyprland Обвес ============
    hyprlock         # Экран блокировки
    polkit_gnome     # Форма запроса приложением root-пароля
    waybar           # Статусная строка
    wl-clipboard     # Общий буфер обмена с консолью
    pavucontrol      # Управление звуковыми устройствами
    wofi             # Лаунчер приложений:
    dunst            # Уведомления
    jq               # Обработка json
    grim             # Скриншоты
    slurp            # Выделение на скриншоте
    hyprpaper        # Обои
    font-awesome     # Иконки

    # =========== GUI Приложения ============
    kitty            # Терминал
    cmus             # Проигрыватель музыки
    mpv              # Проигрыватель видео
    imv              # Просмотрщик изображений
    zathura          # Просмотрщик PDF

    # ========= Консольные утилиты ==========
    btop             # Монитор системных ресурсов и процессов
    ncdu             # Утилита для чистки дисков
    yazi             # Файловый менеджер
    fd               # Быстрый поиск файлов в yazi
    poppler_utils    # Предпросмотр PDF в yazi
    ffmpegthumbnailer# Предпросмотр видео в yazi
    p7zip            # Архиватор 7z

    # ============= Разработка ==============
    neovim           # Текстовый редактор
    ripgrep          # Рекурсивный поиск для neovim
    git              # Система контроля версий
    gh               # CLI от GitHub. Управление репозиториями, SSH
    lazygit          # TUI-интерфейс локального репозитория
    gcc              # Комплект разработчика
    gnumake          # Билдер
  ];

  # === Темы GTK (Чтобы софт выглядел красиво) ===
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    iconTheme.name = "Adwaita";
  };
}
