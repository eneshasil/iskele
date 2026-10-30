#!/usr/bin/env bash
# iskele kurulumu: skill'i Claude Code ve diğer ajanlara bağlar, `iskele` komutunu PATH'e koyar.
# Kopyalamaz, sembolik bağ kurar; bu yüzden `git pull` ile güncellenir.
#
# Kullanım:
#   install.sh              Kur
#   install.sh --uninstall  Kaldır
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
skill="$repo/skills/iskele"
targets=("$HOME/.claude/skills/iskele" "$HOME/.agents/skills/iskele")
bin="$HOME/.local/bin/iskele"

if [[ "${1:-}" == "--uninstall" ]]; then
  for t in "${targets[@]}" "$bin"; do
    [[ -L "$t" ]] && rm "$t" && echo "Kaldırıldı: $t"
  done
  exit 0
fi

# Var olan gerçek bir klasörün üzerine yazma; yalnız bizim bağımızı yenile.
link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "Hata: $dst zaten var ve sembolik bağ değil; elle kontrol et." >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "Bağlandı: $dst"
}

chmod +x "$skill/scripts/iskele.sh"
for t in "${targets[@]}"; do link "$skill" "$t"; done
link "$skill/scripts/iskele.sh" "$bin"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "Uyarı: ~/.local/bin PATH'te değil. Kabuk dosyana ekle:"
     echo '  export PATH="$HOME/.local/bin:$PATH"' ;;
esac

command -v gh >/dev/null || echo "Not: gh yok; GitHub adımı için 'gh' kur ya da --no-github kullan."
echo "Hazır. Deneme: iskele --help"
