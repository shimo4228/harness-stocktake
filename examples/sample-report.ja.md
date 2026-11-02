# Harness 棚卸し 2026-11-02 — examples/sample-harness

- **date:** 2026-11-02
- **base:** `dc1ab8234b46445ab7e1b635b8a17039bd2467e2`

| Group | Count |
|---|---|
| 退役 | 6 |
| 統合・降格 | 2 |
| 改善・更新 | 16 |
| 維持 | 11 |
| **Total** | **35** |

判定を変える項目だけ `decision` 欄を書き換える（空欄 = 推奨どおり。`skip`・`Keep`・別の判定語・コメントも書ける）。そのうえで chat で承認する。

## Sources

### hooks — 対象 3 件（Retire 2 / Improve 1 / Keep 0）


Keep: 0 件

（台帳 `.claude/stocktake/hook-stocktake.json` は未作成。使用状況の証拠は n/a。テストは `*.bats` が無いため —。）

### docs（Update 5 / Keep 1）


Keep: 1 件（docs/adr/0001-in-memory-store.md）

参考: graph.jsonld・llms.txt・AGENTS.md は無い（ソース 1 ファイルの規模のため作成 item は立てていない）。adr_index チェックは adr_lint.py 不在で degraded（手動で ADR 1 件・index 無しを確認）。

### agents — 1 件（Dissolve 1 / Keep 0）


Keep: 0 件

総 description 語数: 10（前回監査なし、差分 n/a）

### distill(rules-distill)— 6 件: Already Covered 3 / Too Specific 3 / Append 0 / Create 0 / Revise 0

