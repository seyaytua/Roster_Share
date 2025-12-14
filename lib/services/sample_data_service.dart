import 'package:uuid/uuid.dart';
import '../models/event.dart';

class SampleDataService {
  static const _uuid = Uuid();

  // サンプルデータを生成
  static List<Event> generateSampleEvents() {
    final now = DateTime.now();

    return [
      // 1. 定例会議
      Event(
        id: _uuid.v4(),
        title: '定例会議',
        description: '週次の定例会議です。進捗報告と今後の予定を確認します。',
        dateTime: DateTime(now.year, now.month, now.day, 10, 0),
        location: '会議室A',
        participants: [
          Participant(
            id: _uuid.v4(),
            name: '山田太郎',
            email: 'yamada@example.com',
            className: '3年A組',
            status: AttendanceStatus.attending,
            notes: '資料準備済み',
            respondedAt: now.subtract(const Duration(days: 1)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '佐藤花子',
            email: 'sato@example.com',
            className: '2年B組',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(days: 1)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '鈴木一郎',
            email: 'suzuki@example.com',
            className: '3年A組',
            status: AttendanceStatus.declined,
            notes: '出張のため欠席',
            respondedAt: now.subtract(const Duration(hours: 12)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '田中美咲',
            email: 'tanaka@example.com',
            className: '1年C組',
            status: AttendanceStatus.pending,
          ),
        ],
        notes: '議題：Q4の目標設定について',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),

      // 2. 新年会
      Event(
        id: _uuid.v4(),
        title: '新年会',
        description: '2025年新年会のお知らせ。親睦を深めましょう！',
        dateTime: DateTime(now.year, 1, 15, 18, 30),
        location: '居酒屋「さくら」',
        participants: [
          Participant(
            id: _uuid.v4(),
            name: '山田太郎',
            email: 'yamada@example.com',
            status: AttendanceStatus.attending,
            notes: '会費準備します',
            respondedAt: now.subtract(const Duration(days: 2)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '佐藤花子',
            email: 'sato@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(days: 2)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '鈴木一郎',
            email: 'suzuki@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(days: 1)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '田中美咲',
            email: 'tanaka@example.com',
            status: AttendanceStatus.pending,
          ),
          Participant(
            id: _uuid.v4(),
            name: '高橋健太',
            email: 'takahashi@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 6)),
          ),
        ],
        notes: '会費：5000円（当日集金）',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),

      // 3. プロジェクトキックオフ
      Event(
        id: _uuid.v4(),
        title: 'プロジェクトキックオフミーティング',
        description: '新規プロジェクトのキックオフ会議。プロジェクト概要と役割分担を決定します。',
        dateTime: DateTime(now.year, now.month, now.day + 2, 14, 0),
        location: '大会議室',
        participants: [
          Participant(
            id: _uuid.v4(),
            name: '山田太郎',
            email: 'yamada@example.com',
            status: AttendanceStatus.attending,
            notes: 'プロジェクト資料作成中',
            respondedAt: now.subtract(const Duration(hours: 3)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '佐藤花子',
            email: 'sato@example.com',
            status: AttendanceStatus.pending,
          ),
          Participant(
            id: _uuid.v4(),
            name: '伊藤誠',
            email: 'ito@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 5)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '渡辺直美',
            email: 'watanabe@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 4)),
          ),
        ],
        notes: 'ノートPC持参のこと',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),

      // 4. 遠足（子供会）
      Event(
        id: _uuid.v4(),
        title: '子供会 春の遠足',
        description: '動物園への遠足です。お弁当持参でお願いします。',
        dateTime: DateTime(now.year, 3, 20, 9, 0),
        location: '市立動物園',
        participants: [
          Participant(
            id: _uuid.v4(),
            name: '山田花子（保護者）',
            email: 'h.yamada@example.com',
            status: AttendanceStatus.attending,
            notes: '付き添い可能',
            respondedAt: now.subtract(const Duration(days: 3)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '佐藤太郎（保護者）',
            email: 't.sato@example.com',
            status: AttendanceStatus.declined,
            notes: '仕事のため欠席',
            respondedAt: now.subtract(const Duration(days: 2)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '鈴木美咲（保護者）',
            email: 'm.suzuki@example.com',
            status: AttendanceStatus.pending,
          ),
          Participant(
            id: _uuid.v4(),
            name: '田中健一（保護者）',
            email: 'k.tanaka@example.com',
            status: AttendanceStatus.attending,
            notes: '車で送迎できます',
            respondedAt: now.subtract(const Duration(days: 1)),
          ),
        ],
        notes: '集合時間厳守！雨天時は延期',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),

      // 5. 技術勉強会
      Event(
        id: _uuid.v4(),
        title: 'Flutter勉強会',
        description: 'Flutter最新機能についての勉強会。実践的なコーディング演習も行います。',
        dateTime: DateTime(now.year, now.month, now.day + 7, 19, 0),
        location: 'オンライン（Zoom）',
        participants: [
          Participant(
            id: _uuid.v4(),
            name: '山田太郎',
            email: 'yamada@example.com',
            status: AttendanceStatus.attending,
            notes: '発表資料準備中',
            respondedAt: now.subtract(const Duration(hours: 8)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '伊藤誠',
            email: 'ito@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 10)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '渡辺直美',
            email: 'watanabe@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 12)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '高橋健太',
            email: 'takahashi@example.com',
            status: AttendanceStatus.pending,
          ),
          Participant(
            id: _uuid.v4(),
            name: '中村良子',
            email: 'nakamura@example.com',
            status: AttendanceStatus.pending,
          ),
        ],
        notes: 'ZoomリンクはSlackで共有します',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),

      // 6. チームランチ
      Event(
        id: _uuid.v4(),
        title: 'チームランチ',
        description: '月例のチームランチ。リラックスして親睦を深めましょう。',
        dateTime: DateTime(now.year, now.month, now.day + 3, 12, 0),
        location: 'イタリアンレストラン「ボーノ」',
        participants: [
          Participant(
            id: _uuid.v4(),
            name: '山田太郎',
            email: 'yamada@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 15)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '佐藤花子',
            email: 'sato@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 14)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '鈴木一郎',
            email: 'suzuki@example.com',
            status: AttendanceStatus.declined,
            notes: 'ミーティングが重なりました',
            respondedAt: now.subtract(const Duration(hours: 10)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '田中美咲',
            email: 'tanaka@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 13)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '高橋健太',
            email: 'takahashi@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(hours: 11)),
          ),
        ],
        notes: '予算：1人1500円程度',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 10)),
      ),

      // 7. 社内運動会
      Event(
        id: _uuid.v4(),
        title: '社内運動会',
        description: '年次恒例の社内運動会。部門対抗戦で盛り上がりましょう！',
        dateTime: DateTime(now.year, 5, 15, 10, 0),
        location: '市民体育館',
        participants: [
          Participant(
            id: _uuid.v4(),
            name: '山田太郎',
            email: 'yamada@example.com',
            status: AttendanceStatus.attending,
            notes: '準備委員',
            respondedAt: now.subtract(const Duration(days: 5)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '佐藤花子',
            email: 'sato@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(days: 4)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '鈴木一郎',
            email: 'suzuki@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(days: 3)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '田中美咲',
            email: 'tanaka@example.com',
            status: AttendanceStatus.pending,
          ),
          Participant(
            id: _uuid.v4(),
            name: '伊藤誠',
            email: 'ito@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(days: 6)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '渡辺直美',
            email: 'watanabe@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(days: 5)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '高橋健太',
            email: 'takahashi@example.com',
            status: AttendanceStatus.pending,
          ),
        ],
        notes: '運動できる服装でお願いします。昼食は提供されます。',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),

      // 8. 保護者会
      Event(
        id: _uuid.v4(),
        title: '第3学期保護者会',
        description: '学年末の保護者会です。成績表の配布と進路相談があります。',
        dateTime: DateTime(now.year, 3, 10, 14, 0),
        location: '○○小学校 3年1組教室',
        participants: [
          Participant(
            id: _uuid.v4(),
            name: '山田花子',
            email: 'h.yamada@example.com',
            status: AttendanceStatus.attending,
            notes: '両親で参加',
            respondedAt: now.subtract(const Duration(days: 4)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '佐藤太郎',
            email: 't.sato@example.com',
            status: AttendanceStatus.attending,
            respondedAt: now.subtract(const Duration(days: 3)),
          ),
          Participant(
            id: _uuid.v4(),
            name: '鈴木美咲',
            email: 'm.suzuki@example.com',
            status: AttendanceStatus.pending,
          ),
          Participant(
            id: _uuid.v4(),
            name: '田中健一',
            email: 'k.tanaka@example.com',
            status: AttendanceStatus.declined,
            notes: '仕事で参加できません',
            respondedAt: now.subtract(const Duration(days: 2)),
          ),
        ],
        notes: '上履き持参のこと',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
