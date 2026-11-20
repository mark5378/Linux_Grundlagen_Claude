ln backup/notizen.txt backup/notizen_hard.txt
ln -s backup/notizen.txt notizen_link.txt
find . -xtype l -delete
echo hardlink > antwort.txt
