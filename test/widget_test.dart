import 'package:flutter_test/flutter_test.dart';

import 'package:roster_share/main.dart';
import 'package:roster_share/services/event_service.dart';
import 'package:roster_share/services/contact_service.dart';

void main() {
  testWidgets('Roster Share app loads', (WidgetTester tester) async {
    // Initialize services
    final eventService = EventService();
    await eventService.init();
    
    final contactService = ContactService();
    await contactService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      eventService: eventService,
      contactService: contactService,
    ));

    // Verify that app title is displayed
    expect(find.text('Roster Share'), findsOneWidget);
  });
}
