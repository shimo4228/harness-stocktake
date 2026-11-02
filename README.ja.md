[English](README.md) | [日本語](README.ja.md)

# harness-stocktake

Claude Code のハーネス全体（skill・rules・agent・hook・CLAUDE.md・ADR・設定ファイル）を、1 本のレポートと 1 回の承認で監査して片付けます。ファイルをまたいで整える点検で、変えるのは承認したものだけです。

**導入:** `claude plugin install harness-stocktake --marketplace shimo4228/harness-stocktake`<br>
**最初の実行:** `claude` を開いて `/harness-stocktake:harness-stocktake --dry-run` と打ちます（読むだけで、書くのは Markdown のレポート 1 本です）。<br>
**見つけるもの:** `/doctor` が拾い残すものです。古くなった参照、ファイル間の矛盾、もう無いスクリプトにつながった hook、skill と同じことを繰り返す rule。

7 つの監査が並列に走り、指摘は 1 本のレポートにまとまるので、まとめて一度に承認できます。承認するまで何も変わりません。承認すると変更がブランチに入るので、それをマージします。

## 最初の 3 分

Claude Code 2.1.292 以降、git、Python 3.11 以降、[uv](https://docs.astral.sh/uv/)（英語）が必要です（2 つの監査が、標準ライブラリだけで書いたスクリプトを `uv run` で動かします）。

1. インストールします。次のコマンドが、この repo を plugin の marketplace として追加し、plugin を入れます。

   ```bash
   claude plugin install harness-stocktake --marketplace shimo4228/harness-stocktake
   ```

2. どこでもよいので Claude Code を起動し、次のように打ちます。

   ```text
   /harness-stocktake:harness-stocktake --dry-run
   ```

   監査するのは `~/.claude` です。代わりに 1 つのプロジェクトの `.claude/` フォルダを監査するときは、`--project <path to the repo>` を足します。
3. 最初の指摘は 2 分ほどで出ます。各監査が、監査先のフォルダの `.notes/stocktake/<date>/sections/` に自分の節を書いていくので、そのフォルダを開けば節が増えていくのを見られます。実行の最後に `report.md` のパスと、グループごとの件数が出ます。

Claude Code は、実行が使うコマンド（`git`、`python3`、`uv`、`date`、2 つの子チェック用の `claude`）ごとに、使う前に確認を求めます。「allow for this session」と答えると、それ以上は聞かれずに最後まで進みます。スクリプトや別の `claude -p` から動かすときは確認に答える人がいないので、先に許可しておきます。

```bash
claude -p "/harness-stocktake:harness-stocktake --dry-run" \
  --allowedTools "Read,Grep,Glob,Write,Edit,Agent,Bash(git:*),Bash(python3:*),Bash(uv:*),Bash(date:*),Bash(claude:*)"
```

計測した実行では、最初の指摘が出るまでの中央値は 138 秒でした（公開ハーネス 14 件）。小〜中規模のハーネスなら 10 分以内にレポート全体が揃います。計測した中で最大のものは 11〜15 分かかりました。

## レポートの中身

指摘は 1 件が 1 行です。判定（Retire、Merge、Improve、Update、Keep）、対象のファイル、ファイルを開かずに判断できる理由、そして正確な変更内容が並びます。行は影響の大きいもの（Retire）から小さいものへとグループにまとまり、Keep の行は最後に畳まれます。

[`examples/sample-report.md`](examples/sample-report.md)（英語）は、[`examples/sample-harness/`](examples/sample-harness/)（英語）のサンプルハーネスから出た実際のレポートです。サンプルはよくあるずれを抱えた小さなプロジェクトで、存在しないスクリプトにつながった hook、同じレビューをする 2 つの skill、退役したモデルに固定された agent、無い `make` ターゲットを挙げる `CLAUDE.md` が入っています。

`--dry-run` のレポートは読むためのものです。指摘を反映するには、`--dry-run` を外してもう一度実行します。レポートは同じですが、今度は指摘の `decision` セルを書き換えて（`skip`、`Keep`、別の判定、またはメモ）その指摘を上書きでき、そのあとチャットで「approved」と伝えます。

利用履歴が要るチェック（一度も使っていない skill はどれか）は、`~/.claude` を監査していて、かつ設定が `~/.claude/metrics/` に利用ログを残しているときだけ、そのログを読みます。ログが無いとき、また `--project` の実行では常に `n/a` になります。使っていない skill は `/doctor` が拾います。

## 読むもの・書くもの・送るもの

- **読む**: 監査するハーネスのファイルです。`~/.claude`（または `--project` の repo）の skill、rules、agent、`settings.json` の hook とそれが呼ぶスクリプト、`CLAUDE.md`、`AGENTS.md`、ADR、`README.md`、設定ファイル。`~/.claude` を監査するときは、`~/.claude/metrics/` の利用ログ（あれば）と、`~/.claude.json` と `~/.claude/.mcp.json` にある MCP サーバーの名前も読みます。
- **書く**: `--dry-run` では、監査先フォルダの中の実行フォルダ `.notes/stocktake/<date>/` だけです。`--dry-run` なしでは、承認のあとに git の worktree とブランチ `stocktake/<date>` を作り、監査ごとに 1 コミットします。skill・rules・agent・hook・rules-distill の監査は、判定の履歴を監査先のハーネスに残します。場所は `~/.claude`（または repo の `.claude/`）の下の `stocktake/<audit>.json` で、そのブランチにコミットされます。context-sync は履歴を残しません。repo-asset-stocktake は、`--project` の実行でも、監査先の repo の `stocktake/<date>` ブランチに `.repo-asset-stocktake.json` を書きます。自分でマージすることはなく、マージは利用者が行います。
- **動かす**: `git`、`python3`（標準ライブラリだけ）、2 つの監査のスクリプト用の `uv run`、そして 2 つのチェックのための子の `claude -p` セッションです。子の 1 つは、各 skill を一覧に載せるコストを見る `/skill-doctor` です。もう 1 つは、rule が無くてもモデルがすでにその rule の求めることをしているかを、新しいセッションで確かめる検査です。どちらの子も hook を切り、MCP サーバーを使わず、ファイルの書き込み・ネットワークからの取得・シェルの実行ができるツールを持たずに動きます。
- **送る**: テレメトリは送りません。ネットワークに出るのは 2 つです。1 つは skill-stocktake が、skill に書かれた公開の http(s) URL がまだ開けるかを、URL ごとに 1 回の GET で確かめることです（タイムアウト 10 秒、本文は読まず、プライベートアドレスとローカルアドレスは飛ばします）。もう 1 つは、監査のスクリプトを初めて `uv run` するときに PyPI からパッケージを取ってくることです（各 `uv.lock` で固定した開発ツールと、固定していないビルドバックエンドの `hatchling`）。ほかに、自分で選んだときだけ起きるものが 2 つあります。`--unattended` では、締めの数行を指定した通知コマンドに渡します。Claude のデスクトップアプリで日本語のレポートを作ると、そのレポートは非公開の Artifact ページにも載ります。

監査するファイルはデータとして扱います。`SKILL.md` や `CLAUDE.md` の中の指示は証拠として引用するだけで、実行はしません。信頼していない repo には、この repo を clone して `skills/harness-stocktake/scripts/isolated-dry-run.sh <repo> <out-dir>` を使ってください。空のフォルダから、シェルも MCP サーバーも設定ファイルも無しで監査を走らせるので、その repo の hook は動きません。

## /doctor との関係

Claude Code 自身のチェック（Claude Code 2.1.316 時点）が見るのは、使われ方と書き方です。`/doctor` は使っていない plugin・MCP サーバー・skill と遅い hook を一覧し、`/doctor prompt-audit` は古いモデル向けの書き方を指摘します。harness-stocktake は、ファイルをまたいで中身を判定します。skill と矛盾する rule、スクリプトの消えた hook、もうコードと合わない ADR、同じ仕事をする 2 つの agent といったものです。見つけるものが違うので、両方を回してください。

## 精度

24 回の実行（公開ハーネスと著者自身のハーネス）から 60 件の指摘を抜き出し、別のモデルが各指摘の中心の主張を repo と照らし合わせました。60 件中 57 件（95%）が成り立ちました。細部（正確な件数、行番号）まですべて正しかったのは 60 件中 40 件なので、承認の前に `change` セルを読んでください。

## 時間と利用量

最初の指摘は約 2 分で出て、よくある規模のハーネスならレポート全体が 5〜10 分で揃います（計測した中で最大の、135 項目以上のものは 11〜15 分）。7 つの監査は Opus のサブエージェントとして並列に走り、ソース（skill、rules、agent、hook、ドキュメントなど）ごとに 1 つずつ受け持ちます。大きな skill ライブラリは 12 件ずつのバッチに分けます。Pro か Max のプランでは利用上限に数えられます（API キーを使っているなら API クレジットに数えられます）。

<details>
<summary>7 つの監査、プロジェクトモード、定期実行、計測の条件</summary>

harness-stocktake は 10 個の skill からなる Claude Code の plugin です。`skills/harness-stocktake/SKILL.md` がほかの 9 つのうち 7 つをソースとして動かし、レポートと反映の手順を受け持ちます。各ソースの判定規則は、そのソースの `SKILL.md` が持ちます。`skill-health` は、skill に書かれたパスと URL がまだたどれるかを確かめるために skill-stocktake が使うスキャナです。`skill-writer` は、承認した指摘が skill を書き直すときに反映の手順が通す草稿ゲートで、Anthropic の `skill-creator` の代わりではありません。要件: Claude Code 2.1.292+、git、Python 3.11+、uv。ライセンス: MIT。

### 7 つの監査

| ソース | skill | 見るもの |
|---|---|---|
| `hooks` | hook-stocktake | hook のスクリプトと、`settings.json` でのつなぎ方 |
| `docs` | context-sync | `CLAUDE.md`、ADR、README をコードと照合 |
| `agents` | agent-stocktake | agent の定義 |
| `distill` | rules-distill | 複数の skill で繰り返されていて、rule に置くべき原則 |
| `skills` | skill-stocktake | skill: 重複、古さ、一覧に載せるコスト |
| `assets` | repo-asset-stocktake | 使い手がいなくなった設定・スクリプト・ドキュメント |
| `rules` | rules-stocktake | rules: 毎セッション読み込まれることで生じるコスト、古さ、冗長さ |

それぞれ単独でも動かせます（例: `/harness-stocktake:skill-stocktake`）。

### 引数

| 引数 | 効果 |
|---|---|
| なし | すべての監査を回し、レポートを出して承認を待つ |
| `--dry-run` | レポートだけ。ブランチ、worktree、台帳への書き込みはなし |
| `--project <repo>` | `~/.claude` の代わりに `<repo>/.claude/`、`CLAUDE.md`、その repo のドキュメントを監査 |
| `<source>` | 1 つの監査だけ（`hooks`、`docs`、`agents`、`distill`、`skills`、`assets`、`rules`） |
| `--out <dir>` | 実行フォルダの置き場所 |
| `apply` | 承認済みのレポートから再開 |
| `--unattended` | レポートを公開して止まる（毎月の定期実行用） |

変更を反映するには、監査先のフォルダが git の repo である必要があります。`~/.claude` がそうでなければ、`--dry-run` を使うか、先にそこで `git init` を実行してください。

### 定期実行

毎月の実行は、cron、スケジュールされたタスク、CI から `claude -p "/harness-stocktake:harness-stocktake --unattended"` を定期的に呼ぶ形です。コマンドは上の `claude -p` の例と同じく、先に許可しておきます。締めの数行を受け取るコマンド（通知コマンド）は、プロンプトの中で指定します。

GitHub では [harness-stocktake-action](https://github.com/shimo4228/harness-stocktake-action/blob/main/README.ja.md)がこれを代わりに回します。月に 1 回と、`.claude/` を変えるプルリクエストのたびに走り、指摘は 1 つの issue に、承認した変更は 1 つのプルリクエストにまとまります。

### 計測の条件

2026-11-01 に Claude Code 2.1.316 と Opus で計測しました。対象はローカルに clone した公開ハーネスで、`isolated-dry-run.sh` で読み取り専用に監査しました（誰にも連絡しておらず、repo の名前は公開していません）。最初の指摘までの時間: 14 回の実行で中央値 138 秒。10 分以内に揃ったレポート: 14 回中 11 回。超えた 3 回（11〜15 分）はいちばん大きなハーネスで、それぞれ 135〜156 項目あり、監査そのものに最も時間がかかりました。精度: 7 つの監査にまたがる層化抽出で 60 件の指摘を選び、各 repo を読み取り専用で見られる別のモデルが確かめました。

`bench/time-to-first-item.sh` は、サンプルハーネスでインストールからレポートまでの流れを再現し、秒数とコストを記録します。

</details>

## ライセンス

MIT です。issue や質問は [github.com/shimo4228/harness-stocktake/issues](https://github.com/shimo4228/harness-stocktake/issues) へどうぞ。

harness-stocktake は、Agent Knowledge Cycle（AKC）の Curate フェーズを実装したものです（DOI [10.5281/zenodo.19200726](https://doi.org/10.5281/zenodo.19200726)（英語））。
