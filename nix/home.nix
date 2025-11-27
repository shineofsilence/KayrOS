{ config, pkgs, ... }:

{
  home.stateVersion = "25.05";
  home.username = "fighter-name";
  home.homeDirectory = "/home/fighter-name";

  # =========== Джентельменский набор приложений =============
  home.packages = with pkgs; [
    # =========== Hyprland Обвес ============
    hyprlock         # Экран блокировки
    polkit_gnome     # Форма запроса приложением root-пароля
    waybar           # Статусная строка
    hyprpaper        # Обои
    pavucontrol      # Управление звуковыми устройствами
    rofimoji         # Выбор иконок и эмоджи
    wofi             # Интерфейс выбора иконок
    font-awesome     # Шрифты и их иконки
    wtype            # Чтобы иконка сама вставилась, а не через буфер
    dunst            # Уведомления
    grim             # Скриншоты
    slurp            # Выделение на скриншоте
    kitty            # Терминал
    zathura          # Просмотрщик PDF
    imv              # Просмотрщик изображений
    cmus             # Проигрыватель музыки
    mpv              # Проигрыватель видео

    # ========= Консольные утилиты ==========
    btop             # Монитор системных ресурсов и процессов
    ncdu             # Утилита для чистки дисков
    wl-clipboard     # Общий буфер обмена с консолью
    starship         # Fish - Строка ввода
    eza              # Fish - Настраиваемый ls
    zoxide           # Fish - Быстрый телепорт по z
    yazi             # Файловый менеджер
    jq               # JSON процессор
    fd               # Быстрый поиск файлов в yazi
    poppler-utils    # Предпросмотр PDF в yazi
    ffmpegthumbnailer# Предпросмотр видео в yazi
    p7zip            # Архиватор 7z

    # ============= Разработка ==============
    neovim           # Текстовый редактор
    ripgrep          # Рекурсивный поиск для neovim
    git              # Система контроля версий
    gh               # CLI от GitHub. Управление репозиториями, SSH
    lazygit          # TUI-интерфейс локального репозитория
  ];

  # ================ Темы GTK ================
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    iconTheme.name = "Adwaita";
  };
}