棚卸し対象: skill 4 件(.claude/skills/*/SKILL.md)、rule ファイル 1 件(.claude/rules/style.md、見出し 1)、CLAUDE.md(見出し 4)。ledger(.claude/stocktake/rules-distill.json)は未作成。

rules への昇格条件(環境固有・substrate 非既定・手順でない)を満たす候補はなく、変更を伴う item はありません。

変更なし(Keep 系): 6 件 — Already Covered 3(distill-01 `make e2e` はリリース前に実行 / distill-02 `make test` / distill-03 基点ブランチ main、いずれも CLAUDE.md に記載済み)、Too Specific 3(distill-04 deploy / distill-05 release-notes / distill-06 code-review+pr-review、いずれも手順なので skill に留める)。付記: Makefile に `e2e` ターゲットが無く、`scripts/deploy.sh` も存在しない(context-sync / skill-stocktake 側の扱い)。

### skills（4件: Merge 1 · Update 1 · Improve 1 · Keep 1）

スキャン対象は `.claude/skills/*/SKILL.md` の4件。symlink（外部所有）のものはなし。使用量と常駐コストは project mode のため `n/a`（未計測）。台帳 `.claude/stocktake/skill-stocktake.json` は存在しない（初回の監査で、hygiene 違反はなし。--dry-run のため書き込みはしていない）。


Keep: 1件（pr-review）

### assets（repo-asset-stocktake）— 14 件: Retire 2 / Merge 1 / Update 8 / Keep 3


Keep: 3 件（.claude/hooks/format.sh、.claude/skills/code-review/SKILL.md、docs/adr/0001-in-memory-store.md）

### rules（1件: Retire 1 / Keep 0）

対象は1ファイル・6行。整合性チェックの失敗はなし（README なし、ポインタやリンクもなし）。


Keep: 0件

## 衝突

- hooks-01 × assets-04 (same-target): `.claude/settings.json`
- docs-03 × docs-04 × assets-07 (same-target): `CLAUDE.md`
- agents-01 × assets-05 (same-target): `.claude/agents/reviewer.md`
- skills-02 × assets-02 (same-target): `.claude/skills/deploy/SKILL.md`
- assets-08 × rules-01 (same-target): `.claude/rules/style.md`
- skills-01 × assets-03 (contradiction): code-review と pr-review の統合方向が逆（skills-01: code-review → pr-review、assets-03: pr-review → code-review）。両方は適用できない。skills ソースが skill の判定を持ち、pr-review は 'unclear names' の観点を既に含むので、skills-01 の方向なら移す内容は make test の 1 行で済む — 勝つのは skills-01
- rules-01 × docs-03 (contradiction): docs-03 は CLAUDE.md の規約 3 行を消して .claude/rules/style.md への参照に置き換えるが、rules-01 は CLAUDE.md が同じ規約を持つことを根拠に style.md を削除する。rules-01 を採るなら docs-03 は CLAUDE.md:20（型ヒントの 2 回目）の削除だけに縮める — 勝つのは rules-01
- rules-01 × assets-08 (same-file): assets-08 は style.md:6 の black を ruff format に直すが、rules-01 はファイルごと削除する。rules-01 を採れば assets-08 は不要 — 勝つのは rules-01
- hooks-01 × assets-04 (same-change): どちらも .claude/settings.json の check-secrets.sh を呼ぶ Bash エントリ（8-11 行目）を削除する同じ変更。判定語が Retire と Update で群が違うため 1 行にまとめず、どちらか一方を承認すればもう一方も満たされる
- skills-02 × assets-02 (same-file): deploy skill を skills-02 は Update（存在しない make e2e と scripts/deploy.sh を直す）、assets-02 は Retire。デプロイ手順が実在するかを作者が決める必要がある
- agents-01 × assets-05 (same-file): reviewer.md を agents-01 は Dissolve、assets-05 は参照とモデル ID の Update。agents-01 を採れば assets-05 は不要 — 勝つのは agents-01
- assets-07 × assets-06 × skills-02 (related): Makefile に e2e ターゲットを足すか（assets-06）、参照側から外すか（docs-02 は CLAUDE.md:8 を削除、skills-02 は deploy の手順 1）で方向をそろえる必要がある

## 退役

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 1 | hooks-01 | Retire (alt: Improve: `.claude/hooks/check-secrets.sh` を新規作成し（Bash の tool_input.command を jq で取り出し、quote した上で既知のトークン形式を検査する）、配線は残す) | .claude/settings.json | PostToolUse(Bash) に配線された `bash .claude/hooks/check-secrets.sh` は呼び出し先スクリプトがリポジトリに存在せず（dangling）、git 履歴にも一度も現れないため、Bash ツール実行のたびに存在しないファイルを bash で起動するだけでシークレット検査は一切行われていない。修復するには検査ロジックを一から書く必要があり、名前が与える「シークレット検査が効いている」という誤った安心感を残すより配線を外す方が正しい。シークレット検査が必要なら、別途スクリプトとテストを用意して新規に配線する。 | .claude/settings.json から PostToolUse の 2 番目のエントリ（9-11 行目 `{ "matcher": "Bash", "hooks": [{ "type": "command", "command": "bash .claude/hooks/check-secrets.sh" }] }`）と直前のカンマを削除し、PostToolUse は Edit\|Write の format.sh 1 件のみにする。削除するスクリプト・テスト・README 行は無い。 | assets-04 | |
| 2 | hooks-02 | Retire (alt: Update: settings.json に `"Stop": [{ "hooks": [{ "type": "command", "command": "bash .claude/hooks/notify-done.sh" }] }]` を追加して配線し、`command -v osascript` が無い環境では exit 0 で抜けるガードを足す; 個人の ~/.claude/settings.json に移す（プロジェクトからは削除）) | .claude/hooks/notify-done.sh （1 file・1 項目を束ねた: assets-01） | `.claude/hooks/notify-done.sh` は settings.json のどのイベントにも配線されていない孤立スクリプト（orphan）で、ヘッダが意図する「セッション停止時の通知」は一度も実行されていない。内容も macOS 専用の `osascript` 1 行で、プロジェクト共有の .claude/ に置くより各自のユーザー設定に属する個人的な通知であるため、削除する。通知が欲しいなら Stop イベントに配線し直す選択肢もあるが、その場合も macOS 以外では失敗する。 | `git rm .claude/hooks/notify-done.sh`。settings.json の配線・テスト・README 行は元から無いため変更不要。 | — | |
| 3 | agents-01 | Dissolve (alt: Update + Improve: model を alias（例: opus）に置換し、tools に Bash を追加、description に委譲しない条件を追記、L8 の ALWAYS/NEVER を判断ベースの一文に書き換え、L9 の存在しない docs/architecture.md 参照を削除（または実在する CLAUDE.md / src/notes.py に向け替え）) | .claude/agents/reviewer.md | code-reviewer（reviewer.md）は「diff のバグをレビューする」役割だが、その仕事は Claude Code 同梱の code-review スキル（現在の diff をバグ観点でレビューし、レビュアー subagent を起動する）が fresh context を保ったまま担っており、本エージェントはそれより劣る：model が旧世代のフル ID `claude-3-opus-20240229` に固定（L4）、tools が Read/Grep/Glob のみで Bash が無いため自力で diff を取得できない（L5）、本文 L9 が参照する `docs/architecture.md` はリポジトリに存在しない、L8 は ALWAYS/NEVER の三連で旧世代型の過剰拘束、description は「after every change」で常時発火を促し委譲しない条件を欠く。さらにリポジトリ内のスキル code-review と pr-review も同じ「現在ブランチの diff をバグ観点でレビュー」を担っており三重化している。削除して同梱 code-review（およびプロジェクトスキル）に一本化し、理由を ADR に記録する。残す場合は alternatives の Update + Improve。 | `.claude/agents/reviewer.md` を削除し、docs/adr/ に「同梱 code-review スキルとプロジェクトスキル code-review / pr-review に吸収されたため code-reviewer エージェントを廃止」する ADR を追加する。 | assets-05 | |
| 5 | assets-02 | Retire (alt: Update — staging へのデプロイが実際に行われているなら、scripts/deploy.sh と Makefile の e2e ターゲットを復元するか、実際の手順に合わせて skill を書き直す（内容の書き直しなので作者に渡す）) | .claude/skills/deploy/SKILL.md | deploy skill が実行するローカル参照 2 件（`make e2e` と `scripts/deploy.sh staging`）はどちらもリポジトリに存在しない。手順どおりに進めると step 1 で必ず失敗し、デプロイまでたどり着けない。 | `.claude/skills/deploy/SKILL.md` を `.claude/skills/deploy/SKILL.md.disabled` にリネームして soft-delete する。実在するデプロイ手順があるなら、作者がスクリプトと e2e ターゲットを復元したうえで書き直す（alternatives を参照）。 | skills-02 | |
| 6 | rules-01 | Retire (alt: Update（6行目を ruff に直して残す）) | .claude/rules/style.md | 全6行のうち規約3項目（型ヒント・f-string・関数40行以内）は常時読み込まれる CLAUDE.md の §Conventions/§Style に同文で既にあり、唯一固有の6行目「black で整形、format hook がやってくれる」は事実と食い違う（hook は black ではなく ruff format を Edit/Write 後に実行）。重複と陳腐化だけで固有の価値が残らないため削除し、必要は CLAUDE.md の同じ規約と .claude/hooks/format.sh（ruff format）が満たす。 | `.claude/rules/style.md` を削除（git rm）。.claude/rules/ はこのファイルだけなので、ディレクトリごと空になる。CLAUDE.md の中で §Conventions と §Style が重複している件（型ヒントが2回）は context-sync の領分なので、ここでは扱わない。 | assets-08, docs-03 | |

## 統合・降格

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 7 | skills-01 | Merge into pr-review | .claude/skills/code-review/SKILL.md | code-review と pr-review は同じ入力（`git diff main...HEAD`）・同じ目的（バグと不足テストを file:line で列挙）・ほぼ同じ description を持つ ABSORBABLE_OVERLAP で、両方を持つとどちらが選ばれるかが曖昧になり、文面の drift コストが二重にかかる。code-review 固有の残差は「その後 `make test` を実行して失敗を報告する」の1行だけなので、これを pr-review に移して code-review を削除する。 | pr-review/SKILL.md の本文末尾に「レビュー後に `make test` を実行し、失敗を報告する」を1行追加し、その後 `.claude/skills/code-review/` ディレクトリを削除する。 | assets-03 | |
| 8 | assets-03 | Merge into .claude/skills/code-review/SKILL.md | .claude/skills/pr-review/SKILL.md | pr-review は code-review と同じく `git diff main...HEAD` を読み、バグと不足テストを file:line で列挙する。中身がほぼ重複している。違うのは「unclear names」の観点だけで、逆に code-review は `make test` の実行も含むので、こちらが上位互換になる。 | code-review/SKILL.md:6 の観点に 'unclear names' を追加し、そのうえで `.claude/skills/pr-review/SKILL.md` を `.claude/skills/pr-review/SKILL.md.disabled` にリネームする。 | skills-01 | |

## 改善・更新

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 9 | hooks-03 | Improve (alt: Keep: ruff を全員が導入済みという前提を受け入れ、現状のまま残す) | .claude/hooks/format.sh | `.claude/hooks/format.sh` は Edit\|Write 後に ruff format を走らせるフックで配線・quote は正しいが、ruff はリポジトリのどこにも依存として宣言されておらず（Makefile の lint は pyflakes、pyproject.toml 等も無い）、さらに出力と終了コードを `>/dev/null 2>&1` と `exit 0` で握り潰しているため、ruff や jq が無い環境では何も起きないことに誰も気付けない。ruff 不在時に stderr へ一行出す（または ruff を開発依存として宣言する）修正を加えて残す。 | .claude/hooks/format.sh を次に置き換える: ```bash #!/usr/bin/env bash # Format the edited Python file with ruff (advisory; never blocks). file=$(jq -r '.tool_input.file_path // empty') \|\| exit 0 [[ $file == *.py ]] \|\| exit 0 if ! command -v ruff >/dev/null 2>&1; then   echo "format.sh: ruff not found; skipping format of $file" >&2   exit 0 fi ruff format "$file" >/dev/null \|\| echo "format.sh: ruff format failed for $file" >&2 exit 0 ``` 併せて ruff を開発依存として宣言する（例: README/CLAUDE.md の Commands に前提ツールとして記載、または requirements-dev に追加）。 | — | |
| 12 | docs-03 | Update | CLAUDE.md | CLAUDE.md の型ヒント・f-string・関数 40 行の 3 規約は .claude/rules/style.md:3-5 と同文で重複しており、「Use type hints everywhere.」は CLAUDE.md 内でも 14 行目と 20 行目に 2 回書かれている。同じ規約が 2 ファイルにあると片方だけ更新されて食い違うため、規約の置き場を rules/style.md に一本化し CLAUDE.md からは削除して 1 行の参照に置き換える。 | CLAUDE.md:13-14（Conventions の `Keep functions under 40 lines.` と `Use type hints everywhere.`）と :20-21（Style の `Use type hints everywhere.` と `Prefer f-strings over `%` formatting.`）を削除し、Style 節に `- Python style: see `.claude/rules/style.md`.` を 1 行置く。Style 節には :22 の PR 規約（docs-04）が残る。 | assets-07, docs-04, rules-01 | |
| 13 | docs-04 | Update | CLAUDE.md | CLAUDE.md:22 `Never commit directly to main; open a PR.` は禁止形の指示だが、禁止形を残す条件（逆向きの既定動作が観測されている・機械的なゲートが無い・一節の理由が付いている）のうち、理由が無く、観測も usage evidence n/a で示せない。既定の動作を肯定形で書き直し、禁止形は残さない。 | CLAUDE.md:22 を `- Work on a feature branch and land changes on main through a PR.` に置き換える。 | assets-07, docs-03 | |
| 14 | docs-05 | Update | README.md （1 file・1 項目を束ねた: assets-09） | README.md は指摘のみで編集しない（リポジトリに README 用の skill は無いのでオーナーはリポジトリ管理者）。README.md:5-7 はこのプロジェクトではなく「harness-stocktake のサンプル harness」としての説明で、そこに出てくる `bench/time-to-first-item.sh` と `dot-claude/` はどちらもリポジトリに存在しない。また README.md:3 は「HTTP service」と書いているが、src/notes.py は in-memory dict の add 関数だけで HTTP 層が無い。 | フラグのみ（context-sync は README を編集しない）: README.md:5-7 のサンプル harness 説明段落を削除するか、プロジェクト自体の説明（何を保存するか・現状は in-memory でサーバー未実装であること、ADR-0001 への参照）に書き換える。README.md:3 の「HTTP service」は実装に合わせて「note store（HTTP 層は未実装）」等に直すか、HTTP 層の実装までそのままにするかをオーナーが判断する。 | — | |
| 15 | skills-02 | Update (alt: Retire（staging へのデプロイ手順自体がもう存在しない場合）) | .claude/skills/deploy/SKILL.md | deploy の3手順のうち2つが存在しない成果物を指していて、手順どおりには実行できない。手順1の `make e2e` は Makefile にターゲットがなく（test と lint のみ）、手順2の `scripts/deploy.sh` はリポジトリに存在しない。手順3の「team channel への投稿」も投稿の手段（コマンドやツール）が書かれていない。リリース前の e2e → デプロイという流れは CLAUDE.md:8 とも一致する正当なジョブなので、ローカルで直せる参照切れとして Update にする。 | skill-writer への intent packet — 対象: .claude/skills/deploy/SKILL.md。直す点: (1) 手順1を実在する e2e の実行方法に置き換えるか、Makefile に e2e ターゲットを追加する（作者に確認）；(2) 手順2の `scripts/deploy.sh` を実際のデプロイ手段に差し替える（作者に確認。手段がもう存在しない場合は Retire に切り替える）；(3) 手順3に投稿先と手段を書き、notes の出どころとして release-notes スキルを名指しする；(4) description に使うタイミング（例: staging にリリースするとき）を足す。No リスト: Currency（make e2e・scripts/deploy.sh）、Actionability（team channel）、Scope fit（description にトリガーがない）。 | assets-02, assets-06, assets-07 | |
| 16 | skills-03 | Improve | .claude/skills/release-notes/SKILL.md （1 file・1 項目を束ねた: assets-10） | release-notes の手順1 `git describe --tags --abbrev=0` は、タグがひとつもないこのリポジトリでは「fatal: No names found」で失敗し、その後の手順が進めない。タグがない場合の代替（最初のコミットから集めるなど）がない。手順3は既存の `CHANGELOG.md` を前提にしているが、ファイルは存在せず、新規作成の指示もない。ジョブ自体はこのリポジトリ固有で（deploy の手順3が release notes を使う）、残す価値がある。 | skill-writer への intent packet — 対象: .claude/skills/release-notes/SKILL.md。直す点: (1) 手順1にタグがない場合の代替を書く（例: `git rev-list --max-parents=0 HEAD` を起点にする）；(2) 手順3に CHANGELOG.md がなければ作成する旨と、見出しの形式（バージョン/日付）を書く；(3) 「type」の分類（feat/fix など）を明示する。No リスト: Currency（タグのない状態で手順1が失敗）、Actionability（CHANGELOG.md がない）。 | — | |
| 17 | assets-04 | Update (alt: Update — 削除する代わりに .claude/hooks/check-secrets.sh を作成する（中身の設計は作者の判断）) | .claude/settings.json | settings.json の PostToolUse(Bash) hook が呼ぶ `.claude/hooks/check-secrets.sh` はリポジトリに存在しないので、Bash を実行するたびに存在しないスクリプトが起動される。Edit\|Write → format.sh のほうは正常に配線されている。 | .claude/settings.json:8-11 の Bash matcher のブロック（check-secrets.sh を呼ぶ要素）を削除する。シークレット検査が必要なら、作者が check-secrets.sh を新しく書いて復元する。 | hooks-01 | |
| 18 | assets-05 | Update | .claude/agents/reviewer.md | code-reviewer agent が最初に読むよう指示している `docs/architecture.md` はリポジトリに存在しない。model には 2024 年の固定 ID `claude-3-opus-20240229` がピン留めされている。 | reviewer.md:9 の `docs/architecture.md` への参照を削除するか、実在するファイル（例: src/notes.py、CLAUDE.md）に向け直す。reviewer.md:4 の model 行は削除して既定値を継承させるか、現行のモデル ID に差し替える。 | agents-01 | |
| 19 | assets-06 | Update | Makefile | Makefile には CLAUDE.md と deploy skill が参照する `e2e` ターゲットがない。さらに `make test` は src/ からテストを探すが、テストファイルが 0 件なので実質 no-op になっている。 | 機械的に直せる修正はない。e2e ターゲットを追加するか、参照側（CLAUDE.md:8、deploy skill）から外すかは作者が判断する。src/ にテストを追加するまで `make test` が何も検査していないことは完了報告に pending として記載する。 | assets-07, skills-02 | |
| 20 | assets-07 | Update | CLAUDE.md （1 file・2 項目を束ねた: docs-01, docs-02） | CLAUDE.md は存在しない `make e2e`（リリース前に必須と書かれている）と、存在しない `docs/architecture.md` を案内している。'Use type hints everywhere.' も同じファイル内で 2 回出てくる。 | CLAUDE.md:8 の e2e 行と CLAUDE.md:15 の architecture 行を削除し（assets-06 で作者が e2e を追加すると決めた場合は 8 行目を残す）、CLAUDE.md:20 の重複行を削除する。 | assets-06, docs-03, docs-04, skills-02 | |
| 21 | assets-08 | Update | .claude/rules/style.md | style.md には「format hook が black で整形する」とあるが、実際の format hook は ruff を実行しており black ではない。残り 3 行は CLAUDE.md の Conventions/Style と同じ文言の重複になっている。 | style.md:6 の 'black' を 'ruff format' に直す。style.md:3-5 と CLAUDE.md:13-14、20-21 の重複は、どちらか一方に寄せる（rules ソースの判定に委ねる）。 | rules-01 | |
| 24 | assets-11 | Update | .repo-asset-stocktake.json | repo-asset-stocktake のレジャー `.repo-asset-stocktake.json` がリポジトリにないので、今回の判定を次回の `changed` モードに引き継げない。 | apply フェーズで、evaluated_at（UTC）、repo、今回の 14 判定（action は pending か適用結果）を含む `.repo-asset-stocktake.json` を作成する。コミットしたくない場合は .gitignore への追加を作者に提案する。--dry-run なので今回は書き込まない。 | — | |

## 維持 (11)

<details>

| order | id | verdict | target | reason |
|---|---|---|---|---|
| 25 | docs-06 | Keep | docs/adr/0001-in-memory-store.md | ADR-0001 の決定（module-level dict に保存）は src/notes.py:3 の `NOTES: dict[int, str] = {}` と一致しており、見直し条件「PostgreSQL を導入したら」はまだ成立していないので現行の決定として正しい。ADR は 1 件だけで index ファイルも無いため、index のずれも起こり得ない。 |
| 26 | distill-01 | Already Covered | CLAUDE.md | deploy skill の「リリース前に `make e2e` を走らせ、失敗したら止まる」という原則は、CLAUDE.md の Commands 節が「run before every release」として既に常駐させているため、rules への昇格は不要。ただし Makefile に `e2e` ターゲットが存在せず、事実そのものが古い可能性がある(これは context-sync / skill-stocktake 側の扱い)。 |
| 27 | distill-02 | Already Covered | CLAUDE.md | code-review skill が前提とする「ユニットテストは `make test`」という環境事実は、CLAUDE.md の Commands 節に既に記載され、Makefile とも一致しているため、rules への昇格は不要。 |
| 28 | distill-03 | Already Covered | CLAUDE.md | code-review と pr-review の 2 skill が共通して前提にする「比較の基点となるブランチは `main`」という事実は、CLAUDE.md の「Never commit directly to main; open a PR.」で main がトランクであることが既に常駐しているため、別途 rule 化は不要。 |
| 29 | distill-04 | Too Specific | .claude/skills/deploy/SKILL.md | deploy skill の「`scripts/deploy.sh staging` を実行し、リリースノートをチームチャンネルに投稿する」は手順であり(テスト 3 不合格)、デプロイ作業時にだけ必要なので skill に留めるべき。参照先 `scripts/deploy.sh` がリポジトリに存在しない点は skill-stocktake 側で扱う。 |
| 30 | distill-05 | Too Specific | .claude/skills/release-notes/SKILL.md | release-notes skill の「最新タグ以降のコミットを種類別にまとめて `CHANGELOG.md` に書く」は作業手順であり(テスト 3 不合格)、常駐させる環境固有の事実・罠を含まないため skill に留めるべき。 |
| 31 | distill-06 | Too Specific | .claude/skills/code-review/SKILL.md | code-review と pr-review が繰り返す「diff を読みバグ・テスト漏れを file:line 付きで列挙する」はレビュー手順かつ一般的な判断であり(テスト 1・3 不合格)、2 skill で再出現していても rules への昇格対象ではない。両 skill の重複は skill-stocktake 側で扱う。 |
| 32 | skills-04 | Keep | .claude/skills/pr-review/SKILL.md | pr-review は PR を開く前に現ブランチの diff（`git diff main...HEAD`、main ブランチは実在）を読み、バグ・不足テスト・わかりにくい名前を file:line で報告する具体的なスキルで、description も本文と一致している。code-review との重複は skills-01 で code-review をこちらへ統合して解消するため、統合先として残す。 |
| 33 | assets-12 | Keep | .claude/hooks/format.sh | format.sh は .claude/settings.json:6 の PostToolUse(Edit\|Write) から呼ばれており、編集された .py ファイルを ruff format で整形する。今も機能している hook。 |
| 34 | assets-13 | Keep | .claude/skills/code-review/SKILL.md | code-review skill は実在する `git diff main...HEAD` と `make test`（Makefile:2）だけを参照しており、pr-review を統合する側（assets-03）として残す。 |
| 35 | assets-14 | Keep | docs/adr/0001-in-memory-store.md | ADR-0001 は CLAUDE.md:16 の `docs/adr/` から案内されている。「module-level dict に保存する」という決定も src/notes.py:3 の `NOTES: dict[int, str] = {}` と今も一致している。 |

</details>

## native が見るもの

この report は中身の判定（古い参照・矛盾・持ち主の消えた設定・rule への蒸留）を出す。使用履歴と書き方は Claude Code の native 検査が見る: `/doctor` は使われていない plugin・MCP・skill と遅い hook を、`/doctor prompt-audit` は古い model 向けの書き方（固定の数値上限・強い強調・存在しない tool への言及）を出す。二つは重ならないので、両方を回して並べて読む（この run はどちらも実行していない）。
