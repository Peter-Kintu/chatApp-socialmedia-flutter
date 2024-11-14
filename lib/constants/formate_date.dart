String formatDate(DateTime date) {
  //today
  if(date.day==DateTime.now().day &&
      date.month == DateTime.now().month &&
      date.year==DateTime.now().year){
    //we want to formate the time like 10:50
    return 'Today ${
        date.hour > 9 ? date.hour : '0${date.hour}'}'
        ':${date.minute > 9 ? date.minute : '0${date.minute}'}';
  }
  //yesterday
  if(date.day==DateTime.now().day -1 &&
      date.month == DateTime.now().month &&
      date.year==DateTime.now().year){
    return 'Yesterday ${
        date.hour > 9 ? date.hour : '0${date.hour}'}'
        ':${date.minute > 9 ? date.minute : '0${date.minute}'}';
  }
  //10/01/2024
  return '${date.day}/${date.month}/${date.year}  ${
      date.hour > 9 ? date.hour : '0${date.hour}'}'
      ':${date.minute > 9 ? date.minute : '0${date.minute}'}';

}