#!/usr/bin/env bash
# iskele: ajanlarla çalışılacak yeni bir kod projesinin iskeleti.
# AGENTS/CLAUDE, NOTES, backlog + log, const, DECISIONS, gitignored .env, GitHub reposu.
# https://github.com/eneshasil/iskele
#
# Kullanım:
#   iskele <ad> [--dir KLASÖR] [--public] [--no-github]
#
#   --dir        Ana klasör (varsayılan: bulunduğun klasör)
#   --public     GitHub reposunu public aç (varsayılan: private)
#   --no-github  Yalnız yerel git; GitHub reposu açma
set -euo pipefail

usage() { sed -n '6,11p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

name="" ; parent="$PWD" ; visibility="--private" ; github=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) parent="${2:?--dir bir klasör ister}"; shift 2 ;;
    --public) visibility="--public"; shift ;;
    --no-github) github=0; shift ;;
    -h|--help) usage ;;
    -*) echo "Bilinmeyen seçenek: $1" >&2; usage 1 ;;
    *) [[ -z "$name" ]] || { echo "Tek proje adı ver." >&2; exit 1; }; name="$1"; shift ;;
  esac
done
[[ -n "$name" ]] || usage 1

dir="$parent/$name"
if [[ -e "$dir" ]] && [[ -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
  echo "Hata: $dir zaten var ve boş değil; üzerine yazmıyorum." >&2
  exit 1
fi
if (( github )); then
  command -v gh >/dev/null || { echo "Hata: gh yok. --no-github kullan ya da 'brew install gh'." >&2; exit 1; }
  gh auth status >/dev/null 2>&1 || { echo "Hata: gh oturumu yok. Önce 'gh auth login'." >&2; exit 1; }
fi

today="$(date +%Y-%m-%d)"
mkdir -p "$dir"
cd "$dir"

# Tek kaynak AGENTS.md; CLAUDE.md yalnız onu içe aktarır, böylece iki dosya sapamaz.
cat > AGENTS.md <<EOF
# $name

Bu dosya ajan talimatlarının tek kaynağıdır. CLAUDE.md yalnız bunu içe aktarır;
değişiklik yalnız burada yapılır.

## Oturum başında oku
- @const.md — değişmez gerçekler. kullanıcının açık onayı olmadan değiştirme.
- @backlog.md — açık ve yarıda kalmış işler.
- DECISIONS.md — bir kararı sorgulamadan önce gerekçesine bak.
- backlog-log.md yalnız gerektiğinde okunur (son satırlar ya da grep); tamamını yükleme.
- reports/ — araştırma ve keşif raporları. Bir konuya başlamadan ilgili raporu ara (ls/grep);
  varsa aynı keşfi baştan yapma.

## Çalışma kuralları
- **Önce yaz:** Bir işe başlarken backlog.md'ye \`[devam]\` satırı ekle; iş bitince satırı sil
  ve backlog-log.md'nin sonuna bir satır ekle. Böylece hiçbir iş sessizce yarıda kalmaz.
- **backlog-log.md append-only:** yalnız sona ekle; eski satırları düzenleme ya da silme.
- **NOTES.md:** fikirleşmede ham dump \`## Taslak\` bölümüne gider. kullanıcı "tamam" deyince
  temize çekilip \`## Kesinleşmiş\` bölümüne yazılır, taslak temizlenir.
- **Karar:** "X yerine Y" seçimi yapılınca DECISIONS.md'ye tarih, karar, alternatif ve gerekçe yaz.
- **Sırlar:** .env commit'lenmez. Yeni değişken eklenirse .env.example'a boş değerle ekle.

## Alt agent'larla çalışma
- **Şef işçilik yapmaz:** Bağımsız iki ya da daha fazla parça varsa ya da büyük bir okuma
  (log, çok dosya) gerekiyorsa işi alt agent'lara dağıt; sen planla, birleştir, doğrula.
  Küçük ya da sıralı işte alt agent açma.
- **Brief:** Her alt agent'a hedefi, dokunabileceği dosya/klasörleri, dokunmaması gerekenleri
  ve teslim biçimini (kısa rapor) yaz. "Nasıl"ı serbest bırak; rol/karakter promptu yazma.
- **Sahiplik:** Aynı dosyaya iki agent yollanmaz. Büyük paralel işte her agent ayrı worktree'de çalışır;
  birleştirmeyi şef yapar.
- **Commit:** Alt agent yalnız kendi branch'ine ya da worktree'sine, anlamlı ilerlemede commit atar.
  Ortak çalışma dizininde commit, \`git reset\`, \`git checkout\` ya da \`git stash\` yapmaz.
- **Kayıt:** Alt agent bulgusunu backlog-log.md'nin sonuna kendi adıyla ekler;
  backlog.md'yi yalnız şef günceller.
- **Rapor:** Araştırma ya da keşif yapan alt agent bulgusunu \`reports/YYYY-MM-DD-konu.md\`
  dosyasına yazar; şefe yalnız kısa özet ve dosya yolunu döner. Şefin bağlamı böyle dolmaz.
- **Doğrulama:** Kritik işte ayrı bir denetçi agent sonucu sıfır bağlamla kontrol eder.
  Yeni test, düzeltme geri alınınca kırılmalı; kırılmıyorsa test sahtedir.
- **Tekrarlayan sorun:** Aynı hata iki kez çıkarsa kuralı bu dosyaya ekle.

## Bağlam
- Stratejik bağlam: (varsa projenin dışındaki not/wiki bağlantısı)
EOF

printf '@AGENTS.md\n' > CLAUDE.md

cat > const.md <<EOF
# Değişmez gerçekler

Projenin tartışmaya kapalı gerçekleri. Kısa tut: her oturum yüklenir.
Ajan bu dosyayı kullanıcının açık onayı olmadan değiştirmez.

- Proje: $name (başlangıç: $today)
EOF

cat > NOTES.md <<'EOF'
# Notlar

## Kesinleşmiş
<!-- kullanıcı "tamam" dedikten sonra temize çekilen fikirler. -->

## Taslak
<!-- Ham dump. Oturum kopsa da kaybolmasın diye hemen buraya yazılır. -->
EOF

mkdir -p reports
cat > reports/README.md <<'EOF'
# Raporlar

Araştırma ve keşif çıktıları. Her rapor ayrı dosya: `YYYY-MM-DD-konu.md`.
Başta 3-5 satır özet, sonra ayrıntı ve kaynaklar. Eski raporlar silinmez;
geçersizleşen raporun başına `> Geçersiz: <tarih> · <neden>` satırı eklenir.
EOF

cat > backlog.md <<'EOF'
# Backlog

Açık işler. Biten satır silinir, kaydı backlog-log.md'ye düşülür.
Biçim: `- [devam|bekliyor] YYYY-MM-DD · iş · nerede kaldı / sıradaki adım`
EOF

cat > backlog-log.md <<EOF
# Backlog log

Append-only. Yalnız sona ekle. Biçim: \`- YYYY-MM-DD HH:MM · ajan · ne oldu\`

- $today $(date +%H:%M) · iskele · Proje iskeleti oluşturuldu.
EOF

cat > DECISIONS.md <<'EOF'
# Kararlar

Biçim:
## YYYY-MM-DD · Karar başlığı
- **Karar:**
- **Alternatifler:**
- **Gerekçe:**
EOF

cat > .gitignore <<'EOF'
# Sırlar
.env
.env.*
!.env.example

# İşletim sistemi / editör
.DS_Store
.vscode/
.idea/
EOF

cat > .env.example <<'EOF'
# Gerekli ortam değişkenleri; gerçek değerler .env içinde (commit'lenmez).
EOF
touch .env

printf '# %s\n' "$name" > README.md

# .gitignore ilk commit'ten önce yazıldı; .env geçmişe hiç girmez.
git init -q -b main
git add -A
if git ls-files --error-unmatch .env >/dev/null 2>&1; then
  echo "Hata: .env stage'e girdi, commit iptal." >&2; exit 1
fi
git commit -q -m "Proje iskeleti"

if (( github )); then
  gh repo create "$name" "$visibility" --source . --remote origin --push
  echo "GitHub: $(gh repo view --json url -q .url)"
fi

echo "Hazır: $dir"
