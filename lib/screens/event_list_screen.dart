import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../providers/event_provider.dart';
import '../models/event.dart';
import '../services/csv_service.dart';
import '../utils/file_helper.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';
import 'contact_list_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    // Load events after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  Future<void> _importCsv(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ファイルの読み込みに失敗しました')),
          );
        }
        return;
      }

      final csvString = utf8.decode(bytes);
      final csvService = CsvService();
      final events = csvService.importEventsFromCsv(csvString);

      // Import all events
      for (var event in events) {
        await context.read<EventProvider>().addEvent(event);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${events.length}件のイベントをインポートしました')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('インポートエラー: $e')),
        );
      }
    }
  }

  void _exportAllCsv(BuildContext context) {
    try {
      final provider = context.read<EventProvider>();
      
      if (provider.events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('エクスポートするイベントがありません')),
        );
        return;
      }

      final csvService = CsvService();
      final csvContent = csvService.exportEventsToCsv(provider.events);
      final filename = 'roster_share_all_events_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      
      FileHelper.downloadFile(
        content: csvContent,
        filename: filename,
        mimeType: 'text/csv',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$filenameをダウンロードしました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エクスポートエラー: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roster Share'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            tooltip: '参加者リスト',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'イベントインポート',
            onPressed: () => _importCsv(context),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'イベントエクスポート',
            onPressed: () => _exportAllCsv(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EventProvider>().loadEvents();
            },
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'エラーが発生しました',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (provider.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_note,
                    size: 64,
                    color: Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'イベントがありません',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右下の + ボタンから新規作成',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: provider.events.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final event = provider.events[index];
              return _EventListItem(event: event);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final Event event;

  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventId: event.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title
            Text(
              event.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            
            // Date and time
            Text(
              dateFormat.format(event.dateTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            
            // Location
            if (event.location.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                event.location,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            
            const SizedBox(height: 8),
            
            // Attendance summary
            Row(
              children: [
                _AttendanceCount(
                  label: '出席',
                  count: event.attendingCount,
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(width: 16),
                _AttendanceCount(
                  label: '欠席',
                  count: event.declinedCount,
                  icon: Icons.cancel_outlined,
                ),
                const SizedBox(width: 16),
                _AttendanceCount(
                  label: '保留',
                  count: event.pendingCount,
                  icon: Icons.help_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCount extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const _AttendanceCount({
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
