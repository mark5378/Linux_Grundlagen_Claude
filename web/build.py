#!/usr/bin/env python3
"""Baut die Webseite (site/index.html) aus Lektionen, Quizfragen und Übungen.

Aufruf:  python3 web/build.py            → schreibt site/index.html
Keine Abhängigkeiten außer Python 3.8+.
"""
import html
import json
import re
import sys
from pathlib import Path

BASIS = Path(__file__).resolve().parent.parent
ZIEL = BASIS / "site" / "index.html"
VORLAGE = BASIS / "web" / "vorlage.html"


# ---------------------------------------------------------------- Markdown
def inline(text: str) -> str:
    """Inline-Markdown: `code`, **fett**, *kursiv*, [Link](url), &nbsp;."""
    teile = re.split(r"(`[^`]+`)", text)
    aus = []
    for teil in teile:
        if teil.startswith("`") and teil.endswith("`") and len(teil) > 1:
            aus.append("<code>" + html.escape(teil[1:-1].replace("\\|", "|")) + "</code>")
            continue
        t = html.escape(teil, quote=False).replace("&amp;nbsp;", "&nbsp;")
        t = t.replace("\\|", "|")
        t = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)",
                   lambda m: f'<a href="{m.group(2)}" rel="noopener" target="_blank">{m.group(1)}</a>', t)
        t = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", t)
        t = re.sub(r"(?<![\w*])\*([^*\s][^*]*)\*(?![\w*])", r"<em>\1</em>", t)
        aus.append(t)
    return "".join(aus)


def zellen(zeile: str):
    zeile = zeile.strip()
    if zeile.startswith("|"):
        zeile = zeile[1:]
    if zeile.endswith("|") and not zeile.endswith("\\|"):
        zeile = zeile[:-1]
    # an unmaskierten | trennen, aber nicht innerhalb von `code`
    teile, aktuell, im_code, i = [], "", False, 0
    while i < len(zeile):
        z = zeile[i]
        if z == "`":
            im_code = not im_code
        if z == "\\" and i + 1 < len(zeile) and zeile[i + 1] == "|":
            aktuell += "\\|"
            i += 2
            continue
        if z == "|" and not im_code:
            teile.append(aktuell.strip())
            aktuell = ""
        else:
            aktuell += z
        i += 1
    teile.append(aktuell.strip())
    return teile


def slug(text: str) -> str:
    t = re.sub(r"<[^>]+>", "", text).lower()
    t = t.translate(str.maketrans({"ä": "ae", "ö": "oe", "ü": "ue", "ß": "ss"}))
    return re.sub(r"[^a-z0-9]+", "-", t).strip("-")


def markdown(md: str, praefix: str = "") -> str:
    zeilen = md.split("\n")
    aus, i = [], 0
    while i < len(zeilen):
        z = zeilen[i]
        if z.startswith("```"):
            sprache = z[3:].strip()
            code = []
            i += 1
            while i < len(zeilen) and not zeilen[i].startswith("```"):
                code.append(zeilen[i])
                i += 1
            i += 1
            klasse = f' data-lang="{html.escape(sprache)}"' if sprache else ""
            aus.append(f'<div class="code"{klasse}><pre><code>{html.escape(chr(10).join(code))}</code></pre>'
                       '<button class="kopieren" type="button">Kopieren</button></div>')
            continue
        m = re.match(r"^(#{1,4})\s+(.*)$", z)
        if m:
            ebene, text = len(m.group(1)), inline(m.group(2))
            aus.append(f'<h{ebene} id="{praefix}{slug(text)}">{text}</h{ebene}>')
            i += 1
            continue
        if re.match(r"^---+\s*$", z):
            aus.append("<hr>")
            i += 1
            continue
        if z.startswith("|") and i + 1 < len(zeilen) and re.match(r"^\|?\s*:?-{3,}", zeilen[i + 1]):
            kopf = zellen(z)
            i += 2
            reihen = []
            while i < len(zeilen) and zeilen[i].startswith("|"):
                reihen.append(zellen(zeilen[i]))
                i += 1
            t = "<div class=\"tabelle\"><table><thead><tr>" + "".join(f"<th>{inline(k)}</th>" for k in kopf) + "</tr></thead><tbody>"
            for r in reihen:
                t += "<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>"
            aus.append(t + "</tbody></table></div>")
            continue
        if z.startswith(">"):
            block = []
            while i < len(zeilen) and zeilen[i].startswith(">"):
                block.append(zeilen[i].lstrip(">").strip())
                i += 1
            aus.append("<blockquote>" + markdown("\n".join(block), praefix) + "</blockquote>")
            continue
        if re.match(r"^\s*[-*]\s+", z):
            punkte = []
            while i < len(zeilen) and re.match(r"^\s*[-*]\s+", zeilen[i]):
                punkte.append(re.sub(r"^\s*[-*]\s+", "", zeilen[i]))
                i += 1
            aus.append("<ul>" + "".join(f"<li>{inline(p)}</li>" for p in punkte) + "</ul>")
            continue
        m = re.match(r"^\s*(\d+)\.\s+", z)
        if m:
            start = int(m.group(1))
            punkte = []
            while i < len(zeilen) and re.match(r"^\s*\d+\.\s+", zeilen[i]):
                punkte.append(re.sub(r"^\s*\d+\.\s+", "", zeilen[i]))
                i += 1
            attr = f' start="{start}"' if start != 1 else ""
            aus.append(f"<ol{attr}>" + "".join(f"<li>{inline(p)}</li>" for p in punkte) + "</ol>")
            continue
        if not z.strip():
            i += 1
            continue
        absatz = []
        while i < len(zeilen) and zeilen[i].strip() and not re.match(r"^(#{1,4}\s|```|\||>|\s*[-*]\s|\s*\d+\.\s|---)", zeilen[i]):
            absatz.append(zeilen[i].strip())
            i += 1
        if absatz:
            aus.append("<p>" + inline(" ".join(absatz)) + "</p>")
        else:
            i += 1
    return "\n".join(aus)


