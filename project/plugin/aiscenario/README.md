# AI Scenario Importer (PoC v1 + v2)

外部シナリオ JSON から `data/map.json` の対象マップへイベントを追記するプラグイン。

- **v1:** `role: villager`（`msg` 直書き）
- **v2:** `role: custom`（`pages[]` / `commands[]` → `page[]` / `cmdblock[]`）

**詳細技術メモ:** [`docs/aiscenario-poc.md`](../../docs/aiscenario-poc.md)（PR #3 確定仕様・保存経路・落とし穴）

## 使い方

### プラグイン（RPG-Cobo 内）

1. RPG-Cobo ツール起動（プロジェクトを開いた状態）
2. **編集 → JSON シナリオ取り込み...** を実行
3. **JSON を貼り付け** または **JSON ファイルを選択**
4. プレビュー（対象 map / events 件数 / 各 event の OK/NG）を確認 → **Import**
5. ログは **表示 → システムコンソール**（Ctrl+@）
6. 対象マップを**閉じて開き直す** → 配置・会話を確認

開発用 sample 固定メニュー（`[Dev] sample villager/custom`）も残しています。

### Scenario Maker → RPG-Cobo 正式導線

1. **Web で JSON を作る**
   - GitHub Pages: https://matrix9neonebuchadnezzar2199-sketch.github.io/aiscenario-maker/
   - または `scenario-maker/index.html` をローカルで開く
2. **JSON を作成する** → **コピー** または **ダウンロード**
3. RPG-Cobo で **編集 → JSON シナリオ取り込み...**
   - コピーした JSON → **貼り付け**
   - ダウンロードした `.json` → **ファイル選択**
4. プレビュー確認 → Import → マップ再オープン

### シナリオメーカー（ブラウザ）

AI なしで中間 JSON を作るウィザード HTML です。

1. `scenario-maker/index.html` をブラウザで開く（右上に **v0.5.0** 等の版数表示）
2. **左サイドバー** — プリセット読込 / 履歴（ホバーでプレビュー・「読み込み」で復元）/ 下書きリセット
3. ステップ 1〜3 でキャラ種類・配置・会話を入力
4. **JSON を作成する** → 右ペインに出力（会話プレビュー付き・履歴に自動保存）
5. **コピー** または **ダウンロード** した JSON を、RPG-Cobo 側で取り込む

サイドバーは ☰ で折りたたみ可能。履歴は最大 30 件（localStorage）。

**版数:** `index.html` 内 `APP_VERSION` を修正のたびに更新（右上表示と連動）。

### GitHub Pages 公開版

ブラウザ単体で配布する公開 URL 用リポは **`aiscenario-maker`**（開発正本とは別）。

| 項目 | 値 |
|------|-----|
| 公開 URL | https://matrix9neonebuchadnezzar2199-sketch.github.io/aiscenario-maker/ |
| Pages リポ | https://github.com/matrix9neonebuchadnezzar2199-sketch/aiscenario-maker |
| ローカル clone | `H:\CURSOR\aiscenario-maker` |

**更新手順（正本 → Pages）:**

```powershell
# 1. ここ（scenario-maker/）を編集し APP_VERSION を bump → rpgcobo-tool を commit/push
# 2. Pages リポへ同期
cd H:\CURSOR\aiscenario-maker
.\update-from-rpgcobo.ps1
git add index.html logo.png
git commit -m "chore: sync scenario maker from rpgcobo-tool"
git push
```

運用メモ（Obsidian）: `40_Tools/aiscenario-maker-pages-update.md`

## 保存経路（PR#3 4点目）

インポート先は対象マップの編集状態で自動分岐する。

| 状態 | 経路 | 保存先 |
|---|---|---|
| 対象マップを開いている（非アクティブタブ含む） | A（editor） | `::skstudio.tabeditors["/.x/map/<mapid>"].data.event` → `editor.save()` |
| 対象マップを開いていない | B（disk） | `getResource → deepclone → save()` |

- **経路A:** 本家 `MapToolEvent.sk` の savefunc 作法（`save()` → `markSaved()` → `updateChangeFile`）に倣う。
- **経路A の制約:** ギズモ（3D表示）の即時生成は PoC スコープ外。**マップを開き直す**と追記イベントがエディタ画面に表示される。
- **作者確認済み:** `::skstudio.tabeditors` から非アクティブタブを含む開いているエディタを列挙できる。

## ファイル構成

```
project/plugin/aiscenario/
├─ plugin.sk
├─ ScenarioImporter.sk
├─ ScenarioCommandBuilder.sk   # v2: type → cmd_* 変換
├─ ImportDialog.sk               # 貼り付け / ファイル / プレビュー
├─ ScenarioAI.sk                 # M5: AI 生成スタブ（中間 JSON のみ）
├─ scenario-maker/
│  └─ index.html                 # ブラウザ用 JSON ウィザード
└─ sample/
   ├─ villager.json
   └─ custom.json
```

## マイルストーン

| ID | 内容 | 状態 |
|---|---|---|
| M0 | sample import + editor/disk 保存経路 | 完了 |
| M1 | JSON 貼り付け取り込み | 完了 |
| M2 | JSON ファイル選択取り込み | 完了 |
| M3 | 取り込み前 validate / preview | 完了 |
| M4 | Scenario Maker → RPG-Cobo 正式導線 | 完了 |
| M5 | AI 生成（中間 JSON のみ、validate 経由） | 設計スタブ |

詳細: [`docs/aiscenario-milestones.md`](../../docs/aiscenario-milestones.md)

## データ仕様（v2 custom）

- **trigger（文字列→数値）:** `examine`=2, `auto`=6, `contact`=3（作者確認 PR#3）
- **message.uiclose:** `0`=開いたまま / `1`=イベント終了時に閉じる / `2`=即閉じ（**既定 2**、未指定時）

## データ仕様（PoC v1）

- 対応 role: `villager` のみ（`msg` に会話文を直接設定）
- イベント ID: 1000001〜、既存 `event` と衝突しない最小値を採番
- 保存経路: `ConfigItemResource.save()`（`::conf.map` 直書き禁止）

## 検証チェックリスト

- [ ] PluginDialog に「AI Scenario Importer (PoC)」が表示される
- [ ] メニュー実行後ログ成功
- [ ] M001 に村人が追加され会話できる
- [ ] 既存イベントが消えていない
