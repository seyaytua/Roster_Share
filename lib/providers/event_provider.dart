import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService;
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  EventProvider(this._eventService);

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all events
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _eventService.getAllEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new event
  Future<void> addEvent(Event event) async {
    try {
      await _eventService.saveEvent(event);
      await loadEvents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update event
  Future<void> updateEvent(Event event) async {
    try {
      await _eventService.saveEvent(event);
      await loadEvents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    try {
      await _eventService.deleteEvent(id);
      await loadEvents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update participant status
  Future<void> updateParticipantStatus({
    required String eventId,
    required String participantId,
    required AttendanceStatus status,
  }) async {
    try {
      await _eventService.updateParticipantStatus(
        eventId: eventId,
        participantId: participantId,
        status: status,
      );
      await loadEvents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update participant notes
  Future<void> updateParticipantNotes({
    required String eventId,
    required String participantId,
    required String notes,
  }) async {
    try {
      await _eventService.updateParticipantNotes(
        eventId: eventId,
        participantId: participantId,
        notes: notes,
      );
      await loadEvents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update event notes
  Future<void> updateEventNotes({
    required String eventId,
    required String notes,
  }) async {
    try {
      await _eventService.updateEventNotes(
        eventId: eventId,
        notes: notes,
      );
      await loadEvents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get event by ID
  Event? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
