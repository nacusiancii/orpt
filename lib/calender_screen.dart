import 'package:flutter/material.dart';
import 'package:orpt/data/appointments_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:orpt/components/components.dart' as components;

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
  Map<DateTime, int> _appointmentsCountByDate = {};

  @override
  void initState() {
    super.initState();
    // Fetch the initial appointments count data when the screen is initialized
    _fetchAppointmentsCount();
  }

  void _fetchAppointmentsCount() {
    widget.appointmentProvider
        .fetchNoOfAppointmentsByMonth(_focusedDay)
        .then((data) => setState(() => _appointmentsCountByDate = data));
  }

  @override
  Widget build(BuildContext context) {
    //Get appointments
    return buildScaffold(context);
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TableCalendar(
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              daysOfWeekHeight: 24.0,
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              firstDay: DateTime(2000),
              lastDay: DateTime(2050),
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                //_fetchAppointmentsCount will call set sate
                _fetchAppointmentsCount();
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AppointmentsListScreen(
                            appointmentProvider: widget.appointmentProvider,
                            selectedDay: selectedDay)));
              },
              calendarBuilders:
                  CalendarBuilders(markerBuilder: (context, date, events) {
                final appointmentsCount = _appointmentsCountByDate[date] ?? 0;
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getColorForAppointmentsCount(
                          context, appointmentsCount),
                    ),
                    child: Center(
                      child: Text(
                        '$appointmentsCount',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: () => _fetchAppointmentsCount()),
      bottomNavigationBar: components.navigationBar(context),
    );
  }
}

_getColorForAppointmentsCount(BuildContext context, int appointmentsCount) {
  if (appointmentsCount >= 4) {
    return Theme.of(context).colorScheme.primaryContainer;
  } else if (appointmentsCount == 3) {
    return Theme.of(context).colorScheme.secondaryContainer;
  } else {
    return Theme.of(context).colorScheme.tertiaryContainer;
  }
}
