# Roster Share

リストを共有して出欠を確認するアプリ。PC、スマホ（Android、iPhone）対応。

![Roster Share Icon](web/icons/Icon-192.png)

## 📱 概要

**Roster Share** は、イベントの出欠確認とメモ管理を行うシンプルなWebアプリケーションです。ミニマリストデザインで、PC・スマートフォン(Android・iPhone)の両方に対応しています。

## ✨ 主な機能

### イベント管理
- ✅ イベントの作成・編集・削除
- ✅ イベント名、説明、日時、場所の設定
- ✅ イベント一覧表示(日付順)
- ✅ イベント詳細表示

### 出欠確認
- ✅ 参加者ごとの出欠ステータス管理（出席/欠席/保留）
- ✅ 出欠状況のリアルタイム集計
- ✅ 参加者リストの表示と管理

### メモ機能
- ✅ イベント全体へのメモ追加
- ✅ 参加者個別へのメモ追加
- ✅ メモの編集・更新

### データ連携
- ✅ CSVエクスポート（単体・全体）
- ✅ CSVインポート
- ✅ Google Drive連携
- ✅ OneDrive連携
- ✅ SharePoint連携

### データ管理
- ✅ ローカルストレージ(Hive)によるデータ永続化
- ✅ オフラインでの動作可能
- ✅ ブラウザ内でのデータ保存

## 🎨 デザイン

ミニマリスト&クリーンデザインを採用:
- ⚪ ホワイトベース
- 📝 テキスト中心の情報表示
- ⚫⚪ モノクロームアイコン
- 📏 豊富なホワイトスペース
- 🎯 必要最小限の要素
- 📱 レスポンシブ対応

## 🛠️ 技術スタック

- **Flutter**: 3.35.4
- **Dart**: 3.9.2
- **State Management**: Provider 6.1.5+1
- **Local Storage**: Hive 2.2.3 + Hive Flutter 1.1.0
- **CSV**: csv 6.0.0
- **File Picker**: file_picker 8.1.6
- **URL Launcher**: url_launcher 6.3.1
- **Date Formatting**: intl 0.19.0
- **UUID**: uuid 4.5.1

## 📦 インストール

### 必要な環境
- Flutter SDK 3.35.4
- Dart SDK 3.9.2

### セットアップ手順

1. リポジトリをクローン
```bash
git clone https://github.com/seyaytua/Roster_Share.git
cd Roster_Share
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. Webアプリとして実行
```bash
flutter run -d chrome
```

または

```bash
flutter build web --release
cd build/web
python3 -m http.server 8080
```

## 📖 使い方

### イベント作成
1. 右下の「+」ボタンをタップ
2. イベント情報を入力
3. 参加者を追加
4. 「保存」ボタンで保存

### 出欠確認
1. イベント一覧から対象イベントをタップ
2. 参加者リストで出欠ステータスをタップ
3. 出席/欠席/保留から選択

### CSVエクスポート
- **単体**: イベント詳細画面 → 共有 → CSVダウンロード
- **全体**: イベント一覧画面 → ↓アイコン

### CSVインポート
1. イベント一覧画面 → ↑アイコン
2. CSVファイルを選択
3. 自動的にインポート

### クラウド連携
1. イベント詳細画面 → 共有アイコン
2. Google Drive/OneDrive/SharePointを選択
3. CSVダウンロード + サービスが開く
4. 手動でアップロード

## 📊 CSVフォーマット

```csv
イベントID,イベント名,説明,日時,場所,イベントメモ,参加者名,メールアドレス,出欠ステータス,参加者メモ,回答日時
event_001,定例会議,毎週の定例会議,2025/01/15 10:00,会議室A,議題を事前に共有,山田太郎,yamada@example.com,出席,資料準備済み,2025/01/10 09:30
```

## 🔧 プロジェクト構造

```
lib/
├── main.dart                    # アプリエントリーポイント
├── models/
│   └── event.dart              # データモデル
├── services/
│   ├── event_service.dart      # データサービス
│   └── csv_service.dart        # CSV変換サービス
├── providers/
│   └── event_provider.dart     # 状態管理
├── screens/
│   ├── event_list_screen.dart  # イベント一覧画面
│   ├── event_detail_screen.dart # イベント詳細画面
│   └── event_form_screen.dart   # イベント作成/編集画面
└── utils/
    └── file_helper.dart         # ファイル操作ヘルパー
```

## 📱 対応プラットフォーム

- ✅ **Web**: Chrome、Firefox、Safari、Edge
- ✅ **Android**: Android 5.0以降（今後APKビルド対応予定）
- ✅ **iOS**: iOS 12.0以降（今後対応予定）
- ✅ **PC**: Windows、macOS、Linux（Webブラウザ経由）

## 🚀 今後の拡張予定

1. 認証機能（ユーザーログインと権限管理）
2. 通知機能（イベントリマインダー）
3. カレンダー連携（Googleカレンダー等との同期）
4. エクスポート機能の強化（Excel形式）
5. テンプレート機能（よく使うイベントのテンプレート保存）
6. 検索機能（イベント名や参加者名での検索）
7. 統計機能（出席率などの統計表示）
8. ダークモード対応
9. Android APKビルド対応
10. iOS対応

## 🤝 コントリビューション

コントリビューションを歓迎します！

1. このリポジトリをフォーク
2. 新しいブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 👤 作成者

seyaytua - [GitHub](https://github.com/seyaytua)

## 🙏 謝辞

- Flutter開発チーム
- Hiveパッケージ開発者
- すべてのコントリビューター

---

**Roster Share** - シンプルで使いやすい出欠確認アプリ