# ---------------------------------------------------------------- Inhalte
def lektionen():
    liste = []
    for datei in sorted((BASIS / "lektionen").glob("[0-9][0-9]-*.md")):
        md = datei.read_text(encoding="utf-8")
        # Abschluss-Zeile mit Terminal-Befehlen entfernen – die Seite hat eigene Buttons
        md = re.sub(r"\n---\s*\n+✅.*\Z", "\n", md, flags=re.S)
        erste, _, rest = md.partition("\n")
        titel = re.sub(r"^#\s*\d+\s*[–-]\s*", "", erste).strip()
        nr = datei.name[:2]
        uebungen = sorted(set(re.findall(r"uebung\.sh start (\d+)", datei.read_text(encoding="utf-8"))))
        abschnitte = [inline(h) for h in re.findall(r"^##\s+(.*)$", rest, flags=re.M)]
        liste.append({"nr": nr, "titel": titel, "html": markdown(rest, f"l{nr}-"),
                      "abschnitte": abschnitte, "uebungen": [u.zfill(2) for u in uebungen]})
    return liste


def normalisiere(s: str) -> str:
    return " ".join(s.split())


def fragen():
    themen = []
    for datei in sorted((BASIS / "quiz" / "fragen").glob("*.txt")):
        titel, liste, block = None, [], {}

        def speichern():
            if block.get("F") and block.get("L"):
                liste.append({"f": block["F"], "o": block.get("O", []), "l": block["L"], "e": block.get("E", "")})

        for zeile in datei.read_text(encoding="utf-8").split("\n") + [""]:
            zeile = zeile.rstrip("\r")
            if zeile.startswith("#"):
                if titel is None:
                    titel = zeile.lstrip("#").strip()
                continue
            if not zeile.strip():
                speichern()
                block = {}
                continue
            k, _, v = zeile.partition(":")
            v = normalisiere(v)
            if k == "F":
                block["F"] = v
            elif k in "ABCD" and len(k) == 1:
                block.setdefault("O", []).append([k, v])
            elif k == "L":
                block.setdefault("L", []).append(v)
            elif k == "E":
                block["E"] = v
        themen.append({"nr": datei.name[:2], "titel": titel or datei.stem, "fragen": liste})
    return themen


def uebungen():
    liste = []
    for ordner in sorted((BASIS / "uebungen").glob("[0-9][0-9]-*/")):
        md = (ordner / "aufgabe.md").read_text(encoding="utf-8")
        erste, _, rest = md.partition("\n")
        liste.append({
            "nr": ordner.name[:2], "name": ordner.name,
            "titel": erste.lstrip("#").strip(),
            "html": markdown(rest, f"u{ordner.name[:2]}-"),
            "hinweis": (ordner / "hinweis.txt").read_text(encoding="utf-8").strip(),
        })
    return liste


def main():
    daten = {"lektionen": lektionen(), "themen": fragen(), "uebungen": uebungen()}
    anzahl = sum(len(t["fragen"]) for t in daten["themen"])
    roh = json.dumps(daten, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    seite = VORLAGE.read_text(encoding="utf-8").replace("/*__DATEN__*/null", roh)
    ZIEL.parent.mkdir(parents=True, exist_ok=True)
    ZIEL.write_text(seite, encoding="utf-8")
    print(f"{ZIEL.relative_to(BASIS)}: {len(daten['lektionen'])} Lektionen, {anzahl} Fragen, "
          f"{len(daten['uebungen'])} Übungen, {len(seite) // 1024} KB")


if __name__ == "__main__":
    sys.exit(main())
