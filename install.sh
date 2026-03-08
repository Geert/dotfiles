#!/usr/bin/env bash
# AppFabriek dotfiles installer
# Safe to run on machines with existing dotfiles — backs up before symlinking.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

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

# ── AppFabriek Rails Template ─────────────────────────────────────────────────

echo "→ AppFabriek Rails Template..."
if [ -d "$HOME/code/appfabriek-rails-template" ]; then
  git -C "$HOME/code/appfabriek-rails-template" pull --quiet
  echo "  ✓ Updated existing clone"
else
  mkdir -p "$HOME/code"
  git clone git@github.com:Geert/appfabriek-rails-template.git "$HOME/code/appfabriek-rails-template"
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
