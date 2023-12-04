// import 'package:flutter/material.dart';
// import 'package:orpt/common/date_utils.dart' as du;
// import 'package:orpt/appointments_provider.dart';
//
// import 'appointment.dart';
// import 'appointment_details_screen.dart';
//
// class ScheduleScreen extends StatelessWidget {
//   final DateTime startDate, endDate;
//   final AppointmentProvider provider;
//   const ScheduleScreen(
//       {super.key,
//       required this.startDate,
//       required this.endDate,
//       required this.provider});
//
//   @override
//   Widget build(BuildContext context) {
//     final appointments = fetchAppointments(startDate, endDate);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Schedule'),
//       ),
//       body: CustomScrollView(
//         slivers: <Widget>[
//           const SliverAppBar(
//             expandedHeight: 200,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text('Schedule'),
//             ),
//           ),
//           SliverList(
//             //Sliver Child: List of Appointments on a date
//             delegate: SliverChildBuilderDelegate(
//                 (BuildContext context, int index) =>
//                     buildScheduleSection(index, appointments)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildScheduleSection(int i, List<List<Appointment>> appointments) {
//     final indexAppointments = appointments[i];
//     indexAppointments.sort((a, b) => ( //if slot is null consider it as zero
//         ((a.slot != null) ? a.slot : 0)! - ((b.slot != null) ? b.slot : 0)!));
//     final indexDate = indexAppointments.first.date;
//     final sectionTitle = '${du.formatIndianDate(indexDate)}}';
//
//     return Column(
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text(
//             sectionTitle,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: appointments.length,
//           itemBuilder: (context, index) {
//             final appointment = indexAppointments[index];
//             return ListTile(
//               title: Text(appointment.name),
//               subtitle: Text(appointment.treatmentScheduled),
//               // Handle tapping on the appointment to view details
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AppointmentDetailsScreen(
//                           appointment: indexAppointments[index],
//                           provider: provider),
//                     ));
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   List<List<Appointment>> fetchAppointments(
//       DateTime startDate, DateTime endDate) {
//     DateTime date = startDate;
//     List<List<Appointment>> appointments = [];
//     while(endDate.difference(date).inDays>=0){
//       final data = provider.fetchAppointmentsByDate(date);
//       appointments.add(data.first+data.last);
//       date.add(const Duration(days:1));
//     }
//     return appointments;
//   }
// }
