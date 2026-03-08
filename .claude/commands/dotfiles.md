Voer de volgende dotfiles setup uit op deze machine. Werk volledig autonoom zonder vragen te stellen.

## Stap 1: Dotfiles repo ophalen

Controleer of `~/code/dotfiles` al bestaat:
- Zo ja: `git -C ~/code/dotfiles pull`
- Zo nee: `git clone git@github.com:Geert/dotfiles.git ~/code/dotfiles`

## Stap 2: CLAUDE.md mergen

Lees beide bestanden:
- Bestaand op deze machine: `~/.claude/CLAUDE.md` (als het bestaat en geen symlink naar dotfiles is)
- Dotfiles versie: `~/code/dotfiles/.claude/CLAUDE.md`

Bepaal zelf welke content waardevol is:
- **Behoud altijd**: unieke project-specifieke instructies, persoonlijke voorkeuren, machine-specifieke paden die niet in de dotfiles versie staan
- **Negeer**: duplicaten, verouderde content die al beter beschreven staat in de dotfiles versie, tijdelijke notities

Schrijf de gemerge versie naar `~/code/dotfiles/.claude/CLAUDE.md`.

## Stap 3: Symlinks aanmaken

```bash
# CLAUDE.md
ln -sf ~/code/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md

# Slash commands (zodat /dotfiles op elke machine beschikbaar is)
ln -sf ~/code/dotfiles/.claude/commands ~/.claude/commands
```

## Stap 4: Commit en push (alleen als er iets gewijzigd is)

```bash
cd ~/code/dotfiles
git add .claude/CLAUDE.md
git diff --staged --quiet || git commit -m "Merge CLAUDE.md from $(hostname)"
git push
```

## Stap 5: AppFabriek Rails Template

Controleer of `~/code/appfabriek-rails-template` al bestaat:
- Zo ja: `git -C ~/code/appfabriek-rails-template pull`
- Zo nee: `git clone git@github.com:Geert/appfabriek-rails-template.git ~/code/appfabriek-rails-template`

## Klaar

Rapporteer kort wat er gedaan is: welke bestanden gemerged, wat er uniek was op deze machine, welke symlinks aangemaakt.
