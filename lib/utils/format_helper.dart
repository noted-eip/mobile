DateTime formatStringToDateTime(String date) {
  return DateTime.parse(date);
}

String formatDateToString(DateTime dateTime) {
  String day = intTo2Digits(dateTime.day);
  String month = intTo2Digits(dateTime.month);
  String year = dateTime.year.toString();
  String hour = intTo2Digits(dateTime.hour);
  String minute = intTo2Digits(dateTime.minute);

  return "$day/$month/$year : $hour:$minute";
}

String intTo2Digits(int number) {
  if (number < 10) {
    return "0$number";
  }
  return number.toString();
}
