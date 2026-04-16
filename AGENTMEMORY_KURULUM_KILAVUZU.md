# AgentMemory MCP Kurulum ve Kullanım Kılavuzu (Codex + Antigravity)

Bu doküman, AgentMemory MCP'yi **tek bir remote backend** (mem.berkai.shop) ile hem Codex hem Antigravity ortamında tutarlı çalıştırmak için hazırlanmıştır.

## 1) Mimari (özet)

- `remote-bridge.mjs` bir **stdio MCP köprüsü**dür.
- Köprü, yerel agent'tan gelen MCP çağrılarını remote REST API'ye iletir.
- Kimlik doğrulama için `C:\Users\berka\.agentmemory\.env` içindeki:
  - `III_ENGINE_URL`
  - `AGENTMEMORY_SECRET`
  kullanılır.

## 2) Yapılandırılan Dosyalar

Bu kurulumda aşağıdaki dosyalar ayarlandı:

- `C:\Users\berka\.agentmemory\.env`
- `C:\Users\berka\.codex\config.toml`
- `C:\Users\berka\.gemini\antigravity\mcp_config.json`

## 3) Kullanılan Nihai Konfig

### 3.1 AgentMemory ortam değişkenleri

`C:\Users\berka\.agentmemory\.env`

```env
III_ENGINE_URL=https://mem.berkai.shop
AGENTMEMORY_SECRET=***
III_REST_PORT=3111
AGENTMEMORY_TOOLS=all
EMBEDDING_PROVIDER=local
STANDALONE_MCP=false
```

Not:
- `III_ENGINE_URL` kesinlikle `https://` olmalı (remote-bridge bunu REST için kullanır).
- Secret değerini paylaşma/loglama.

### 3.2 Codex MCP sunucusu

`C:\Users\berka\.codex\config.toml`

```toml
[mcp_servers.agentmemory]
command = "C:\\Program Files\\nodejs\\node.exe"
args = ["c:/Users/berka/projeler/memory/dist/remote-bridge.mjs"]
```

### 3.3 Antigravity MCP sunucusu

`C:\Users\berka\.gemini\antigravity\mcp_config.json`

```json
{
  "mcpServers": {
    "agentmemory": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": ["c:/Users/berka/projeler/memory/dist/remote-bridge.mjs"]
    }
  }
}
```

## 4) Yeniden Başlatma (zorunlu)

Konfig değişikliklerinden sonra:

1. Codex oturumunu kapat/aç.
2. Antigravity uygulamasını tamamen kapatıp yeniden aç.

Aksi halde eski MCP process'i cache'de kalabilir.

## 5) Doğrulama Adımları

## 5.1 Remote API sağlık kontrolü

```powershell
$h = @{ Authorization = 'Bearer <AGENTMEMORY_SECRET>' }
Invoke-RestMethod -Method GET -Uri 'https://mem.berkai.shop/agentmemory/health' -Headers $h
```

Beklenen: `status: healthy`

## 5.2 MCP tool list endpoint doğrulaması

```powershell
$h = @{ Authorization = 'Bearer <AGENTMEMORY_SECRET>' }
Invoke-RestMethod -Method GET -Uri 'https://mem.berkai.shop/agentmemory/mcp/tools' -Headers $h
```

Beklenen: tool listesi dönmeli (`memory_*` araçları)

## 5.3 Bridge log kontrolü

```powershell
Get-Content -LiteralPath 'C:\Users\berka\.agentmemory\bridge.log' -Tail 100
```

Beklenen:
- `Bridge process started`
- `Routing to remote REST engine ...`
- `Method call: tools/list` / `tools/call`

## 6) Sık Görülen Sorunlar ve Çözüm

## 6.1 `sessions` boş, ama export'ta `memories` var

Bu her zaman kurulum hatası olmayabilir.

Sebep seçenekleri:
- Eski dönemde sadece `memory_save` kullanılmış, `session` akışı çalışmamış olabilir.
- Hook tabanlı session capture açık olmayabilir.
- Farklı namespace/proje ile arama yapılıyor olabilir.

