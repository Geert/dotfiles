#!/usr/bin/env bash
# AppFabriek dotfiles installer
# Safe to run on machines with existing dotfiles — backs up before symlinking.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Geert/dotfiles/main/install.sh)
#   ~/code/dotfiles/install.sh

set -e

DOTFILES_REPO="https://github.com/Geert/dotfiles.git"
DOTFILES_DIR="$HOME/code/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ── Bootstrap: clone dotfiles repo als dat nog niet gedaan is ─────────────────
# Wanneer dit script via curl pipe draait, is BASH_SOURCE[0] een /dev/fd pad.
# In dat geval klonen we de repo eerst en voeren dan de lokale versie uit.

if [[ "${BASH_SOURCE[0]}" == /dev/fd/* ]] || [[ "${BASH_SOURCE[0]}" == /proc/* ]]; then
  if [ -d "$DOTFILES_DIR" ]; then
    echo "→ Dotfiles updaten..."
    git -C "$DOTFILES_DIR" pull --quiet
    echo "  ✓ Bijgewerkt"
  else
    echo "→ Dotfiles clonen..."
    mkdir -p "$HOME/code"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    echo "  ✓ Gecloned naar $DOTFILES_DIR"
  fi
  echo ""
  exec bash "$DOTFILES_DIR/install.sh"
fi

# ── GitHub SSH host key ───────────────────────────────────────────────────────
# GitHub rotated their RSA key in March 2023. Fix stale known_hosts entries.

if ssh-keygen -F github.com 2>/dev/null | grep -q "RSA"; then
  if ! ssh-keygen -l -f <(ssh-keygen -F github.com 2>/dev/null) 2>/dev/null | grep -q "uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s"; then
    echo "→ Oud GitHub SSH host key gevonden — wordt bijgewerkt..."
    ssh-keygen -R github.com 2>/dev/null
    ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
    echo "  ✓ GitHub SSH host key bijgewerkt"
  fi
elif ! ssh-keygen -F github.com 2>/dev/null | grep -q "github.com"; then
  echo "→ GitHub SSH host key toevoegen..."
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
  echo "  ✓ GitHub SSH host key toegevoegd"
fi

# ── Helpers ───────────────────────────────────────────────────────────────────

safe_link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      echo "  ✓ $dest (already linked)"
      return
    fi
    # Symlink pointing elsewhere — back it up
    mkdir -p "$BACKUP_DIR"
    cp -P "$dest" "$BACKUP_DIR/"
    echo "  ⚠ Backed up existing symlink: $dest → $BACKUP_DIR/"
  elif [ -f "$dest" ]; then
    # Real file exists — show diff and back it up
    mkdir -p "$BACKUP_DIR"
    cp "$dest" "$BACKUP_DIR/"
    echo ""
    echo "  ⚠ Existing file found: $dest"
    echo "  ⚠ Backed up to: $BACKUP_DIR/$(basename "$dest")"
    echo ""
    echo "  Differences (existing → dotfiles):"
    diff --color=always "$dest" "$src" | head -40 || true
    echo ""
    read -p "  Overwrite with dotfiles version? [y/N] " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "  → Skipped. Merge manually:"
      echo "     diff $dest $src"
      echo "     # Edit $src, then re-run install.sh"
      return
    fi
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
  echo "  ✓ $dest → dotfiles"
}

# ── Claude Code ───────────────────────────────────────────────────────────────

echo "→ Setting up Claude Code configuration..."
mkdir -p "$HOME/.claude"
safe_link "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# Slash commands — echte directory met per-bestand symlinks
# (Claude Code volgt geen directory-symlinks bij het ontdekken van commands)
if [ -L "$HOME/.claude/commands" ]; then
  echo "  ⚠ ~/.claude/commands is een symlink — wordt omgezet naar echte directory..."
  rm "$HOME/.claude/commands"
fi
mkdir -p "$HOME/.claude/commands"
for cmd_file in "$DOTFILES_DIR/.claude/commands"/*.md; do
  cmd_name="$(basename "$cmd_file")"
  dest="$HOME/.claude/commands/$cmd_name"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$cmd_file" ]; then
    echo "  ✓ ~/.claude/commands/$cmd_name (already linked)"
  else
    ln -sf "$cmd_file" "$dest"
    echo "  ✓ ~/.claude/commands/$cmd_name → dotfiles"
  fi
done

# ── AppFabriek Rails Template ─────────────────────────────────────────────────

echo "→ AppFabriek Rails Template..."
if [ -d "$HOME/code/appfabriek-rails-template" ]; then
  git -C "$HOME/code/appfabriek-rails-template" pull --quiet
  echo "  ✓ Updated existing clone"
else
  mkdir -p "$HOME/code"
  git clone https://github.com/Geert/appfabriek-rails-template.git "$HOME/code/appfabriek-rails-template"
  echo "  ✓ Cloned appfabriek-rails-template"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done!"
if [ -d "$BACKUP_DIR" ]; then
  echo "Backups saved in: $BACKUP_DIR"
fi
echo ""
echo "New Rails apps: rails new myapp -m ~/code/appfabriek-rails-template/template.rb"
