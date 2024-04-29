import 'package:flutter/material.dart';
import 'package:orpt/common/date_utils.dart' as du;
import 'package:orpt/data/appointments_provider.dart';
import 'package:provider/provider.dart';
import 'components/components.dart' as components;

class NewAppointmentScreen extends StatefulWidget {
  final AppointmentProvider appointmentProvider;
  final DateTime? selectedDay;
  final String? patientName;

  const NewAppointmentScreen(
      {super.key,
      required this.appointmentProvider,
      this.selectedDay,
      this.patientName});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _slotController = TextEditingController();
  final _treatmentScheduledController = TextEditingController();
  final _nameSearchController = SearchController();

  @override
  Widget build(BuildContext context) {
    _dateController.text = widget.selectedDay == null
        ? ''
        : du.formatIndianDate(widget.selectedDay!);
    _nameSearchController.text =
        widget.patientName == null ? '' : widget.patientName!;
    Set<String> patients;
    return Consumer<AppointmentProvider>(
        // Use Consumer widget
        builder: (context, appointmentProvider, child) {
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
                          isFullScreen: false,
                          searchController: _nameSearchController,
                          builder: (context, controller) {
                            return SearchBar(
                              controller: controller,
                              padding:
                                  const MaterialStatePropertyAll<EdgeInsets>(
                                      EdgeInsets.symmetric(horizontal: 16.0)),
                              onTap: () => controller.openView(),
                              onSubmitted: (selectedText) {
                                controller.closeView(selectedText);
                              },
                              leading: const Icon(Icons.search),
                            );
                          },
                          suggestionsBuilder: (context, controller) {
                            var relatedPatients = patients
                                .where((patient) => patient
                                    .toLowerCase()
                                    .contains(controller.text.toLowerCase()))
                                .toList();
                            if (relatedPatients.isEmpty) {
                              return <ListTile>[];
                            }
                            return List<ListTile>.generate(
                                relatedPatients.length,
                                (int index) => ListTile(
                                      title: Text(
                                          relatedPatients.elementAt(index)),
                                      onTap: () => controller.closeView(
                                          relatedPatients.elementAt(index)),
                                    ));
                          }),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                            labelText: 'Date (DD-MM-YYYY)'),
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
                                final name = _nameSearchController.text;
                                final date = DateTime.parse(
                                    du.formatIndianToUsDate(
                                        _dateController.text));
                                int? slot = (_slotController.text.isEmpty)
                                    ? null
                                    : int.parse(_slotController.text);
                                final treatmentScheduled =
                                    _treatmentScheduledController.text;

                                widget.appointmentProvider.createAppointment(
                                    name, date, treatmentScheduled, slot);
                                Navigator.pop(context); // Close the screen
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
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _slotController.dispose();
    _treatmentScheduledController.dispose();
    _nameSearchController.dispose();
    super.dispose();
  }
}
