import 'package:flutter/material.dart';
import 'package:orpt/components/components.dart';
import 'package:orpt/patients/patient_appointments_screen.dart';
import 'package:orpt/data/appointments_provider.dart';

class PatientSearchScreen extends StatefulWidget {
  final AppointmentProvider appointmentProvider;
  const PatientSearchScreen({super.key, required this.appointmentProvider});

  @override
  State<StatefulWidget> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<String>>(
      future: widget.appointmentProvider.fetchPatients(),
      builder: (BuildContext context, AsyncSnapshot<Set<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Search Patients'),
            ),
            body: const CircularProgressIndicator(),
            bottomNavigationBar: navigationBar(context),
          );
        } else if (snapshot.hasError) {
          throw snapshot.error!;
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Search Patients'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor(
                  builder: (context, controller) {
                    return SearchBar(
                      controller: controller,
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0)),
                      onTap: ()=>controller.openView(),
                      onChanged: (_)=>controller.openView(),
                      leading: const Icon(Icons.search),
                    );
                  },
                  suggestionsBuilder: (context, controller) {
                    var patients = snapshot.data!.where((patient) => patient
                        .toLowerCase()
                        .contains(controller.text.toLowerCase()));
                    return List<ListTile>.generate(
                        patients.length,
                        (int index) => ListTile(
                              title: Text(patients.elementAt(index)),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PatientAppointmentsListScreen(
                                              appointmentProvider:
                                                  widget.appointmentProvider,
                                              patient:
                                                  patients.elementAt(index)))),
                            ));
                  }),
            ),
            bottomNavigationBar: navigationBar(context, selected: 'patients'),
          );
        }
      },
    );
  }
}
