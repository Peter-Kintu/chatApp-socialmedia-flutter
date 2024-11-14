import 'package:chatapp/controllers/controllers.dart';
import 'package:chatapp/controllers/local_saved_data.dart';
import 'package:chatapp/models/user_data.dart';
import 'package:flutter/foundation.dart';


class UserDataProvider extends ChangeNotifier{
  String _userId = "";
  String _userName = "";
  String _userProfilePic = "";
  String _userPhoneNumber = "";
  String _userDeviceToken = "";

  String get getUserId => _userId;
  String get getUserName => _userName;
  String get getUserProfile => _userProfilePic;
  String get getUserPhoneNumber => _userPhoneNumber;
  String get getUserDeviceToken => _userDeviceToken;


  //to load the data from device
 void loadDatafromLocal(){
   _userId = LocalSavedData.getUserId();
   _userPhoneNumber = LocalSavedData.getUserPhone();
   _userName = LocalSavedData.getUserName();
   _userProfilePic = LocalSavedData.getUserProfile();
   print("data loaded from local $_userId, $_userPhoneNumber, $_userName");
   notifyListeners();
 }

 // to load data from our appwrite database collection
  void loadUserData(String userId)async{
   UserData? userData = await getUserDetails(userId: userId);
   if(userData!=null){
     _userName = userData.name?? "";
     _userProfilePic = userData.profilePic?? "";
     notifyListeners();
   }
  }


 // set user id
void setUserId(String id){
   _userId = id;
   LocalSavedData.saveUserid(id);
   notifyListeners();
}

  // set user phone
  void setUserPhone(String phone){
    _userPhoneNumber = phone;
    LocalSavedData.saveUserPhone(phone);
    notifyListeners();
  }

  //set user name
 void setUserName(String name) {
   _userName = name;
   LocalSavedData.saveUserName(name);
   notifyListeners();
}

//set profile pic of user
 void setProfilePic(String pic) {
   _userProfilePic = pic;
   LocalSavedData.saveUserProfile(pic);
   notifyListeners();
 }

 //set device token
void setDeviceToken(String token){
   _userDeviceToken =  token;
   notifyListeners();
}

//clear add values
void clearAllProvider(){
   _userId = "";
   _userName = "";
   _userProfilePic = "";
   _userPhoneNumber = "";
   _userDeviceToken = "";
   notifyListeners();
}
}