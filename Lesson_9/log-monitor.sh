#!/bin/bash

# Добавляем дату к строке вывода
log_message() {
    logger "$(date '+%d.%m.%Y-%H:%M:%S') - $1"
}

# Проверим существование параметров
if [ -z "$LOG_FILE" ] || [ -z "$KEYWORD" ]; then
    log_message "ОШИБКА: LOG_FILE или KEYWORD не заданы"
    exit 1
fi

# Проверим существования файла лога
if [ ! -f "$LOG_FILE" ]; then
    log_message "ОШИБКА: Файл лога $LOG_FILE не найден"
    exit 1
fi

# Поиск ключевого слова
matches=$(grep -c "$KEYWORD" "$LOG_FILE" 2>/dev/null)

if [ "$matches" -gt 0 ]; then
    log_message "НАЙДЕНО: $matches вхождений ключевого слова '$KEYWORD' в $LOG_FILE"
    exit 0
else
    log_message "Ключевое слово '$KEYWORD' не найдено"
    exit 0
fi