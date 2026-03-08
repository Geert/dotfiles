Voer de volgende dotfiles setup uit op deze machine. Werk volledig autonoom zonder vragen te stellen.

## Stap 1: Dotfiles repo ophalen

Controleer of `~/code/dotfiles` al bestaat:
- Zo ja: `git -C ~/code/dotfiles pull`
- Zo nee: `git clone git@github.com:Geert/dotfiles.git ~/code/dotfiles`

## Stap 2: Zoek originele CLAUDE.md content op deze machine

Controleer de volgende bronnen in volgorde:

**A. Backup van install.sh** — run dit commando:
```bash
ls -t ~/.dotfiles-backup-*/CLAUDE.md 2>/dev/null | head -1
```
Als er een backup bestaat, lees die. Dit is de originele CLAUDE.md van vóór de dotfiles setup.

**B. Huidige ~/.claude/CLAUDE.md** — als het GEEN symlink is naar `~/code/dotfiles`:
```bash
readlink ~/.claude/CLAUDE.md
```
Als de output niet naar `~/code/dotfiles` wijst, lees dan `~/.claude/CLAUDE.md`.

**C. Geen originele content** — als er geen backup is en de symlink al naar dotfiles wijst, sla deze stap over.

## Stap 3: CLAUDE.md mergen (alleen als er originele content is gevonden)

Vergelijk de gevonden originele content met `~/code/dotfiles/.claude/CLAUDE.md`.

Bepaal zelf welke content waardevol is om toe te voegen:
- **Behoud altijd**: unieke instructies, persoonlijke voorkeuren, projectconventies die niet in de dotfiles versie staan
- **Negeer**: duplicaten, content die al beter beschreven staat in de dotfiles versie

Schrijf de gemerge versie naar `~/code/dotfiles/.claude/CLAUDE.md`.

## Stap 4: Symlinks aanmaken

```bash
ln -sf ~/code/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/code/dotfiles/.claude/commands ~/.claude/commands
```

## Stap 5: Commit en push (alleen als er iets gewijzigd is)

```bash
cd ~/code/dotfiles
git add .claude/CLAUDE.md
git diff --staged --quiet || git commit -m "Merge CLAUDE.md from $(hostname)"
git push
```

## Stap 6: AppFabriek Rails Template

Controleer of `~/code/appfabriek-rails-template` al bestaat:
- Zo ja: `git -C ~/code/appfabriek-rails-template pull`
- Zo nee: `git clone https://github.com/Geert/appfabriek-rails-template.git ~/code/appfabriek-rails-template`

## Klaar

Rapporteer kort:
- Of er een originele CLAUDE.md gevonden is (backup of bestaand bestand)
- Welke unieke content er gevonden en toegevoegd is
- Of er iets gepusht is naar GitHub
