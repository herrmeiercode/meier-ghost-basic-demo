# Meier Ghost Basic – statische Demo

Dieses Repository veröffentlicht eine statische Demo des kostenlosen Ghost-Themes **Meier Ghost Basic** über GitHub Pages.

Geplante Demo-URL: https://herrmeiercode.github.io/meier-ghost-basic-demo/

## Prinzip

Ghost läuft nur lokal auf dem eigenen Rechner. Das Theme und die Demo-Inhalte werden dort gepflegt. Das Skript `publish-demo.ps1` erzeugt aus der lokalen Ghost-Seite eine statische Kopie im Ordner `docs`. Nach dem Push veröffentlicht GitHub Pages diesen Ordner automatisch.

## Einmalige Voraussetzungen unter Windows

1. Node.js LTS installieren.
2. Git installieren und bei GitHub anmelden.
3. Ghost CLI installieren: `npm install -g ghost-cli`
4. Wget installieren: `winget install JernejSimoncic.Wget`
5. Einen leeren Ordner für Ghost erstellen und darin installieren:

   ```powershell
   mkdir C:\Ghost-Demos\meier-basic
   cd C:\Ghost-Demos\meier-basic
   ghost install local
   ```

6. Ghost Admin unter http://localhost:2368/ghost öffnen.
7. `meier-ghost-basic.zip` hochladen, aktivieren und die Demo-Inhalte anlegen.
8. Dieses Repository klonen:

   ```powershell
   cd C:\Ghost-Demos
   git clone https://github.com/herrmeiercode/meier-ghost-basic-demo.git
   cd meier-ghost-basic-demo
   ```

## Demo veröffentlichen

Ghost muss lokal laufen. Falls nötig: `ghost start`

Danach im geklonten Demo-Repository:

```powershell
.\publish-demo.ps1 -Push
```

Das Skript exportiert die lokale Seite, prüft auf verbliebene Localhost-Links, erstellt einen Commit und überträgt ihn zu GitHub.

## GitHub Pages einmalig aktivieren

Unter **Settings → Pages → Build and deployment** als Quelle **GitHub Actions** auswählen. Danach übernimmt der Workflow `.github/workflows/pages.yml` jede weitere Veröffentlichung.

## Einschränkungen der statischen Demo

Layout, Navigation, Beiträge, Seiten, Tags, Autoren, responsive Darstellung und clientseitige Theme-Funktionen bleiben erhalten. Ghost Portal, Mitgliederanmeldung, Newsletterversand, Kommentare und die servergestützte Suche funktionieren statisch nicht vollständig. Diese Elemente sollten in der lokalen Demo deaktiviert oder mit einem Demo-Hinweis versehen werden.
