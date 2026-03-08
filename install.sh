#!/usr/bin/env bash
# AppFabriek dotfiles installer
# Safe to run on machines with existing dotfiles — backs up before symlinking.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ── GitHub SSH host key ───────────────────────────────────────────────────────
# GitHub rotated their RSA key in March 2023. Fix stale known_hosts entries.

if ssh-keygen -F github.com 2>/dev/null | grep -q "RSA"; then
  CURRENT=$(ssh-keygen -F github.com 2>/dev/null | grep -A1 "github.com" | tail -1)
  # Known good GitHub RSA fingerprint (post-March 2023 rotation)
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
    # Already a symlink — check if it already points to dotfiles
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
safe_link "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# Slash commands (maakt /dotfiles beschikbaar in Claude Code)
mkdir -p "$HOME/.claude"
if [ -L "$HOME/.claude/commands" ]; then
  echo "  ✓ ~/.claude/commands (already linked)"
elif [ -d "$HOME/.claude/commands" ] && [ ! -L "$HOME/.claude/commands" ]; then
  echo "  ⚠ ~/.claude/commands bestaat al als directory — handmatig samenvoegen nodig"
  echo "     ls $HOME/.claude/commands"
else
  ln -sf "$DOTFILES_DIR/.claude/commands" "$HOME/.claude/commands"
  echo "  ✓ ~/.claude/commands → dotfiles (slash commands beschikbaar)"
fi

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
