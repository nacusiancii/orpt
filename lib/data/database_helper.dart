import 'dart:convert';
import 'dart:io';

import 'package:orpt/appointment.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../common/date_utils.dart' as du;

class DatabaseHelper {
  // Database fields
  static const String dbName = 'appointments.db';
  static const int dbVersion = 1;

  // Table and column names
  static const String appointmentsTable = 'Appointments';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDate = 'date';
  static const String columnSlot = 'slot';
  static const String columnTreatmentScheduled = 'treatmentScheduled';
  static const String columnTreatmentProvided = 'treatmentProvided';
  static const String columnStatus = 'status';

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  factory DatabaseHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    //When supporting multiple platforms: TODO implement custom path library to handle differences among platforms
    String dbPath = await getDatabasesPath();

    String path = join(dbPath, 'appointments2.db');
    Database db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
    var dir = await getApplicationDocumentsDirectory();
    final propertiesFile = File('${dir.path}/properties.json');
    List<Appointment> appointments = [];
    //properties
    Map<String, dynamic>? properties;
    if (propertiesFile.existsSync()) {
      properties = json.decode(propertiesFile.readAsStringSync());
      if (!properties?['migratedFromBuild3ToBuild4']) {
        appointments = await getOldData();
      }
    } else {
      appointments = await getOldData();
    }
    // Use a transaction to ensure atomicity
    await db.transaction((txn) async {
      for (Appointment appointment in appointments) {
        const query = '''INSERT INTO $appointmentsTable (
          $columnName, $columnDate, $columnSlot, $columnTreatmentScheduled,
          $columnTreatmentProvided, $columnStatus
        ) VALUES (?, ?, ?, ?, ?, ?)
        ''';

        await txn.rawInsert(query, [
          appointment.name,
          du.formatIndianDate(appointment.date),
          appointment.slot,
          appointment.treatmentScheduled,
          appointment.treatmentProvided,
          appointment.status.index,
        ]);
      }
    });
    properties ??= <String, dynamic>{};
    properties.update('migratedFromBuild3ToBuild4', (value) => true,
        ifAbsent: () => true);
    final jsonData = json.encode(properties);
    propertiesFile.writeAsStringSync(jsonData);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $appointmentsTable (
          $columnId INTEGER PRIMARY KEY,
          $columnName TEXT NOT NULL,
          $columnDate TEXT NOT NULL,
          $columnSlot INTEGER,
          $columnTreatmentScheduled TEXT NOT NULL,
          $columnTreatmentProvided TEXT,
          $columnStatus INTEGER NOT NULL
      );
    ''');
    await db.execute('CREATE INDEX DateIndex ON appointments ($columnDate);');
    await db.execute('CREATE INDEX NameIndex ON appointments ($columnName);');
  }

  // Insert an appointment
  Future<void> insertAppointment(
      String name, DateTime date, String treatmentScheduled,
      [int? slot]) async {
    final db = await database;
    final appointment = Appointment(
        id: 0, name: name, date: date, treatmentScheduled: treatmentScheduled);
    const query = '''INSERT INTO $appointmentsTable (
      $columnName, $columnDate, $columnSlot, $columnTreatmentScheduled,
      $columnTreatmentProvided, $columnStatus
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''';

    await db.rawInsert(query, [
      appointment.name,
      du.formatIndianDate(appointment.date),
      appointment.slot,
      appointment.treatmentScheduled,
      appointment.treatmentProvided,
      appointment.status.index,
    ]);
  }

  // Retrieve all appointments
  Future<List<Appointment>> getAppointments() async {
    final db = await database;
    final appointments = await db.query(appointmentsTable);
    return appointments.map((json) => Appointment.fromJson(json)).toList();
  }

  // Retrieve appointments by date
  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    final db = await database;
    final formattedDate = du.formatIndianDate(date);
    final appointments = await db.query(appointmentsTable,
        where: '$columnDate = ?', whereArgs: [formattedDate]);
    return appointments.map((json) => Appointment.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> countAppointmentsByDate(DateTime selectedMonth) async {
    final db = await database;

    // Extract year and month from the selected date
    final year = selectedMonth.year;
    final month = selectedMonth.month;

    // Format the year and month as a string
    final formattedMonth = '${month.toString().padLeft(2, '0')}-$year';

    // Execute the query
    final result = await db.rawQuery('''
    SELECT $columnDate, COUNT(*) as count
    FROM $appointmentsTable
    WHERE SUBSTR($columnDate, 4, 10) = ? AND $columnStatus != ${AppointmentStatus.cancelled.index}
    GROUP BY $columnDate
    ORDER BY $columnDate
  ''', [formattedMonth]);

    return result;
  }

  // Retrieve appointments by name
    Future<List<Appointment>> getAppointmentsByName(String name) async {
      final db = await database;
      final appointments = await db
          .query(appointmentsTable, where: '$columnName = ? COLLATE NOCASE', whereArgs: [name]);
      return appointments.map((json) => Appointment.fromJson(json)).toList();
    }

  // Update an appointment
  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    int changes = await db.update(appointmentsTable, appointment.toJson(),
        where: '$columnId = ?', whereArgs: [appointment.id]);
    appointment = await getAppointmentById(appointment.id);
    return changes;
  }

  // Delete an appointment
  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db
        .delete(appointmentsTable, where: '$columnId = ?', whereArgs: [id]);
  }

  //throws a state error if no data exists with id
  Future<Appointment> getAppointmentById(int id) async {
    final db = await database;
    final data = await db
        .query(appointmentsTable, where: '$columnId=?', whereArgs: [id]);
    return Appointment.fromJson(data.first);
  }
}

Future<List<Appointment>> getOldData() async {
  final appointments = <Appointment>[];
  var dir = await getApplicationDocumentsDirectory();
  final appointmentsFile = File('${dir.path}/appointments.json');
  if (appointmentsFile.existsSync()) {
    final jsonData = json.decode(appointmentsFile.readAsStringSync());
    jsonData
        .map((entry) => Appointment.fromJson(entry))
        .forEach((entry) => appointments.add(entry));
  }
  return appointments;
}
