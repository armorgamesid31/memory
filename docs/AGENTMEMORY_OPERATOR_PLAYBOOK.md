# AGENTMEMORY Operator Playbook (TR + EN)

Bu doküman, AgentMemory + context-mode yapısını Antigravity, Cline ve Codex üzerinde aynı davranışla çalıştırmak için zorunlu operasyon standardıdır.  
This document is the operational standard for running AgentMemory + context-mode with identical behavior across Antigravity, Cline, and Codex.

## 0) Scope / Kapsam

- TR: Bu playbook runtime/config/operations odaklıdır; ürün kodu davranışını değiştirmez.
- EN: This playbook is runtime/config/operations focused; it does not change product logic.
- TR: Hedef: tek global kimlik, tek kalıcı bellek, düşük token maliyeti.
- EN: Goal: one global identity, one persistent memory, low token cost.

## 1) Global Contract (MUST)

- TR: Tüm istemciler aynı `AGENTMEMORY_URL` ve aynı `AGENTMEMORY_SECRET` kullanır.
- EN: All clients must use the same `AGENTMEMORY_URL` and `AGENTMEMORY_SECRET`.
- TR: Tüm istemcilerde iki MCP server zorunludur: `agentmemory`, `context-mode`.
- EN: Two MCP servers are mandatory on every client: `agentmemory`, `context-mode`.
- TR: `node` komutu mutlak path olmalıdır (ör: `/opt/homebrew/bin/node` veya `/usr/local/bin/node`).
- EN: `node` command must be absolute path.
- TR: `PATH` sırası deterministic olmalıdır: `node` bin -> `bun` bin -> sistem path.
- EN: `PATH` order must be deterministic: `node` bin -> `bun` bin -> system paths.
- TR: Namespace standardı: `global` ve `project:<repo>`.
- EN: Namespace standard: `global` and `project:<repo>`.

## 2) Canonical MCP Config Parity (MUST)

Parite uygulanacak dosyalar / Files to enforce parity:

- `~/.gemini/antigravity/mcp_config.json`
- `~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`
- `~/.codex/config.toml`

Her dosyada aşağıdakiler doğrulanır / Validate these in each file:

1. `agentmemory` entry exists.
2. `context-mode` entry exists.
3. `command` for Node-based server is absolute path.
4. `env.PATH` has deterministic order.
5. `AGENTMEMORY_URL` and `AGENTMEMORY_SECRET` match exactly across all clients.

## 3) Recommended Runtime Variables

TR: Secret değerlerini dokümana açık yazmayın; environment üzerinden geçin.  
EN: Never store raw secrets in docs; pass via environment.

```env
AGENTMEMORY_URL=https://mem.berkai.shop
AGENTMEMORY_SECRET=***REDACTED***
AGENTMEMORY_AUTO_COMPRESS=true
AGENTMEMORY_INJECT_CONTEXT=true
AGENTMEMORY_AUTO_TOPIC_SESSIONS=true
```

## 4) Topic-Session Automation (Sessions)

- TR: Konu başlığı açıldığında yeni topic session otomatik üretilir (`AGENTMEMORY_AUTO_TOPIC_SESSIONS=true`).
- EN: A new topic session is auto-created on topic start (`AGENTMEMORY_AUTO_TOPIC_SESSIONS=true`).
- TR: Konu başlığı standardı:
- EN: Topic header standard:

```text
## Topic: <short-title>
Namespace: project:<repo>
Objective: <one-line outcome>
```

- TR: Kişisel/kalıcı prensipler `global`, repo kararları `project:<repo>` namespace’ine yazılır.
- EN: Personal durable principles go to `global`; repo decisions go to `project:<repo>`.

## 5) Restart / Reload Sequence (MUST)

1. TR: İlgili IDE’yi tamamen kapatın (cold stop).  
   EN: Fully close each IDE (cold stop).
2. TR: Eski/orphan MCP process var mı kontrol edin, gerekirse sonlandırın.  
   EN: Check/terminate orphan MCP processes.
3. TR: IDE’yi açın, MCP listesinde iki sunucu görünürlüğünü doğrulayın (`agentmemory`, `context-mode`).  
   EN: Reopen IDE and verify both servers are listed.
4. TR: İlk oturumda kısa smoke test çalıştırın (aşağıdaki bölüm).  
   EN: Run the smoke test on first session.

## 6) Smoke Test (Cross-Client)

### A. Config integrity

