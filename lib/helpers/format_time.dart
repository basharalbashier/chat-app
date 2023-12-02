import 'package:intl/intl.dart';

String amOrPm(String? timeFrom, bool fullDateAndtime) {
  if (timeFrom == null) {
    return 'No time added';
  }

  String time;

  try {
      String hour = timeFrom.substring(11, 13);
  String after = timeFrom.substring(13, 16);
  String dateFrom = timeFrom.substring(0, 10);
  int intHour = int.parse(hour)+2;
    if (!fullDateAndtime) {
      if (intHour > 12) {
        // time = "${intHour - 12 + 2}${after} AM";
                time = "$intHour ";


      } 
        time = "$intHour$after AM";
      
    } else {
      DateTime date = DateTime.parse(dateFrom);
      String dateFormat = DateFormat('EEEE').format(date);

      if (intHour > 12) {
        time = "$dateFormat\n${intHour - 12 + 2}${after} PM\n$dateFrom";
      } else {
        time = "$dateFormat\n${intHour + 2}${after} AM\n$dateFrom";
      }
    }
  } catch (e) {
    time = 'Error on time';
  }
  return time;
}

String whichDayIsIt(String? fullDateandTime){
  if(fullDateandTime==null){
    return 'no date provided';
  }
String day = '';
try{

  var today=DateTime.now();
if(fullDateandTime.substring(0, 10) ==today.toString().substring(0, 10)){
  day ='Today';
}else{
    day='wrong data';

}
}catch(e){
  day='wrong data';
}
return day;

}