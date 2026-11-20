# Hardlinks und symbolische Links

In `backup` liegt die Datei `notizen.txt`. Außerdem gibt es im Übungsordner ein paar alte Verknüpfungen.

1. Erstelle im Ordner `backup` einen **Hardlink** `notizen_hard.txt` auf `backup/notizen.txt`.
2. Erstelle direkt im Übungsordner einen **symbolischen Link** `notizen_link.txt`, der auf `backup/notizen.txt` zeigt.
3. Im Übungsordner gibt es symbolische Links, deren Ziel nicht mehr existiert („kaputte Links“). Finde und lösche **nur** diese.
4. Beantworte in `antwort.txt` mit einem Wort (`hardlink` oder `symlink`): Welche der beiden Verknüpfungen funktioniert noch, wenn `backup/notizen.txt` gelöscht wird?

Nützliche Befehle: `ln`, `ln -s`, `ls -li`, `stat`, `find -xtype l`

> Ein Hardlink ist ein zweiter Name für dieselben Daten (gleiche Inode-Nummer). Ein Symlink ist eine kleine Datei, die nur einen Pfad enthält.
