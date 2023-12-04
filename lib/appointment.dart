import 'common/date_utils.dart' as du;

enum AppointmentStatus { done, tbd, cancelled }

class Appointment {
  final int id;
  final String name;
  final DateTime date;
  final int? slot;
  final String treatmentScheduled;
  String treatmentProvided;
  AppointmentStatus status;
  Appointment({
    required this.id,
    required this.name,
    required this.date,
    required this.treatmentScheduled,
    this.slot,
  })  : status = AppointmentStatus.tbd,
        treatmentProvided = "tbd";

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(du.formatIndianToUsDate(json['date'])),
      slot: json['slot'],
      treatmentScheduled: json['treatmentScheduled'],
    )
      ..treatmentProvided = json['treatmentProvided']
      ..status = AppointmentStatus.values[json['status']];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': du.formatIndianDate(date),
      'slot': slot,
      'treatmentScheduled': treatmentScheduled,
      'treatmentProvided': treatmentProvided,
      'status': status.index,
    };
  }

  @override
  String toString() {
    return 'Appointment{id: $id, name: $name, date: ${du.formatIndianDate(date)}, slot: $slot, treatmentScheduled: $treatmentScheduled, treatmentProvided: $treatmentProvided, status: $status}';
  }
}
