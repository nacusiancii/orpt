import 'package:flutter/material.dart';
import 'package:orpt/patients/patient_search_screen.dart';
import 'package:orpt/data/appointments_provider.dart';
import 'package:provider/provider.dart';

import 'calender_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (context) => AppointmentProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    AppointmentProvider appointmentProvider =
        Provider.of<AppointmentProvider>(context);
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routes: {
        '/': (context) => CalendarScreen(
              appointmentProvider: appointmentProvider,
            ),
        '/patients': (context) => PatientSearchScreen(
              appointmentProvider: appointmentProvider,
            ),
      },
    );
  }
}
