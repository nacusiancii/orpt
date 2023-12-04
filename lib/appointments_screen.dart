import 'package:flutter/material.dart';
import 'package:orpt/data/appointments_provider.dart';
import 'package:provider/provider.dart';

import 'appointment.dart';
import 'appointment_details_screen.dart';
import 'common/date_utils.dart' as du;
import 'new_appointments_screen.dart';
import 'components/components.dart' as components;

class AppointmentsListScreen extends StatelessWidget {
  final AppointmentProvider appointmentProvider;
  final DateTime selectedDay;

  const AppointmentsListScreen(
      {super.key,
      required this.appointmentProvider,
      required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(du.formatIndianDate(selectedDay)),
      ),
      body: Consumer<AppointmentProvider>(
        // Use Consumer widget
        builder: (context, appointmentProvider, child) {
          return FutureBuilder<List<List<Appointment>>>(
            future: appointmentProvider.fetchAppointmentsByDate(selectedDay),
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

                return Column(
                  children: [
                    _buildSection(
                        context, 'Active Appointments', activeAppointments),
                    _buildSection(context, 'Completed Appointments',
                        completedAppointments),
                    _buildSection(
                        context, 'Canceled Appointments', canceledAppointments),
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
                selectedDay: selectedDay,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: components.navigationBar(context),
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
            title: Text(appointment.name),
            subtitle: Text(appointment.status == AppointmentStatus.done
                ? appointment.treatmentProvided
                : appointment.treatmentScheduled),
            trailing: appointment.status != AppointmentStatus.cancelled
                ? null
                : ElevatedButton(
                    onPressed: () {
                      appointmentProvider.removeAppointment(appointment);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the value to make it more or less rounded
                      ),
                      backgroundColor: Colors.red, // Button color
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.all(10.0), // Adjust the padding as needed
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
}
