import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class CsvService {
  // Export events to CSV format
  String exportEventsToCsv(List<Event> events) {
    List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'イベントID',
      'イベント名',
      '説明',
      '日時',
      '場所',
      'イベントメモ',
      '参加者名',
      'クラス',
      'メールアドレス',
      '出欠ステータス',
      '参加者メモ',
      '回答日時',
    ]);

    // Data rows
    for (var event in events) {
      final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja_JP');

      if (event.participants.isEmpty) {
        // Event with no participants
        rows.add([
          event.id,
          event.title,
          event.description,
          dateFormat.format(event.dateTime),
          event.location,
          event.notes ?? '',
          '',
          '',
          '',
          '',
          '',
          '',
        ]);
      } else {
        // Event with participants (one row per participant)
        for (var participant in event.participants) {
          rows.add([
            event.id,
            event.title,
            event.description,
            dateFormat.format(event.dateTime),
            event.location,
            event.notes ?? '',
            participant.name,
            participant.className ?? '',
            participant.email,
            _getStatusText(participant.status),
            participant.notes ?? '',
            participant.respondedAt != null
                ? dateFormat.format(participant.respondedAt!)
                : '',
          ]);
        }
      }
    }

    // Convert to CSV string
    return const ListToCsvConverter().convert(rows);
  }

  // Export single event to CSV format
  String exportEventToCsv(Event event) {
    return exportEventsToCsv([event]);
  }

  // Import events from CSV string
  List<Event> importEventsFromCsv(String csvString) {
    final List<List<dynamic>> rows =
        const CsvToListConverter().convert(csvString);

    if (rows.isEmpty) {
      throw Exception('CSVファイルが空です');
    }

    // Skip header row
    final dataRows = rows.skip(1);

    // Group by event ID
    Map<String, _EventBuilder> eventBuilders = {};

    for (var row in dataRows) {
      if (row.length < 12) continue;

      final eventId = row[0].toString();
      final eventTitle = row[1].toString();
      final eventDescription = row[2].toString();
      final eventDateTime = DateFormat('yyyy/MM/dd HH:mm', 'ja_JP').parse(row[3].toString());
      final eventLocation = row[4].toString();
      final eventNotes = row[5].toString();

      if (!eventBuilders.containsKey(eventId)) {
        eventBuilders[eventId] = _EventBuilder(
          id: eventId,
          title: eventTitle,
          description: eventDescription,
          dateTime: eventDateTime,
          location: eventLocation,
          notes: eventNotes.isEmpty ? null : eventNotes,
        );
      }

      // Add participant if exists
      final participantName = row[6].toString();
      if (participantName.isNotEmpty) {
        final participantClassName = row[7].toString();
        final participantEmail = row[8].toString();
        final statusText = row[9].toString();
        final participantNotes = row[10].toString();
        final respondedAtText = row[11].toString();

        eventBuilders[eventId]!.participants.add(Participant(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              participantEmail,
          name: participantName,
          email: participantEmail,
          className: participantClassName.isEmpty ? null : participantClassName,
          status: _parseStatusText(statusText),
          notes: participantNotes.isEmpty ? null : participantNotes,
          respondedAt: respondedAtText.isEmpty
              ? null
              : DateFormat('yyyy/MM/dd HH:mm', 'ja_JP').parse(respondedAtText),
        ));
      }
    }

    return eventBuilders.values.map((builder) => builder.build()).toList();
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.attending:
        return '出席';
      case AttendanceStatus.declined:
        return '欠席';
      case AttendanceStatus.pending:
        return '保留';
    }
  }

  AttendanceStatus _parseStatusText(String text) {
    switch (text) {
      case '出席':
        return AttendanceStatus.attending;
      case '欠席':
        return AttendanceStatus.declined;
      case '保留':
      default:
        return AttendanceStatus.pending;
    }
  }
}

class _EventBuilder {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String? notes;
  final List<Participant> participants = [];

  _EventBuilder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.notes,
  });

  Event build() {
    return Event(
      id: id,
      title: title,
      description: description,
      dateTime: dateTime,
      location: location,
      participants: participants,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
