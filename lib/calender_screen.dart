import 'package:flutter/material.dart';
import 'package:orpt/data/appointments_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:orpt/components/components.dart' as components;
import '/common/date_utils.dart' as du;

import 'appointments_screen.dart';

class CalendarScreen extends StatefulWidget {
  final AppointmentProvider appointmentProvider;
  const CalendarScreen({super.key, required this.appointmentProvider});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Consumer<AppointmentProvider>(
              builder: (context, appointmentProvider, child) {
                return FutureBuilder<Map<String, int>>(
                  future: widget.appointmentProvider
                      .fetchNoOfAppointmentsByMonth(_focusedDay),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return buildTableCalendar(snapshot.data!); //Calendar
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () => setState(() {}),
      ),
      bottomNavigationBar: components.navigationBar(context),
    );
  }

  Widget buildTableCalendar(Map<String, int> appointmentsCountByDate) {
    return TableCalendar(
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      daysOfWeekHeight: 24.0,
      calendarFormat: _calendarFormat,
      focusedDay: _focusedDay,
      firstDay: DateTime(2000),
      lastDay: DateTime(2050),
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {});
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AppointmentsListScreen(
                    appointmentProvider: widget.appointmentProvider,
                    selectedDay: selectedDay)));
      },
      calendarBuilders:
          CalendarBuilders(markerBuilder: (context, date, events) {
        final appointmentsCount =
            appointmentsCountByDate[du.formatIndianDate(date)] ?? 0;
        return Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColorForAppointments(appointmentsCount),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Center(
                child: Text(
                  '$appointmentsCount',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  getColorForAppointments(int? count) {
    if (count == null) {
      return Colors.white;
    } else if (count == 0) {
      return Colors.white;
    } else if (count < 4) {
      return Colors.green;
    } else if (count == 4) {
      return Colors.yellow[700];
    } else {
      return Colors.red;
    }
  }
}
