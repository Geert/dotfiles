Scan de dotfiles op deze machine en voeg waardevolle configuratie toe aan de dotfiles repo. Werk volledig autonoom.

## Stap 1: Zorg dat de dotfiles repo aanwezig is

Controleer of `~/code/dotfiles` bestaat:
- Zo nee: `git clone git@github.com:Geert/dotfiles.git ~/code/dotfiles`
- Zo ja: `git -C ~/code/dotfiles pull`

## Stap 2: Scan kandidaat-bestanden

Lees de volgende bestanden als ze bestaan:
- `~/.gitconfig`
- `~/.gitignore_global` / `~/.config/git/ignore`
- `~/.zshrc`
- `~/.zprofile`
- `~/.bashrc`
- `~/.bash_profile`
- `~/.ssh/config` (alleen het config bestand, nooit keys)
- `~/.rubocop.yml`
- `~/.gemrc`
- `~/.irbrc`
- `~/.pryrc`
- `~/.npmrc` (alleen als er geen auth tokens in staan)
- `~/.config/gh/config.yml` (GitHub CLI config, zonder tokens)

## Stap 3: Beoordeel elk bestand

Per bestand bepaal je zelf:

**Voeg toe als:**
- Het persoonlijke voorkeuren/aliases/instellingen bevat die op elke machine nuttig zijn
- Het geen secrets, tokens, wachtwoorden of API keys bevat
- Het niet machine-specifiek is (geen hardcoded hostnames of absolute paden die machine-specifiek zijn)

**Sla over als:**
- Er tokens, wachtwoorden, of API keys in staan (ook als ze omschreven zijn als `GITHUB_TOKEN`, `NPM_TOKEN`, etc.)
- Het puur machine-specifiek is en nergens anders bruikbaar
- Het al in de dotfiles repo staat

**Anonimiseer als nodig:**
- Verwijder of vervang machine-specifieke waarden door placeholders
- Verwijder `[credential]` secties uit gitconfig die tokens opslaan

## Stap 4: Voeg toe aan dotfiles repo

Voor elk bestand dat je toevoegt:
1. Kopieer naar `~/code/dotfiles/` met dezelfde relatieve pad-structuur
   - `~/.gitconfig` → `~/code/dotfiles/gitconfig` (zonder punt, conventie)
   - `~/.zshrc` → `~/code/dotfiles/zshrc`
   - `~/.ssh/config` → `~/code/dotfiles/ssh/config`
2. Maak een symlink aan: `safe_link` patroon uit install.sh volgen

## Stap 5: Update install.sh

Voeg voor elk nieuw bestand een `safe_link` regel toe aan `install.sh` in het juiste sectioblok. Gebruik hetzelfde patroon als de bestaande regels. Maak nieuwe secties aan als dat logisch is (bijv. `# ── Git ──`, `# ── Shell ──`, `# ── SSH ──`).

## Stap 6: Update README.md

Voeg de nieuwe bestanden toe aan de tabel in README.md.

## Stap 7: Commit en push

```bash
cd ~/code/dotfiles
git add .
git commit -m "Add dotfiles from $(hostname): [bestandsnamen]"
git push
```

## Stap 8: Rapporteer

Geef een overzicht van:
- Welke bestanden zijn toegevoegd (en waarom)
- Welke bestanden zijn overgeslagen (en waarom)
- Welke aanpassingen je hebt gemaakt (bijv. verwijderde tokens)
