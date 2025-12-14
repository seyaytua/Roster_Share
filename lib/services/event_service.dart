import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event.dart';

class EventService {
  static const String _eventsBoxName = 'events';
  late Box<String> _eventsBox;

  // Initialize Hive and open box
  Future<void> init() async {
    await Hive.initFlutter();
    _eventsBox = await Hive.openBox<String>(_eventsBoxName);
  }

  // Get all events
  Future<List<Event>> getAllEvents() async {
    final List<Event> events = [];
    
    for (var key in _eventsBox.keys) {
      final jsonString = _eventsBox.get(key);
      if (jsonString != null) {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        events.add(Event.fromMap(map));
      }
    }
    
    // Sort by date (newest first)
    events.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    return events;
  }

  // Get event by ID
  Future<Event?> getEvent(String id) async {
    final jsonString = _eventsBox.get(id);
    if (jsonString == null) return null;
    
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return Event.fromMap(map);
  }

  // Save event (create or update)
  Future<void> saveEvent(Event event) async {
    event.updatedAt = DateTime.now();
    final jsonString = jsonEncode(event.toMap());
    await _eventsBox.put(event.id, jsonString);
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
  }

  // Update participant status
  Future<void> updateParticipantStatus({
    required String eventId,
    required String participantId,
    required AttendanceStatus status,
  }) async {
    final event = await getEvent(eventId);
    if (event == null) return;

    final participantIndex =
        event.participants.indexWhere((p) => p.id == participantId);
    if (participantIndex == -1) return;

    event.participants[participantIndex].status = status;
    event.participants[participantIndex].respondedAt = DateTime.now();

    await saveEvent(event);
  }

  // Update participant notes
  Future<void> updateParticipantNotes({
    required String eventId,
    required String participantId,
    required String notes,
  }) async {
    final event = await getEvent(eventId);
    if (event == null) return;

    final participantIndex =
        event.participants.indexWhere((p) => p.id == participantId);
    if (participantIndex == -1) return;

    event.participants[participantIndex].notes = notes;

    await saveEvent(event);
  }

  // Update event notes
  Future<void> updateEventNotes({
    required String eventId,
    required String notes,
  }) async {
    final event = await getEvent(eventId);
    if (event == null) return;

    event.notes = notes;
    await saveEvent(event);
  }

  // Clear all events (for testing)
  Future<void> clearAll() async {
    await _eventsBox.clear();
  }
}
