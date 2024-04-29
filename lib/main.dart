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
    try{
      AppointmentProvider appointmentProvider =
      Provider.of<AppointmentProvider>(context);
      return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
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
    catch(e){
      return const MaterialApp(
        title: 'Restart App',
           home: Scaffold(
             body: Center(
               child: Text('Error: Try Restarting. If error persists contact developer'),
             ),
           ),
      );
    }
  }
}