- TR: JSON/TOML parse hatası olmamalı.
- EN: No JSON/TOML parse errors.
- TR: Üç configte de iki server key’i mevcut olmalı.
- EN: Both server keys must exist in all three configs.

### B. Protocol health

- TR: Her client için `initialize` ve `tools/list` iki server’da başarılı.
- EN: `initialize` and `tools/list` must succeed for both servers in each client.
- TR: Negatif test: bilinmeyen tool çağrısı structured JSON-RPC error dönmeli.
- EN: Negative test: invalid tool call must return structured JSON-RPC error.

### C. Global memory E2E

1. Client A: `memory_save` with `namespace=global` and marker text.
2. Client B/C: `memory_recall` same marker -> same record visible.
3. Client A: save `project:p` scoped record.
4. Client B/C: recall in `project:p` succeeds; recall in other namespace does not.

### D. Token-efficiency check

- TR: Büyük çıktılı bir tanı adımını `context-mode` index+query akışıyla çalıştırın.
- EN: Run one large diagnostic through `context-mode` index+query flow.
- TR: Ham dump yerine sorgu tabanlı retrieval kullanıldığını doğrulayın.
- EN: Confirm retrieval is query-based, not raw dump.

### E. Stability

- TR: Refresh/reload döngülerinden sonra stuck/orphan process kalmamalı.
- EN: No stuck/orphan processes after refresh cycles.
- TR: Son loglarda tekrarlayan “failed to stop mcp instance” olmamalı.
- EN: No recurring “failed to stop mcp instance” in recent logs.

## 7) Troubleshooting Matrix

| Symptom | Likely Cause | Fix |
|---|---|---|
| Server process running but not listed in UI | Client cache / stale MCP registry | Full IDE cold restart + clear client MCP cache |
| Listed but tools missing | Partial handshake / wrong server config key | Validate `initialize` + `tools/list`, fix server key names |
| Works in one IDE, fails in others | URL/secret mismatch | Align `AGENTMEMORY_URL` + `AGENTMEMORY_SECRET` in all clients |
| Intermittent connection failures | Non-deterministic PATH / wrong node binary | Use absolute node path + enforce PATH order |
| Sessions not splitting by topic | Auto-topic disabled or no topic header | Set `AGENTMEMORY_AUTO_TOPIC_SESSIONS=true`; use topic header standard |
| Save works, recall empty | Wrong namespace | Re-run recall with correct `global` or `project:<repo>` |
| Recurrent stop/start errors | orphan runtime processes | Kill stale MCP processes and cold restart client |

## 8) Weekly / Monthly Maintenance

### Weekly

- TR: Üç config dosyasının hash/parity kontrolü.
- EN: Hash/parity check for all three configs.
- TR: Son 7 gün error log taraması (`mcp`, `json-rpc`, `stop instance`).
- EN: Review last 7 days logs for MCP/JSON-RPC/stop errors.
- TR: `global` ve aktif proje namespace recall sanity check.
- EN: Recall sanity check for `global` and active project namespaces.

### Monthly

- TR: Node path ve PATH sırası tekrar doğrulama.
- EN: Re-validate node path and PATH order.
- TR: End-to-end A/B/C cross-client memory testini tekrar çalıştırma.
- EN: Re-run full A/B/C cross-client memory test.
- TR: Kullanılmayan/yanlış namespace kayıtlarını temizleme.
- EN: Clean stale or incorrect namespace records.

## 9) Quick Start for New Agent on New Machine

1. Clone repository.
2. Install dependencies and build:
```bash
npm install
npm run build
```
3. Set environment variables (`AGENTMEMORY_URL`, `AGENTMEMORY_SECRET`, optional topic/session flags).
4. Add/verify `agentmemory` + `context-mode` in Antigravity, Cline, Codex configs with absolute node path.
5. Cold restart clients.
6. Run smoke test sections 6A-6E.

## 10) Operator Definition of Done

- TR: Üç istemcide de iki server görünür ve `tools/list` sağlıklı.
- EN: Both servers visible and healthy (`tools/list`) in all 3 clients.
- TR: `global` save/recall A->B->C başarılı.
- EN: `global` save/recall works across A->B->C.
- TR: `project:<repo>` scope izolasyonu doğrulandı.
- EN: `project:<repo>` scope isolation verified.
- TR: Topic-session otomasyonu aktif ve test edildi.
- EN: Topic-session automation enabled and validated.
- TR: Son loglarda tekrarlayan durdurma hatası yok.
- EN: No recurring stop-instance errors in latest logs.
