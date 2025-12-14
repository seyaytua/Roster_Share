import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/event_service.dart';
import 'services/contact_service.dart';
import 'providers/event_provider.dart';
import 'providers/contact_provider.dart';
import 'screens/event_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final eventService = EventService();
  await eventService.init();
  
  final contactService = ContactService();
  await contactService.init();
  
  runApp(MyApp(
    eventService: eventService,
    contactService: contactService,
  ));
}

class MyApp extends StatelessWidget {
  final EventService eventService;
  final ContactService contactService;

  const MyApp({
    super.key,
    required this.eventService,
    required this.contactService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider(eventService)),
        ChangeNotifierProvider(create: (_) => ContactProvider(contactService)),
      ],
      child: MaterialApp(
        title: 'Roster Share',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          // Minimalist theme
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFFE0E0E0),
            thickness: 1,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
        home: const EventListScreen(),
      ),
    );
  }
}
