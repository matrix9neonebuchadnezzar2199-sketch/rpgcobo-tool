# AI Scenario Importer (PoC v1)

外部シナリオ JSON から `data/map.json` の対象マップへ **villager** イベントを追記する PoC プラグイン。

## 使い方

1. RPG-Cobo ツール起動（プロジェクトを開いた状態）
2. **編集 → [PoC] シナリオJSON取り込み**
3. ログに `imported N villager(s) into M001 ids=[...]` が出る
4. 対象マップを**閉じて開き直す**（またはツール再起動）→ 村人配置・会話を確認

## サンプル

`sample/villager.json` — 取り込み対象の中間 JSON。`map` にマップ ID、`events[]` に villager 定義。

## データ仕様（PoC v1）

- 対応 role: `villager` のみ（`msg` に会話文を直接設定）
- イベント ID: 1000001〜、既存 `event` と衝突しない最小値を採番
- 保存経路: `ConfigItemResource.save()`（`::conf.map` 直書き禁止）

## 検証チェックリスト

- [ ] PluginDialog に「AI Scenario Importer (PoC)」が表示される
- [ ] メニュー実行後ログ成功
- [ ] M001 に村人が追加され会話できる
- [ ] 既存イベントが消えていない
