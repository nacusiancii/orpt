
library date_utils;

import 'package:intl/intl.dart';

String formatIndianDate(DateTime dateTime){
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

String formatIndianToUsDate(String iDate){
  try {
    // Parse the input date string with the original format
    DateTime originalDate;
    List<String> parts = iDate.split('-');
    if(parts[0].length==4) {
      originalDate = DateTime.parse(iDate);
      return iDate;
    }
    else {
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Create a DateTime object
      originalDate = DateTime(year, month, day);
    }

    // Format the DateTime object to the desired format
    String formattedDate = "${originalDate.year}-${originalDate.month.toString().padLeft(2, '0')}-${originalDate.day.toString().padLeft(2, '0')}";

    return formattedDate;
  } catch (e) {
    throw FormatException;
  }
}

bool areSameDays(DateTime date1, DateTime date2){
  return date1.year==date2.year && date1.month==date2.month &&date1.day==date2.day;
}