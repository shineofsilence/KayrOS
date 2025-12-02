import asyncio
import os
import json
import subprocess

class Hyprland:
    # Конструктор
    def __init__(self, bus):
        self.bus = bus
        signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")

        # Пути к сокетам
        self.hypr_event_socket = f"/tmp/hypr/{signature}/.socket2.sock"
        self.my_command_socket = os.path.expanduser("~/.kayros.sock")

        # ЕДИНАЯ ОЧЕРЕДЬ ИСПОЛНЕНИЯ
        # Гарантирует, что команды летят в Hyprland строго по одной
        self._dispatch_queue = asyncio.Queue()

    async def start(self):
        """Запускает все процессы ввода-вывода"""
        
        # 1. Input: Слушаем события Hyprland (Events)
        if os.path.exists(self.hypr_event_socket):
            asyncio.create_task(self._listen_hypr_events())
            
        # 2. Input: Слушаем твои команды (Hotkeys/IPC)
        await self._start_command_server()
        
        # 3. Output: Воркер, который разгребает очередь и дергает hyprctl
        asyncio.create_task(self._dispatcher_worker())

    # ================= INPUT: HYPRLAND EVENTS =================
    async def _listen_hypr_events(self):
        reader, _ = await asyncio.open_unix_connection(self.hypr_event_socket)
        while True:
            data = await reader.read(1024)
            if not data: break
            
            # Парсим поток событий
            events = data.decode('utf-8', errors='ignore').split('\n')
            for event in events:
                if event.startswith("openwindow>>"):
                    # Тут можно сразу принять решение или кинуть в Bus
                    # Пример: сами реагируем на открытие (внутренняя логика)
                    await self._handle_window_open(event)

    # ================= INPUT: USER COMMANDS (IPC) =================
    async def _start_command_server(self):
        # Удаляем старый сокет, если остался
        if os.path.exists(self.my_command_socket):
            os.remove(self.my_command_socket)
            
        server = await asyncio.sjart_server(
            self._handle_ipc_client, path=self.my_command_socket
        )
        # Сервер работает фоном внутри Loop

    async def _handle_ipc_client(self, reader, writer):
        """Обработка входящей команды от хоткея (echo 'swap' | socat ...)"""
        data = await reader.read(100)
        command = data.decode().strip()
        
        if command == "swap":
            # Кладем сложную логику в очередь
            await self._dispatch_queue.put({"type": "logic", "name": "swap"})
        elif command.startswith("exec"):
            # Кладем простую команду
            cmd_str = command.split(" ", 1)[1]
            await self._dispatch_queue.put({"type": "raw", "cmd": cmd_str})

        writer.close()

    # ================= LOGIC & OUTPUT (WORKER) =================
    async def _dispatcher_worker(self):
        """Единственное место, которое имеет право трогать hyprctl"""
        while True:
            # Ждем задачу из очереди
            task = await self._dispatch_queue.get()
            
            if task["type"] == "raw":
                # Просто выполнить hyprctl dispatch ...
                await self._run_hyprctl(task["cmd"])
                
            elif task["type"] == "logic":
                # Выполнить сложный сценарий (например, твой smart_swap)
                if task["name"] == "swap":
                    await self._logic_smart_swap()
            
            # Важно: даем Hyprland время обработать команду, прежде чем слать следующую
            # Это предотвращает глитчи анимаций
            # await asyncio.sleep(0.005) 
            self._dispatch_queue.task_done()

    # ================= HELPERS =================
    async def _run_hyprctl(self, args):
        # Реальный вызов subprocess
        # Можно использовать run_in_executor, если боимся блокировки
        proc = await asyncio.create_subprocess_shell(
            f"hyprctl dispatch {args}",
            stdout=subprocess.DEVNULL
        )
        await proc.wait()

    async def _logic_smart_swap(self):
        # Твоя логика перестановки окон (из python скрипта выше)
        # ... get active window ...
        # ... if grouped ...
        # ВАЖНО: Внутри этой логики мы НЕ вызываем _run_hyprctl напрямую,
        # если хотим строгую очередь, либо вызываем, понимая, что мы ВНУТРИ воркера.
        # В данном случае, так как мы внутри воркера, можно вызывать _run_hyprctl.
        pass
