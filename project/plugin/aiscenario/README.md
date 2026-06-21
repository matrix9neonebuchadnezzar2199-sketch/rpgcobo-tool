# AI Scenario Importer (PoC v1 + v2)

外部シナリオ JSON から `data/map.json` の対象マップへイベントを追記するプラグイン。

- **v1:** `role: villager`（`msg` 直書き）
- **v2:** `role: custom`（`pages[]` / `commands[]` → `page[]` / `cmdblock[]`）

## 使い方

1. RPG-Cobo ツール起動（プロジェクトを開いた状態）
2. **編集** メニューから取り込みを実行:
   - `[PoC] villager JSON取り込み` — `sample/villager.json`
   - `[PoC] custom JSON取り込み` — `sample/custom.json`
3. ログは **表示 → システムコンソール**（Ctrl+@）
4. 対象マップを**閉じて開き直す** → 配置・会話を確認

## ファイル構成

```
project/plugin/aiscenario/
├─ plugin.sk
├─ ScenarioImporter.sk
├─ ScenarioCommandBuilder.sk   # v2: type → cmd_* 変換
└─ sample/
   ├─ villager.json
   └─ custom.json
```

## データ仕様（PoC v1）

- 対応 role: `villager` のみ（`msg` に会話文を直接設定）
- イベント ID: 1000001〜、既存 `event` と衝突しない最小値を採番
- 保存経路: `ConfigItemResource.save()`（`::conf.map` 直書き禁止）

## 検証チェックリスト

- [ ] PluginDialog に「AI Scenario Importer (PoC)」が表示される
- [ ] メニュー実行後ログ成功
- [ ] M001 に村人が追加され会話できる
- [ ] 既存イベントが消えていない
