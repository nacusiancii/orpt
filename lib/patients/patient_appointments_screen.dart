import 'package:flutter/material.dart';
import 'package:orpt/common/date_utils.dart' as du;
import 'package:orpt/data/appointments_provider.dart';
import 'package:provider/provider.dart';

import '../appointment.dart';
import '../appointment_details_screen.dart';
import '../new_appointments_screen.dart';
import '../components/components.dart' as components;

class PatientAppointmentsListScreen extends StatelessWidget {
  final AppointmentProvider appointmentProvider;
  final String patient;

  const PatientAppointmentsListScreen(
      {super.key, required this.appointmentProvider, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments for $patient'),
      ),
      body: Consumer<AppointmentProvider>(
        // Use Consumer widget
        builder: (context, appointmentProvider, child) {
          return FutureBuilder<List<List<Appointment>>>(
            future: appointmentProvider.fetchAppointmentsByName(patient),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // If the Future is still running, show a loading indicator
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If there is an error, display an error message
                return Text('Error: ${snapshot.error}');
              } else {
                // If the Future is complete, build the UI with the data
                final [
                  activeAppointments,
                  completedAppointments,
                  canceledAppointments
                ] = snapshot.data!;

                return ListView(
                  children: [
                    _buildSection(
                        context, 'Active Appointments', activeAppointments),
                    _buildSection(context, 'Completed Appointments',
                        completedAppointments),
                    _buildSection(
                        context, 'Canceled Appointments', canceledAppointments),
                    ElevatedButton(onPressed: ()=>_showDeletePatientDialog(context, patient), child: const Text("Delete Patient")),
                  ],
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open a screen to create a new appointment
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewAppointmentScreen(
                appointmentProvider: appointmentProvider,
                patientName: patient,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar:
          components.navigationBar(context, selected: 'patients'),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Appointment> appointments) {
    return Column(
      children: [
        if (appointments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        for (final appointment in appointments)
          ListTile(
            title: Text(du.formatIndianDate(appointment.date)),
            subtitle: Text(appointment.status == AppointmentStatus.done
                ? appointment.treatmentProvided
                : appointment.treatmentScheduled),
            trailing: ElevatedButton(
              onPressed: () {
                _showDeleteAppointmentDialog(context, appointment);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      30.0), // Adjust the value to make it more or less rounded
                ),
                backgroundColor: Colors.red, // Button color
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0), // Adjust the padding as needed
                child: Icon(
                  Icons.cancel,
                  color: Colors.white, // Icon color
                  size: 30.0, // Icon size
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsScreen(
                    appointment: appointment,
                    provider: appointmentProvider,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _showDeletePatientDialog(BuildContext context, String patient) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
          const Text('Are you sure you want to permanently delete this patient and all their data?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Cancel the appointment
                appointmentProvider.removePatient(patient);
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushNamed(context, '/patients');// Close the dialog
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAppointmentDialog(BuildContext context, Appointment appointment) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
          const Text('Are you sure you want to delete this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Cancel the appointment
                appointmentProvider.removeAppointment(appointment);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
