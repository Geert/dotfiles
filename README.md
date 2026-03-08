# AppFabriek Dotfiles

Persoonlijke ontwikkelomgeving configuratie, gesynchroniseerd via Git.

## Wat zit er in

| Bestand | Doel |
|---------|------|
| `.claude/CLAUDE.md` | Globale Claude Code instructies (Rails conventions, Fizzy als referentie) |
| `.claude/commands/dotfiles.md` | `/dotfiles` slash command — setup en merge op nieuwe machines |
| `install.sh` | Bootstrap script — maakt symlinks en kloont repos |

## Nieuwe machine opzetten

### Stap 1 — Bootstrap (eenmalig)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Geert/dotfiles/main/install.sh)
```

Dit doet:
- Kloont deze repo naar `~/code/dotfiles`
- Symlinkт `~/.claude/CLAUDE.md` → dotfiles
- Symlinkт `~/.claude/commands/` → dotfiles (maakt `/dotfiles` beschikbaar)
- Kloont `appfabriek-rails-template` naar `~/code/appfabriek-rails-template`
- Maakt backups van bestaande bestanden vóór ze worden overschreven

### Stap 2 — CLAUDE.md mergen (als je al een bestaande config hebt)

Open Claude Code en typ:

```
/dotfiles
```

Claude leest de bestaande `~/.claude/CLAUDE.md` op de machine, bepaalt wat unieke en waardevolle content is, merget die intelligent in de dotfiles versie, en commit + pusht naar GitHub.

### Stap 3 — Klaar

Op machines die al zijn opgezet: `git -C ~/code/dotfiles pull` om de laatste versie te krijgen.

---

## Bestaande machine updaten

```bash
git -C ~/code/dotfiles pull
```

Symlinks wijzen al naar de dotfiles — na een pull zijn alle wijzigingen direct actief.

---

## CLAUDE.md aanpassen

De globale Claude Code configuratie staat in `.claude/CLAUDE.md`. Wijzigingen maken:

```bash
# Bewerk het bestand (de symlink zorgt dat wijzigingen direct in dotfiles terechtkomen)
code ~/.claude/CLAUDE.md

# Commit en push
cd ~/code/dotfiles
git commit -am "Update Claude conventions: ..."
git push
```

Op andere machines: `git -C ~/code/dotfiles pull` — geen verdere actie nodig.

---

## Rails projecten starten

```bash
rails new myapp -m ~/code/appfabriek-rails-template/template.rb
```

Zie [appfabriek-rails-template](https://github.com/Geert/appfabriek-rails-template) voor wat de template opzet.

---

## Architectuur

```
~/.claude/CLAUDE.md          →  symlink  →  ~/code/dotfiles/.claude/CLAUDE.md
~/.claude/commands/          →  symlink  →  ~/code/dotfiles/.claude/commands/
~/code/dotfiles/             →  git remote  →  github.com/Geert/dotfiles
~/code/appfabriek-rails-template/  →  git remote  →  github.com/Geert/appfabriek-rails-template
```

Het `/dotfiles` slash command is beschikbaar in elke Claude Code sessie op elke machine waar `install.sh` is gedraaid.
