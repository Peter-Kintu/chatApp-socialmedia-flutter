import 'package:shared_preferences/shared_preferences.dart';

class LocalSavedData {
  static SharedPreferences? preferences;

  // initialize
  static Future<void> init() async{
    preferences = await SharedPreferences.getInstance();
  }
  //save the userId
  static Future<void>saveUserid(String id) async{
    await preferences!.setString("userId", id);
  }

  //read the userId
  static String getUserId(){
    return preferences!.getString("userId")?? "";
  }


  //save the user name
  static Future<void>saveUserName(String name) async{
    await preferences!.setString("name", name);
  }

  //read the user name
  static String getUserName(){
    return preferences!.getString("name")?? "";
  }


  //save the phone number
  static Future<void>saveUserPhone(String phone) async{
    await preferences!.setString("phone", phone);
  }

  //read the phone number
  static String getUserPhone(){
    return preferences!.getString("phone")?? "";
  }

  //save the user profile pic
  static Future<void>saveUserProfile(String profile) async{
    await preferences!.setString("profile", profile);
  }

  //read the user profile pic
  static String getUserProfile(){
    return preferences!.getString("profile")?? "";
  }

  //clear all the data
  static clearAllData () async{
    final bool data = await preferences!.clear();
    print("cleared all data from local :$data");
  }
}