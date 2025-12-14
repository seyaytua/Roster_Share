import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _contactService;
  List<Contact> _contacts = [];
  bool _isLoading = false;
  String? _error;

  ContactProvider(this._contactService);

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all contacts
  Future<void> loadContacts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contacts = await _contactService.getAllContacts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new contact
  Future<void> addContact(Contact contact) async {
    try {
      await _contactService.saveContact(contact);
      await loadContacts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update contact
  Future<void> updateContact(Contact contact) async {
    try {
      await _contactService.saveContact(contact);
      await loadContacts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete contact
  Future<void> deleteContact(String id) async {
    try {
      await _contactService.deleteContact(id);
      await loadContacts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Search contacts
  Future<List<Contact>> searchContacts(String query) async {
    try {
      return await _contactService.searchContacts(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get contact by ID
  Contact? getContactById(String id) {
    try {
      return _contacts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
