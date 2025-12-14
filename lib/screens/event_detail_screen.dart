import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import '../services/csv_service.dart';
import '../utils/file_helper.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        final event = provider.getEventById(eventId);

        if (event == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('イベント詳細'),
            ),
            body: const Center(
              child: Text('イベントが見つかりません'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('イベント詳細'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventFormScreen(event: event),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _showShareDialog(context, event),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, event.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EventHeader(event: event),
                const Divider(),
                _EventNotes(event: event),
                const Divider(),
                _ParticipantsList(event: event),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エクスポート・共有'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('CSVダウンロード'),
                subtitle: const Text('ローカルに保存'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadCsv(context, event);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cloud_queue),
                title: const Text('Google Drive'),
                subtitle: const Text('CSVをダウンロードしてアップロード'),
                onTap: () {
                  Navigator.pop(context);
                  _shareToGoogleDrive(context, event);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('OneDrive'),
                subtitle: const Text('CSVをダウンロードしてアップロード'),
                onTap: () {
                  Navigator.pop(context);
                  _shareToOneDrive(context, event);
                },
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('SharePoint'),
                subtitle: const Text('CSVをダウンロードしてアップロード'),
                onTap: () {
                  Navigator.pop(context);
                  _shareToSharePoint(context, event);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _downloadCsv(BuildContext context, Event event) {
    try {
      final csvService = CsvService();
      final csvContent = csvService.exportEventToCsv(event);
      final filename = '${event.title}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      
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
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }

  void _shareToGoogleDrive(BuildContext context, Event event) {
    // First download the CSV
    _downloadCsv(context, event);
    
    // Then open Google Drive
    Future.delayed(const Duration(milliseconds: 500), () {
      FileHelper.openUrlInNewTab('https://drive.google.com/drive/my-drive');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSVファイルをダウンロードしました。Google Driveにアップロードしてください。'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }

  void _shareToOneDrive(BuildContext context, Event event) {
    // First download the CSV
    _downloadCsv(context, event);
    
    // Then open OneDrive
    Future.delayed(const Duration(milliseconds: 500), () {
      FileHelper.openUrlInNewTab('https://onedrive.live.com/');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSVファイルをダウンロードしました。OneDriveにアップロードしてください。'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }

  void _shareToSharePoint(BuildContext context, Event event) {
    // First download the CSV
    _downloadCsv(context, event);
    
    // Then open SharePoint
    Future.delayed(const Duration(milliseconds: 500), () {
      FileHelper.openUrlInNewTab('https://www.office.com/launch/sharepoint');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSVファイルをダウンロードしました。SharePointにアップロードしてください。'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }

  void _confirmDelete(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このイベントを削除しますか?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<EventProvider>().deleteEvent(eventId);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

class _EventHeader extends StatelessWidget {
  final Event event;

  const _EventHeader({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日 (E) HH:mm', 'ja_JP');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today,
            text: dateFormat.format(event.dateTime),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: event.location,
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _EventNotes extends StatelessWidget {
  final Event event;

  const _EventNotes({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'イベントメモ',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editEventNotes(context, event),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.notes?.isEmpty ?? true ? 'メモなし' : event.notes!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _editEventNotes(BuildContext context, Event event) {
    final controller = TextEditingController(text: event.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('イベントメモ'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'メモを入力',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<EventProvider>().updateEventNotes(
                    eventId: event.id,
                    notes: controller.text,
                  );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsList extends StatelessWidget {
  final Event event;

  const _ParticipantsList({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '参加者 (${event.participants.length})',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...event.participants.map((participant) =>
              _ParticipantItem(event: event, participant: participant)),
        ],
      ),
    );
  }
}

class _ParticipantItem extends StatelessWidget {
  final Event event;
  final Participant participant;

  const _ParticipantItem({
    required this.event,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      participant.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _StatusButton(event: event, participant: participant),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  participant.notes?.isEmpty ?? true
                      ? 'メモなし'
                      : participant.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.note_add, size: 20),
                onPressed: () =>
                    _editParticipantNotes(context, event, participant),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _editParticipantNotes(
      BuildContext context, Event event, Participant participant) {
    final controller = TextEditingController(text: participant.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${participant.name}のメモ'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'メモを入力',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<EventProvider>().updateParticipantNotes(
                    eventId: event.id,
                    participantId: participant.id,
                    notes: controller.text,
                  );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final Event event;
  final Participant participant;

  const _StatusButton({required this.event, required this.participant});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AttendanceStatus>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getStatusIcon(participant.status),
            const SizedBox(width: 4),
            Text(
              _getStatusText(participant.status),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      onSelected: (status) {
        context.read<EventProvider>().updateParticipantStatus(
              eventId: event.id,
              participantId: participant.id,
              status: status,
            );
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AttendanceStatus.attending,
          child: Row(
            children: [
              _getStatusIcon(AttendanceStatus.attending),
              const SizedBox(width: 8),
              const Text('出席'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AttendanceStatus.declined,
          child: Row(
            children: [
              _getStatusIcon(AttendanceStatus.declined),
              const SizedBox(width: 8),
              const Text('欠席'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AttendanceStatus.pending,
          child: Row(
            children: [
              _getStatusIcon(AttendanceStatus.pending),
              const SizedBox(width: 8),
              const Text('保留'),
            ],
          ),
        ),
      ],
    );
  }

  Icon _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.attending:
        return const Icon(Icons.check_circle_outline, size: 18);
      case AttendanceStatus.declined:
        return const Icon(Icons.cancel_outlined, size: 18);
      case AttendanceStatus.pending:
        return const Icon(Icons.help_outline, size: 18);
    }
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
}
