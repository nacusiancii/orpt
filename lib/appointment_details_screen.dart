import 'package:flutter/material.dart';
import 'package:orpt/data/appointments_provider.dart';
import 'package:orpt/edit_appointment_screen.dart';

import 'components/components.dart' as components;
import 'appointment.dart';
import 'common/date_utils.dart' as du;

class AppointmentDetailsScreen extends StatefulWidget {
  final Appointment appointment;
  final AppointmentProvider provider;

  const AppointmentDetailsScreen(
      {super.key, required this.appointment, required this.provider});

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final TextEditingController _treatmentController = TextEditingController();
  final none = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Name: ${widget.appointment.name}'),
          ),
          ListTile(
            title:
                Text('Date: ${du.formatIndianDate(widget.appointment.date)}'),
          ),
          ListTile(
            title: Text('Slot: ${widget.appointment.slot ?? none}'),
          ),
          ListTile(
            title: Text(
                'Scheduled Treatment: ${widget.appointment.treatmentScheduled}'),
          ),
          ListTile(
            title: Text(
                'Treatment Provided: ${widget.appointment.treatmentProvided}'),
          ),
          ListTile(
            title: Text('Status: ${_getStatusText(widget.appointment.status)}'),
          ),
          if (widget.appointment.status == AppointmentStatus.tbd)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showMarkDoneDialog(context);
                  },
                  child: const Text('Mark Done'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showCancelDialog(context);
                  },
                  child: const Text('Cancel Appointment'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditAppointmentScreen(
                              appointmentProvider: widget.provider,
                              appointment: widget.appointment)));
                },
                child: const Text('Edit Appointment'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: components.navigationBar(context),
    );
  }

  Future<void> _showMarkDoneDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark Appointment as Done'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _treatmentController,
                decoration:
                    const InputDecoration(labelText: 'Treatment Provided'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update the appointment status and treatment provided
                  widget.provider
                      .fulfillAppointment(
                    widget.appointment.id,
                    _treatmentController.text,
                  )
                      .then((value) {
                    Navigator.pop(context); // Close the dialog
                    setState(() {
                      widget.appointment.treatmentProvided =
                          _treatmentController.text;
                      widget.appointment.status = AppointmentStatus.done;
                    });
                  });
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content:
              const Text('Are you sure you want to cancel this appointment?'),
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
                widget.provider.cancelAppointment(widget.appointment.id);
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Close the appointment details screen
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _treatmentController.dispose();
    super.dispose();
  }

  String _getStatusText(AppointmentStatus status) {
    if (status == AppointmentStatus.done) {
      return 'Done';
    } else if (status == AppointmentStatus.cancelled) {
      return 'Cancelled';
    } else {
      return 'TBD';
    }
  }
}
