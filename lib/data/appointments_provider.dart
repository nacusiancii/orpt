import 'package:flutter/material.dart';

import '../appointment.dart';
import 'database_helper.dart';

//Provider with slots
class AppointmentProvider with ChangeNotifier {
  final DatabaseHelper databaseHelper;
  AppointmentProvider() : databaseHelper = DatabaseHelper.instance;

  // Load data from files
  // Future<void> _loadData() async {
  //   // Load appointments from JSON file
  //   Directory dir = await getApplicationDocumentsDirectory();
  //   final appointmentFile = File()await pu.getFile('appointments.json');
  //   if(appointmentFile==null) throw Exception('Appointment file must be selected');
  //   if (appointmentFile.existsSync()) {
  //     final jsonData = json.decode(appointmentFile.readAsStringSync());
  //     _appointments = List<Appointment>.from(
  //       jsonData.map((entry) => Appointment.fromJson(entry)),
  //     );
  //   }
  //
  //   // Load active appointments count by date from another file
  //   final activeAppointmentsFile = await pu.getFile('active_appointments.json');
  //   if(activeAppointmentsFile==null) throw Exception('Active appointments file must be selected');
  //   if (activeAppointmentsFile.existsSync()) {
  //     _activeAppointmentsByDate = Map<String, int>.from(
  //         json.decode(activeAppointmentsFile.readAsStringSync()));
  //   }
  // }
  //
  // // Save data to files
  // void _saveData() async {
  //   // Save appointments to JSON file
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/appointments.json');
  //   final jsonData = json.encode(_appointments);
  //   file.writeAsStringSync(jsonData);
  //
  //   // Save active appointments count by date to another file
  //   final activeAppointmentsFile =
  //       File('${directory.path}/active_appointments.json');
  //   final jsonDataActive = json.encode(_activeAppointmentsByDate);
  //   activeAppointmentsFile.writeAsStringSync(jsonDataActive);
  // }

  // Helper function to get a unique appointment ID
  // int _getUniqueAppointmentId() {
  //   int lastId = 0;
  //   if (_appointments.isNotEmpty) {
  //     lastId = _appointments.last.id;
  //   }
  //   return lastId + 1;
  // }

  // Create a new appointment
  void createAppointment(String name, DateTime date, String treatmentScheduled,
      [int? slot]) async {
    await databaseHelper.insertAppointment(name, date, treatmentScheduled, slot);
    notifyListeners();
  }

  // Fulfill an appointment
  Future<Appointment> fulfillAppointment(
      int id, String treatmentProvided) async {
    final appointment = await databaseHelper.getAppointmentById(id);
    appointment.treatmentProvided = treatmentProvided;
    appointment.status = AppointmentStatus.done;

    await databaseHelper.updateAppointment(appointment);
    notifyListeners();
    return appointment;
  }

  // Cancel an appointment
  void cancelAppointment(int id) async {
    final appointment = await databaseHelper.getAppointmentById(id);
    appointment.treatmentProvided = 'Cancelled';
    appointment.status = AppointmentStatus.cancelled;

    await databaseHelper.updateAppointment(appointment);
    notifyListeners();
  }

  // Fetch appointments on a specific date
  Future<List<List<Appointment>>> fetchAppointmentsByDate(DateTime date) async {
    List<Appointment> activeAppointments = [];
    List<Appointment> completedAppointments = [];
    List<Appointment> canceledAppointments = [];

    final appointments = await databaseHelper.getAppointmentsByDate(date);
    for (final appointment in appointments) {
      if (appointment.status == AppointmentStatus.cancelled) {
        canceledAppointments.add(appointment);
      } else if (appointment.status == AppointmentStatus.done) {
        completedAppointments.add(appointment);
      } else {
        activeAppointments.add(appointment);
      }
    }

    return [activeAppointments, completedAppointments, canceledAppointments];
  }

  // Fetch appointments by name
  Future<List<List<Appointment>>> fetchAppointmentsByName(String name) async {
    List<Appointment> activeAppointments = [];
    List<Appointment> completedAppointments = [];
    List<Appointment> canceledAppointments = [];

    final appointments = await databaseHelper.getAppointmentsByName(name);
    for (final appointment in appointments) {
      if (appointment.status == AppointmentStatus.cancelled) {
        canceledAppointments.add(appointment);
      } else if (appointment.status == AppointmentStatus.done) {
        completedAppointments.add(appointment);
      } else {
        activeAppointments.add(appointment);
      }
    }

    return [activeAppointments, completedAppointments, canceledAppointments];
  }

  //Fetch appointment by id
  Future<Appointment> fetchAppointmentById(int id) async {
    return await databaseHelper.getAppointmentById(id);
  }

  // Fetch dates with active appointments and the number of appointments
  // Map<DateTime, int> fetchDatesWithActiveAppointments() {
  //   final result = <DateTime, int>{};
  //   for (var entry in _activeAppointmentsByDate.entries) {
  //     final date = DateTime.parse(entry.key);
  //     result[date] = entry.value;
  //   }
  //   return result;
  // }

  // Generate a key for date representation (YYYY-MM-DD)
  // String _getDateKey(DateTime date) {
  //   return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  // }

  //Fetch all registered patients
  //Patient names are not case sensitive
  Future<Set<String>> fetchPatients() async {
    final appointments = await databaseHelper.getAppointments();
    final patients = <String>{};
    for (var element in appointments) {
      patients.add(element.name.toLowerCase());
    }
    return patients;
  }

  void removeAppointment(Appointment appointment) async {
    await databaseHelper.deleteAppointment(appointment.id);
    notifyListeners();
  }

  Future<Map<DateTime,int>>fetchNoOfAppointmentsByMonth(DateTime dayInMonth) async {
    Map<DateTime,int> appointmentCount={};
    DateTime day = DateTime(dayInMonth.year,dayInMonth.month,1);
    while(day.month==dayInMonth.month){
      int count = (await databaseHelper.getAppointmentsByDate(day)).length;
      appointmentCount.putIfAbsent(day, () => count);
    }
    return appointmentCount;
  }
}
