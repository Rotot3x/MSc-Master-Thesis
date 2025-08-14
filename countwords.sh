#!/bin/bash

# Hinweis zur Installation von detex
echo "Um dieses Skript zu nutzen muss detex auf dem Rechner installiert sein"
echo "Unter macOS kann es mit dem folgenden Befehl installiert werden: brew install opendetex"

# Vorherige temporäre Dateien löschen
rm combined_text.txt 2> /dev/null
rm wordcounts.txt 2> /dev/null

# Datei mit Kapitelübersicht
INCLUDE_FILE="skripte/kapitelUebersicht.tex"

# Funktionen zum Einlesen von Dateien und Zählen der Wörter
process_file() {
    local file=$1
    local text_file="temp_text.txt"
    detex "$file" > "$text_file"
    local word_count=$(wc -w < "$text_file")
    printf "%10d  %-100s\n" "$word_count" "$(basename "$file")" >> wordcounts.txt
    cat "$text_file" >> combined_text.txt
    rm "$text_file"
}

# Kapitel aus der Datei kapitelUebersicht.tex einlesen und verarbeiten
process_input_files() {
    local input_file=$1

    while IFS= read -r line; do
        if [[ $line =~ \\input\{(.+)\} ]]; then
            local input_path=${BASH_REMATCH[1]}
            process_file "$input_path"
        fi
    done < "$input_file"
}

# Hauptdatei einlesen und Wörter zählen
process_input_files "$INCLUDE_FILE"

# Anzahl der Wörter insgesamt und pro Kapitel ausgeben
echo
printf "%10s  %-100s\n" "Wörter" "Kapitel"
printf "%10s  %-100s\n" "----------" "----------------------------------------------------------------------------------------------------"
cat wordcounts.txt

echo
echo "Gesamtanzahl der Wörter von 00_Einleitung.tex bis 00_Kritische Reflexion.tex:"
wc -w combined_text.txt | awk '{printf "%d Wörter\n", $1}'

# Temporäre Dateien löschen
rm combined_text.txt 2> /dev/null
rm wordcounts.txt 2> /dev/null
