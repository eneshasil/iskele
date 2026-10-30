---
name: iskele
description: Ajanlarla çalışılacak yeni bir kod projesi açar; AGENTS.md/CLAUDE.md, const, NOTES, backlog + append-only log, DECISIONS, gitignored .env ve GitHub reposunu tek komutla kurar. Kullanıcı "yeni proje aç", "proje iskeleti kur", "yeni repo başlat" dediğinde kullan.
---

# iskele

Kullanıcı yeni bir kod projesine başlamak istediğinde iskeleti bu skill ile kur.

## Adımlar

1. **Bilgileri topla.** Proje adı yoksa sor. Klasör belirtilmediyse bulunduğun klasörde aç.
   GitHub reposu varsayılan olarak private açılır; kullanıcı public isterse `--public`,
   GitHub istemezse `--no-github` kullan. Başka bir şey sorma.
2. **Çalıştır.**
   ```bash
   iskele <ad> [--dir KLASÖR] [--public] [--no-github]
   ```
   `iskele` PATH'te yoksa bu skill'in klasöründeki `scripts/iskele.sh` dosyasını çalıştır.
   GitHub adımı `gh` ister; `gh` yoksa ya da oturum açık değilse kullanıcıya
   `gh auth login` yapmasını söyle ya da `--no-github` ile devam et.
3. **Doldur.** Kullanıcının sohbette söylediği değişmez gerçekleri (amaç, teknoloji,
   kısıtlar) `const.md` dosyasına kısa maddeler halinde yaz. Söylemediği şeyi uydurma.
   Projenin dışında bir not ya da wiki bağlantısı verdiyse `AGENTS.md` içindeki
   `## Bağlam` satırına ekle. Bunu ayrı bir commit olarak at.
4. **Anlat.** Kullanıcıya kısaca hangi dosyanın ne işe yaradığını ve reponun yolunu
   (GitHub varsa bağlantısını) söyle.

Bundan sonra o projede çalışırken projenin kendi `AGENTS.md` dosyasındaki kurallara uy.
