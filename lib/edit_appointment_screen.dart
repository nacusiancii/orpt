import 'package:flutter/material.dart';
import 'package:orpt/appointment_details_screen.dart';
import 'package:orpt/common/date_utils.dart' as du;
import 'package:orpt/data/appointments_provider.dart';
import 'appointment.dart';
import 'components/components.dart' as components;

class EditAppointmentScreen extends StatefulWidget {
  final AppointmentProvider appointmentProvider;
  final Appointment appointment;

  const EditAppointmentScreen(
      {super.key,
      required this.appointmentProvider,
      required this.appointment});
  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _slotController = TextEditingController();
  final _treatmentScheduledController = TextEditingController();
  final _nameSearchController = SearchController();
  final _treatmentPovidedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _nameSearchController.text = widget.appointment.name;
    _dateController.text = du.formatIndianDate(widget.appointment.date);
    _slotController.text = widget.appointment.slot == null
        ? ''
        : widget.appointment.slot.toString();
    _treatmentScheduledController.text = widget.appointment.treatmentScheduled;
    _treatmentPovidedController.text = widget.appointment.treatmentProvided;

    Set<String> patients;
    return FutureBuilder<Set<String>>(
      future: widget.appointmentProvider.fetchPatients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('New Appointment'),
            ),
            body: const CircularProgressIndicator(),
            bottomNavigationBar: components.navigationBar(context),
          );
        } else if (snapshot.hasError) {
          throw Exception(snapshot.error);
        } else {
          patients = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('New Appointment'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SearchAnchor(
                        searchController: _nameSearchController,
                        builder: (context, controller) {
                          return SearchBar(
                            controller: controller,
                            padding: const MaterialStatePropertyAll<EdgeInsets>(
                                EdgeInsets.symmetric(horizontal: 16.0)),
                            onTap: () => controller.openView(),
                            onChanged: (_) => controller.openView(),
                            onSubmitted: (selectedText) => controller.closeView(selectedText),
                            leading: const Icon(Icons.search),
                          );
                        },
                        suggestionsBuilder: (context, controller) {
                          var relatedPatients = patients.where((patient) =>
                              patient
                                  .toLowerCase()
                                  .contains(controller.text.toLowerCase()));
                          return List<ListTile>.generate(
                              patients.length,
                              (int index) => ListTile(
                                    title:
                                        Text(relatedPatients.elementAt(index)),
                                    onTap: () => controller.closeView(
                                        relatedPatients.elementAt(index)),
                                  ));
                        }),
                    TextFormField(
                      controller: _dateController,
                      decoration:
                          const InputDecoration(labelText: 'Date (DD-MM-YYYY)'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a date';
                        }
                        if (value.length != 10) {
                          return 'Please enter a valid date';
                        }
                        try {
                          DateTime.parse(du.formatIndianToUsDate(value));
                        } on FormatException catch (_) {
                          return 'Please enter a valid date';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _slotController,
                      decoration:
                          const InputDecoration(labelText: 'Treatment Slot'),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _treatmentScheduledController,
                      decoration: const InputDecoration(
                          labelText: 'Treatment Scheduled'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the treatment scheduled';
                        }
                        return null;
                      },
                    ),
                    (widget.appointment.status != AppointmentStatus.done)
                        ? const Padding(padding: EdgeInsets.all(0))
                        : TextFormField(
                            controller: _treatmentPovidedController,
                            decoration: const InputDecoration(
                                labelText: 'Treatment Provided'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter the treatment scheduled';
                              }
                              return null;
                            },
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Cancel button action, navigate back to the previous screen
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Submit button action
                            if (_formKey.currentState!.validate()) {
                              int? slot = (_slotController.text.isEmpty)
                                  ? null
                                  : int.parse(_slotController.text);
                              Appointment editedAppointment = Appointment(
                                  id: widget.appointment.id,
                                  name: _nameSearchController.text,
                                  date: DateTime.parse(du.formatIndianToUsDate(
                                      _dateController.text)),
                                  treatmentScheduled:
                                      _treatmentScheduledController.text,
                                  slot: slot);
                              editedAppointment.status =
                                  widget.appointment.status;
                              editedAppointment.treatmentProvided =
                                  _treatmentPovidedController.text;
                              widget.appointmentProvider
                                  .updateAppointment(editedAppointment);
                              Navigator.popUntil(context, (p) => p.isFirst);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AppointmentDetailsScreen(
                                              appointment: editedAppointment,
                                              provider: widget
                                                  .appointmentProvider))); // Open edited appointment
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: components.navigationBar(context),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _slotController.dispose();
    _treatmentScheduledController.dispose();
    _nameSearchController.dispose();
    _treatmentPovidedController.dispose();
    super.dispose();
  }
}
