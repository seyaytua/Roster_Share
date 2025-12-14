import 'package:flutter/material.dart';
import '../models/event.dart';

class FilterDialog extends StatefulWidget {
  final String? currentSearchText;
  final AttendanceStatus? currentStatusFilter;
  final DateTime? currentDateFilter;

  const FilterDialog({
    super.key,
    this.currentSearchText,
    this.currentStatusFilter,
    this.currentDateFilter,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _searchController;
  AttendanceStatus? _selectedStatus;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.currentSearchText);
    _selectedStatus = widget.currentStatusFilter;
    _selectedDate = widget.currentDateFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('フィルター'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search by text
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'イベント名・参加者名で検索',
                hintText: 'キーワードを入力',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Filter by attendance status
            const Text(
              '出欠ステータス',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('すべて'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('出席'),
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  selected: _selectedStatus == AttendanceStatus.attending,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? AttendanceStatus.attending : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('欠席'),
                  avatar: const Icon(Icons.cancel_outlined, size: 18),
                  selected: _selectedStatus == AttendanceStatus.declined,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? AttendanceStatus.declined : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('保留'),
                  avatar: const Icon(Icons.help_outline, size: 18),
                  selected: _selectedStatus == AttendanceStatus.pending,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? AttendanceStatus.pending : null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter by date
            const Text(
              '日付',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDate == null
                          ? '日付を選択'
                          : '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}',
                    ),
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset all filters
            setState(() {
              _searchController.clear();
              _selectedStatus = null;
              _selectedDate = null;
            });
            Navigator.pop(context, FilterResult(
              searchText: null,
              statusFilter: null,
              dateFilter: null,
            ));
          },
          child: const Text('リセット'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, FilterResult(
              searchText: _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
              statusFilter: _selectedStatus,
              dateFilter: _selectedDate,
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text('適用'),
        ),
      ],
    );
  }
}

class FilterResult {
  final String? searchText;
  final AttendanceStatus? statusFilter;
  final DateTime? dateFilter;

  FilterResult({
    this.searchText,
    this.statusFilter,
    this.dateFilter,
  });

  bool get hasActiveFilters =>
      searchText != null || statusFilter != null || dateFilter != null;
}
