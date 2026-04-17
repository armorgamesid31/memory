# Agent Operations Card (1-Page)

Bu kart, 4 repo ile çalışırken minimum kuralla stabil memory + MCP kullanımını verir.

## 1) Tek Kural Dosyası

- Global kural kaynağı: `GLOBAL_AGENT_RULES.md`
- Her repo içinde bu dosya bulunmalı (aynı içerik).

## 2) Namespace Standardı

- `global` -> kişisel/genel çalışma kuralları
- `repo:<name>` -> repo özel kararlar

Örnek:

```text
global
repo:billing-api
repo:web-app
repo:admin-panel
repo:worker-service
```

## 3) Session Başlangıcı (Zorunlu, 30-60 sn)

1. `GLOBAL_AGENT_RULES.md` oku.
2. `memory_recall(namespace=global)` çalıştır.
3. `memory_recall(namespace=repo:<name>)` çalıştır.

## 4) Session Sonu (Zorunlu, 20 sn)

Sadece önemli karar/lesson kaydet:

```text
memory_save(
  namespace="repo:<name>",
  title="<short decision>",
  content="<what changed + why + risk>"
)
```

Gerekirse aynı kaydın kısa versiyonunu `global` namespace'e de ekle.

## 5) Ne Memory'ye Yazılmaz

- Uzun log dump
- Geçici debug notları
- Policy dosyasında olması gereken kurallar

## 6) Ne Git Dosyasına Yazılır

- Kalıcı operasyon kuralları
- Güvenlik/uyumluluk kuralları
- MCP/context-mode kontratları

Kural değiştiyse: önce dosya güncelle, sonra memory'ye özet geç.

## 7) Günlük Hızlı Checklist

- Başta recall yapıldı mı? (`global` + `repo:<name>`)
- Çalışma sırasında namespace doğru mu?
- Sonda en az 1 kaliteli lesson/decision kaydedildi mi?

## 8) Fail-Safe

Memory bozulsa bile sistem çalışmalı:

- Otorite her zaman repo içi kural dosyalarıdır.
- Memory sadece hızlandırıcı katmandır.
