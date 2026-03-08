#!/usr/bin/env bash
# AppFabriek dotfiles installer
# Run on a fresh machine to set up Claude Code configuration

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "→ Setting up Claude Code configuration..."
mkdir -p ~/.claude
ln -sf "$DOTFILES_DIR/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
echo "  ✓ ~/.claude/CLAUDE.md → dotfiles/.claude/CLAUDE.md"

echo "→ Cloning AppFabriek Rails Template..."
if [ -d "$HOME/code/appfabriek-rails-template" ]; then
  git -C "$HOME/code/appfabriek-rails-template" pull --quiet
  echo "  ✓ Updated existing clone"
else
  mkdir -p "$HOME/code"
  git clone git@github.com:Geert/appfabriek-rails-template.git "$HOME/code/appfabriek-rails-template"
  echo "  ✓ Cloned appfabriek-rails-template"
fi

echo ""
echo "Done! New Rails apps:"
echo "  rails new myapp -m ~/code/appfabriek-rails-template/template.rb"
