#!/bin/bash

# Очищаем экран для красоты
clear
echo "🛠️  Мастер создания Distrobox-контейнера для Neovim"
echo "==================================================="

# 1. Спрашиваем имя контейнера
read -p "👉 Введите имя для нового контейнера (по умолчанию: arch-dev): " CONTAINER_NAME
CONTAINER_NAME=${CONTAINER_NAME:-arch-dev} # Если пустой ввод, будет arch-dev

IMAGE="archlinux:latest"

echo ""
echo "🚀 Создаем контейнер '$CONTAINER_NAME' из образа $IMAGE..."

# Создаем контейнер БЕЗ установки пакетов (флаг -Y подтверждает все вопросы yes)
distrobox create -i "$IMAGE" -n "$CONTAINER_NAME" -Y --pull

if [ $? -ne 0 ]; then
    echo "❌ Ошибка при создании контейнера. Проверьте имя (может такой уже есть?)."
    exit 1
fi

echo ""
echo "🔄 Первичное обновление системы (pacman -Syu)..."
# Сначала обновляем базы и ключи. Это критично для Arch.
distrobox enter "$CONTAINER_NAME" -- sh -c "sudo pacman -Syu --noconfirm"

echo ""
echo "📦 Установка зависимостей..."

# Список пакетов
PACKAGES=(
    # Основное
    neovim
    git
    base-devel      # Нужно для компиляции telescope-fzf-native и других плагинов
    
    # Шелл утилиты
    starship
    zoxide
    wl-clipboard    # Буфер обмена (ты просил wd-clipboard, но правильное имя wl-clipboard для Wayland)
    
    # Файловый менеджер
    yazi
    vivid
    
    # Для работы Mason и плагинов Neovim (Telescope и т.д.)
    ripgrep         # Поиск по файлам (grep)
    fd              # Поиск файлов (find)
    fzf             # Нечеткий поиск
    unzip           # Распаковка серверов Mason
    wget            # Скачивание серверов Mason
    curl            # Скачивание серверов Mason
    gzip            # Архивация
    tar             # Архивация
    
    # Mason (NodeJS нужен для 80% LSP серверов: html, css, json, bash-ls, markdown и т.д.)
    nodejs
    npm
)

# Преобразуем массив в строку
PKG_STRING="${PACKAGES[*]}"

# Заходим и устанавливаем
distrobox enter "$CONTAINER_NAME" -- sh -c "sudo pacman -S --noconfirm $PKG_STRING"

echo ""
echo "✅ Контейнер $CONTAINER_NAME готов!"
echo "---------------------------------------------------"
echo "Зайти внутрь:    distrobox enter $CONTAINER_NAME"
echo "Удалить (если что): distrobox rm $CONTAINER_NAME"
