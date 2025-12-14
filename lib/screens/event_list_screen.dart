import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../providers/event_provider.dart';
import '../models/event.dart';
import '../services/csv_service.dart';
import '../services/sample_data_service.dart';
import '../utils/file_helper.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';
import 'filter_dialog.dart';
import 'contact_list_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String? _searchText;
  AttendanceStatus? _statusFilter;
  DateTime? _dateFilter;

  @override
  void initState() {
    super.initState();
    // Load events after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  List<Event> _applyFilters(List<Event> events) {
    var filteredEvents = events;

    // Filter by search text (event name or participant name)
    if (_searchText != null && _searchText!.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        // Search in event title
        if (event.title.toLowerCase().contains(_searchText!.toLowerCase())) {
          return true;
        }
        // Search in event location
        if (event.location.toLowerCase().contains(_searchText!.toLowerCase())) {
          return true;
        }
        // Search in participant names
        for (var participant in event.participants) {
          if (participant.name.toLowerCase().contains(_searchText!.toLowerCase())) {
            return true;
          }
          if (participant.email.toLowerCase().contains(_searchText!.toLowerCase())) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    // Filter by attendance status
    if (_statusFilter != null) {
      filteredEvents = filteredEvents.where((event) {
        return event.participants.any((p) => p.status == _statusFilter);
      }).toList();
    }

    // Filter by date
    if (_dateFilter != null) {
      filteredEvents = filteredEvents.where((event) {
        return event.dateTime.year == _dateFilter!.year &&
            event.dateTime.month == _dateFilter!.month &&
            event.dateTime.day == _dateFilter!.day;
      }).toList();
    }

    return filteredEvents;
  }

  bool get _hasActiveFilters =>
      _searchText != null || _statusFilter != null || _dateFilter != null;

  void _showFilterDialog() async {
    final result = await showDialog<FilterResult>(
      context: context,
      builder: (context) => FilterDialog(
        currentSearchText: _searchText,
        currentStatusFilter: _statusFilter,
        currentDateFilter: _dateFilter,
      ),
    );

    if (result != null) {
      setState(() {
        _searchText = result.searchText;
        _statusFilter = result.statusFilter;
        _dateFilter = result.dateFilter;
      });
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

  Future<void> _loadSampleData(BuildContext context) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('サンプルデータ読み込み'),
        content: const Text(
          'サンプルイベントを8件追加します。\n'
          'デモや動作確認に便利です。\n\n'
          '続行しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('読み込む'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // デバッグ: サンプルデータ生成開始
      if (kDebugMode) {
        debugPrint('🔥 サンプルデータ生成を開始します...');
      }
      
      final sampleEvents = SampleDataService.generateSampleEvents();
      
      if (kDebugMode) {
        debugPrint('✅ ${sampleEvents.length}件のイベントを生成しました');
      }
      
      for (var event in sampleEvents) {
        if (kDebugMode) {
          debugPrint('📝 イベント追加中: ${event.title}');
        }
        await context.read<EventProvider>().addEvent(event);
      }

      if (kDebugMode) {
        debugPrint('✅ 全イベントの追加が完了しました');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sampleEvents.length}件のサンプルイベントを追加しました'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ エラー発生: $e');
        debugPrint('スタックトレース: $stackTrace');
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
      final filename = 'roster_share_all_events_${DateFormat('yyyyMMdd_HHmmss', 'ja_JP').format(DateTime.now())}.csv';
      
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
            icon: Badge(
              isLabelVisible: _hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'フィルター',
            onPressed: _showFilterDialog,
          ),
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
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'サンプルデータ読み込み',
            onPressed: () => _loadSampleData(context),
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

          // Apply filters
          final filteredEvents = _applyFilters(provider.events);

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
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _loadSampleData(context),
                    icon: const Icon(Icons.auto_awesome, size: 28),
                    label: const Text(
                      'サンプルデータを読み込む',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            );
          }

          if (filteredEvents.isEmpty && _hasActiveFilters) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.filter_list_off,
                    size: 64,
                    color: Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '条件に一致するイベントがありません',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchText = null;
                        _statusFilter = null;
                        _dateFilter = null;
                      });
                    },
                    child: const Text('フィルターをクリア'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter chips display
              if (_hasActiveFilters)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_searchText != null)
                        Chip(
                          label: Text('検索: $_searchText'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _searchText = null;
                            });
                          },
                        ),
                      if (_statusFilter != null)
                        Chip(
                          label: Text('ステータス: ${_getStatusText(_statusFilter!)}'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _statusFilter = null;
                            });
                          },
                        ),
                      if (_dateFilter != null)
                        Chip(
                          label: Text(
                            '日付: ${_dateFilter!.year}/${_dateFilter!.month}/${_dateFilter!.day}',
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _dateFilter = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredEvents.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return _EventListItem(event: event);
                  },
                ),
              ),
            ],
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
