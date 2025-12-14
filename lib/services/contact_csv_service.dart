import 'package:csv/csv.dart';
import '../models/contact.dart';

class ContactCsvService {
  // Export contacts to CSV format
  String exportContactsToCsv(List<Contact> contacts) {
    List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      '名前',
      'メールアドレス',
      '電話番号',
      '組織',
      'メモ',
    ]);

    // Data rows
    for (var contact in contacts) {
      rows.add([
        contact.name,
        contact.email,
        contact.phone ?? '',
        contact.organization ?? '',
        contact.notes ?? '',
      ]);
    }

    // Convert to CSV string
    return const ListToCsvConverter().convert(rows);
  }

  // Import contacts from CSV string
  List<Contact> importContactsFromCsv(String csvString) {
    final List<List<dynamic>> rows =
        const CsvToListConverter().convert(csvString);

    if (rows.isEmpty) {
      throw Exception('CSVファイルが空です');
    }

    // Skip header row
    final dataRows = rows.skip(1);

    List<Contact> contacts = [];

    for (var row in dataRows) {
      if (row.length < 2) continue; // Name and email are required

      final name = row[0].toString().trim();
      final email = row[1].toString().trim();

      if (name.isEmpty || email.isEmpty) continue;

      contacts.add(Contact(
        id: DateTime.now().millisecondsSinceEpoch.toString() + email,
        name: name,
        email: email,
        phone: row.length > 2 ? row[2].toString().trim() : null,
        organization: row.length > 3 ? row[3].toString().trim() : null,
        notes: row.length > 4 ? row[4].toString().trim() : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    return contacts;
  }
}
