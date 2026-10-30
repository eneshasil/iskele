# Ajan için kurulum talimatı

Bu dosyayı kullanıcının ajanı okur ve uygular. Kullanıcı yalnız şunu söyler:

> https://github.com/eneshasil/iskele reposundaki KURULUM.md dosyasını oku ve uygula.

## Adımlar

1. **Ön koşul:** `git` ve `bash` gerekli (macOS, Linux ya da Windows'ta WSL).
   `gh` isteğe bağlı; yalnız GitHub reposu açmak için.
2. **İndir ya da güncelle:**
   ```bash
   if [ -d ~/.iskele/.git ]; then git -C ~/.iskele pull --ff-only
   else git clone https://github.com/eneshasil/iskele ~/.iskele; fi
   ```
3. **İncele ve kur:** `~/.iskele/install.sh` dosyasını oku, ne yaptığını kullanıcıya bir
   cümleyle söyle, sonra çalıştır:
   ```bash
   bash ~/.iskele/install.sh
   ```
   Kurulum `~/.claude/skills/iskele`, `~/.agents/skills/iskele` ve `~/.local/bin/iskele`
   yollarına sembolik bağ kurar; başka bir dosyaya dokunmaz.
4. **Doğrula:** `iskele --help` çıktı vermeli. Çıktı yoksa ve kurulum PATH uyarısı verdiyse,
   kullanıcıya uyarıdaki satırı kabuk dosyasına eklemesini öner; kendin ekleme.
5. **Bildir:** Kullanıcıya kurulumun bittiğini ve kullanımı söyle: yeni bir projeye
   başlarken "iskele ile yeni proje aç: <ad>" demesi yeterli. Kullanıcı istemedikçe
   proje açma.

Kaldırmak için: `bash ~/.iskele/install.sh --uninstall` ve `rm -rf ~/.iskele`.