Ne yapmalı:
1. `memory_save` ile test kaydı at.
2. Aynı terimle `memory_recall` dene.
3. `bridge.log` ve remote `/agentmemory/mcp/call` yanıtlarını kontrol et.

## 6.2 Secret hatası

Belirti:
- Bridge stderr: `AGENTMEMORY_SECRET is not set`

Çözüm:
- `C:\Users\berka\.agentmemory\.env` dosyasında secret var mı kontrol et.
- Uygulamayı yeniden başlat.

## 6.3 MCP görünmüyor

Çözüm:
- Dosya path'lerini birebir doğrula.
- Node path doğru mu kontrol et:

```powershell
& 'C:\Program Files\nodejs\node.exe' -v
```

## 7) Günlük Kullanım Akışı (öneri)

1. Görev başında `memory_smart_search` ile ilgili geçmişi çek.
2. Önemli kararları `memory_save` ile kaydet.
3. Periyodik olarak `memory_recall` / `memory_sessions` ile kontrol et.
4. Hassas veri (token, şifre) asla hafızaya bilinçsiz kaydetme.

## 8) Güvenlik Notu

Remote export çıktısında geçmişte secret benzeri içerikler görüldüyse:
- ilgili credential'ları rotate et,
- mümkünse `memory_governance_delete` ile temizle,
- bundan sonra secret'ları maskelenmiş formatta kaydet.

---

Hazırlayan notu:
Bu kurulumda Codex ve Antigravity aynı `remote-bridge.mjs` ve aynı `~/.agentmemory/.env` kaynağına bağlanacak şekilde standardize edilmiştir.

## 9) Özellikleri Nasıl Kullanırım? (Pratik)

Günlük temel akış:

1. Başlamadan önce geçmişi tara:
   - `memory_smart_search`
   - `memory_recall`
2. İş sırasında kritik kararları kaydet:
   - `memory_save`
3. İş bittiğinde durum kontrolü:
   - `memory_memories_list`
   - `memory_actions_list`
   - `memory_audit_log`

Bu kurulumda ek erişilebilir özellikler:

- `memory_memories_list`: Remote store'daki memory kayıtlarını listeler.
- `memory_actions_list`: Action/work-item kayıtlarını listeler.
- `memory_lessons_list`: Lessons kayıtlarını listeler.
- `memory_crystals_list`: Crystals kayıtlarını listeler.
- `memory_audit_log`: Audit log döker.
- `memory_export_full`: Full export JSON döker.
- `memory_profile_get`: Project profile döker (session yoksa `no_sessions` dönebilir).

Not:
- UI'de görülen tüm modüller birebir MCP tool olarak açılmayabilir.
- Bu nedenle bazı alanlar MCP gateway yerine bridge'in REST ek tool'larıyla expose edilmiştir.

## 8) Memo.berkai.shop Stabilizasyon Runbook (Direct-to-main)

- Sadece `armorgamesid31/memory` deposu kullanılır, tüm değişiklikler doğrudan `main` branch'ine push edilir.
- Push sonrası Coolify'da yalnızca `mem` (`https://mem.berkai.shop`) servisine redeploy tetiklenir.
- Her redeploy sonrası tam **120 saniye** beklenir, sonra test turu başlatılır.
- Browser doğrulaması için yalnızca `chrome-devtools-mcp` kullanılır.
- Test sekmeleri: `Dashboard`, `Graph`, `Memories`, `Timeline`, `Sessions`, `Lessons`, `Actions`, `Crystals`, `Audit`, `Activity`, `Profile`.
- Her turda:
  1. Hard refresh (`Ctrl+Shift+R`)
  2. Sekmeleri tek tek aç
  3. Console/Network hatalarını kontrol et
  4. Kritik endpoint'leri doğrula (özellikle `GET /agentmemory/graph/stats`)

### Runtime Notları

- Viewer giriş: `admin / 82841a370`
- OpenRouter model: `google/gemini-2.0-flash-001`
- Üretimde graph extraction kapalıysa `graph/stats`, `graph/query`, `graph/build` endpoint'leri fallback ile 200 dönmelidir (UI kırılmaması için).
