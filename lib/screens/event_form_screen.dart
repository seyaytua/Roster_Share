import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/event_provider.dart';
import '../providers/contact_provider.dart';
import '../models/event.dart';
import '../models/contact.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  final List<_ParticipantForm> _participants = [];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _selectedDate = widget.event!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.dateTime);
      
      for (var p in widget.event!.participants) {
        _participants.add(_ParticipantForm(
          id: p.id,
          nameController: TextEditingController(text: p.name),
          emailController: TextEditingController(text: p.email),
          classNameController: TextEditingController(text: p.className ?? ''),
        ));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    for (var p in _participants) {
      p.nameController.dispose();
      p.emailController.dispose();
      p.classNameController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? '新規イベント' : 'イベント編集'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'イベント名',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'イベント名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('日付'),
              subtitle: Text(
                '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
              ),
              onTap: _selectDate,
            ),

            // Time
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('時刻'),
              subtitle: Text(
                '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              ),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '場所',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Participants section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '参加者',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _selectFromContactList,
                      icon: const Icon(Icons.contacts),
                      label: const Text('リストから選択'),
                    ),
                    TextButton.icon(
                      onPressed: _addParticipant,
                      icon: const Icon(Icons.add),
                      label: const Text('手動追加'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Participants list
            ..._participants.asMap().entries.map((entry) {
              final index = entry.key;
              final participant = entry.value;
              return _ParticipantFormWidget(
                participant: participant,
                onRemove: () => _removeParticipant(index),
              );
            }),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectFromContactList() async {
    final contactProvider = context.read<ContactProvider>();
    await contactProvider.loadContacts();

    if (!mounted) return;

    final selected = await showDialog<List<Contact>>(
      context: context,
      builder: (context) => _ContactSelectionDialog(
        contacts: contactProvider.contacts,
        alreadySelected: _participants.map((p) => p.emailController.text).toList(),
      ),
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        for (var contact in selected) {
          _participants.add(_ParticipantForm(
            id: const Uuid().v4(),
            nameController: TextEditingController(text: contact.name),
            emailController: TextEditingController(text: contact.email),
            classNameController: TextEditingController(text: contact.className ?? ''),
          ));
        }
      });
    }
  }

  void _addParticipant() {
    setState(() {
      _participants.add(_ParticipantForm(
        id: const Uuid().v4(),
        nameController: TextEditingController(),
        emailController: TextEditingController(),
        classNameController: TextEditingController(),
      ));
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants[index].nameController.dispose();
      _participants[index].emailController.dispose();
      _participants[index].classNameController.dispose();
      _participants.removeAt(index);
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('参加者を少なくとも1人追加してください')),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final participants = _participants.map((p) {
      return Participant(
        id: p.id,
        name: p.nameController.text,
        email: p.emailController.text,
        className: p.classNameController.text.isEmpty ? null : p.classNameController.text,
        status: AttendanceStatus.pending,
      );
    }).toList();

    final event = Event(
      id: widget.event?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      dateTime: dateTime,
      location: _locationController.text,
      participants: participants,
      notes: widget.event?.notes,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.event == null) {
        await context.read<EventProvider>().addEvent(event);
      } else {
        await context.read<EventProvider>().updateEvent(event);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }
}

class _ParticipantForm {
  final String id;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController classNameController;

  _ParticipantForm({
    required this.id,
    required this.nameController,
    required this.emailController,
    required this.classNameController,
  });
}

class _ContactSelectionDialog extends StatefulWidget {
  final List<Contact> contacts;
  final List<String> alreadySelected;

  const _ContactSelectionDialog({
    required this.contacts,
    required this.alreadySelected,
  });

  @override
  State<_ContactSelectionDialog> createState() => _ContactSelectionDialogState();
}

class _ContactSelectionDialogState extends State<_ContactSelectionDialog> {
  final Set<String> _selectedEmails = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredContacts = widget.contacts.where((contact) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return contact.name.toLowerCase().contains(query) ||
          contact.email.toLowerCase().contains(query);
    }).toList();

    return AlertDialog(
      title: const Text('参加者を選択'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '検索',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredContacts.isEmpty
                  ? const Center(child: Text('参加者リストが空です'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        final isAlreadyAdded = widget.alreadySelected.contains(contact.email);
                        final isSelected = _selectedEmails.contains(contact.email);

                        return CheckboxListTile(
                          value: isSelected,
                          enabled: !isAlreadyAdded,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedEmails.add(contact.email);
                              } else {
                                _selectedEmails.remove(contact.email);
                              }
                            });
                          },
                          title: Text(contact.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contact.email),
                              if (isAlreadyAdded)
                                const Text(
                                  '既に追加済み',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            final selected = widget.contacts
                .where((c) => _selectedEmails.contains(c.email))
                .toList();
            Navigator.pop(context, selected);
          },
          child: Text('選択 (${_selectedEmails.length})'),
        ),
      ],
    );
  }
}

class _ParticipantFormWidget extends StatelessWidget {
  final _ParticipantForm participant;
  final VoidCallback onRemove;

  const _ParticipantFormWidget({
    required this.participant,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: participant.nameController,
                    decoration: const InputDecoration(
                      labelText: '名前',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '名前を入力';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: participant.classNameController,
              decoration: const InputDecoration(
                labelText: 'クラス (任意)',
                hintText: '例: 3年A組',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: participant.emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力';
                }
                if (!value.contains('@')) {
                  return '有効なメールアドレスを入力';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
