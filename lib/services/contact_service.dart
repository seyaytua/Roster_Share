import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';

class ContactService {
  static const String _contactsBoxName = 'contacts';
  late Box<String> _contactsBox;

  // Initialize Hive and open box
  Future<void> init() async {
    _contactsBox = await Hive.openBox<String>(_contactsBoxName);
  }

  // Get all contacts
  Future<List<Contact>> getAllContacts() async {
    final List<Contact> contacts = [];
    
    for (var key in _contactsBox.keys) {
      final jsonString = _contactsBox.get(key);
      if (jsonString != null) {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        contacts.add(Contact.fromMap(map));
      }
    }
    
    // Sort by name
    contacts.sort((a, b) => a.name.compareTo(b.name));
    
    return contacts;
  }

  // Get contact by ID
  Future<Contact?> getContact(String id) async {
    final jsonString = _contactsBox.get(id);
    if (jsonString == null) return null;
    
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return Contact.fromMap(map);
  }

  // Save contact (create or update)
  Future<void> saveContact(Contact contact) async {
    contact.updatedAt = DateTime.now();
    final jsonString = jsonEncode(contact.toMap());
    await _contactsBox.put(contact.id, jsonString);
  }

  // Delete contact
  Future<void> deleteContact(String id) async {
    await _contactsBox.delete(id);
  }

  // Search contacts by name or email
  Future<List<Contact>> searchContacts(String query) async {
    final allContacts = await getAllContacts();
    final lowerQuery = query.toLowerCase();
    
    return allContacts.where((contact) {
      return contact.name.toLowerCase().contains(lowerQuery) ||
          contact.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Clear all contacts (for testing)
  Future<void> clearAll() async {
    await _contactsBox.clear();
  }
}
