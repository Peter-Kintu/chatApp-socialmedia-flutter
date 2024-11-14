// ignore_for_file: duplicate_import

import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_data_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_data.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

Client client = Client()
  .setEndpoint('https://cloud.appwrite.io/v1')
  .setProject('670d23d10011da2ef854')
  .setSelfSigned(status: true); //for self signed certificate, only use for development

const String db = "670d2a7e0016df90a038";
const String userCollection ="670d2ac20014630f6405";
const String chatCollection ="67191bbf0037ccb4dc22";
const String storageBucket = "6713a08c000abdf7cd35";

Account account = Account(client);
final Databases databases = Databases(client);
final Storage storage = Storage(client);
final Realtime realtime = Realtime(client);

RealtimeSubscription? subscription;
//to subscribe to realtime changes
subscribeToRealtime({required String userId}){
  subscription=realtime.subscribe(
    ["databases.$db.collections.$chatCollection.documents",
      "databases.$db.collections.$userCollection.documents"
    ]);
  print("subscribing to real time");

  subscription!.stream.listen((data){
    print("some events happened");
    // print(data.events);
    // print(data.payload);
    final firstItem=data.events[0].split(".");
    final eventType = firstItem[firstItem.length -1];
    print("event type is $eventType");
    if(eventType == "create"){
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
      listen: false)
          .loadChats(userId);
    }
   else if(eventType == "update"){
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
          listen: false)
          .loadChats(userId);
    }
   else if(eventType == "delete"){
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
          listen: false)
          .loadChats(userId);
    }
  });


}


//save phone number to database (while creating a new account)
Future<bool> savePhoneToDb({
  required String phoneno, required String userId})async{
  try{
    final response = await databases.createDocument(
        databaseId: db,
        collectionId: userCollection, 
        documentId: userId, 
        data: {"phone_no":phoneno, "userId":userId}
    );
    print(response);
    return true;
    
  } on AppwriteException catch (e) {
    print("Cannot save to user database :$e");
    return false;
  }
}


// check whether phone number exist in DB or not

Future<String> checkPhoneNumber({required String phoneno}) async{
  try{
    final DocumentList matchUser=await databases.listDocuments(databaseId: db, collectionId: userCollection,
        queries: [Query.equal("phone_no", phoneno)]
    );

    if(matchUser.total>0){
      final Document user = matchUser.documents[0];

      if(user.data["phone_no"]!=null ||user.data["phone_no"]!=""){
        return user.data["userId"];
      }
      else{
        print("no user exist on db");
        return "user_not_exist";
      }

    }
    else{
      print("no user exist on db");
      return "user_not_exist";
    }

  }
  on AppwriteException catch (e) {
    print("error on reading database $e");
    return "user_not_exist";
  }
}

//create a phone session, send otp to phone number
Future<String> createPhoneSession({required String phone})async{
  try{
    final userId = await checkPhoneNumber(phoneno: phone);
    if(userId=="user_not_exist"){

      //creating a new account
      final Token data = await account.createPhoneToken(userId: ID.unique(), phone: phone);

      //save the new user to user collection
      savePhoneToDb(phoneno: phone, userId: data.userId);
      return data.userId;
    }

    //if user is an existing user
    else{
      //creating phone token for exisiting user
      final Token data = await account.createPhoneToken(userId: userId, phone: phone);
      return data.userId;
    }
  }
  catch (e) {
    print("error on create phone session :$e");
    return "login_error";
  }
}

// login with otp
Future <bool> loginWithOtp({required String otp, required String userId}) async{
  try{
    final Session session = await account.updatePhoneSession(userId: userId, secret: otp);
    print(session.userId);
    return true;

  } catch (e) {
    print("error on login with otp :$e");
    return false;
  }

}

// to check whether the session exist or not
Future<bool> checkSessions()async{
  try{
    final Session session = await account.getSession(sessionId: "current");
    print("Session exist ${session.$id}");
    return true;

  }catch (e) {
    print("session does not exist please login");
    return false;
  }
}
//logout the user  and delete the session

Future logoutUser()async{
  await account.deleteSession(sessionId: "current");
}

//load user data
 Future<UserData?> getUserDetails({required String userId}) async{
  try{
    final response = await databases.getDocument(databaseId: db, collectionId: userCollection, documentId: userId);
    print("getting user data");
    print(response.data);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(response.data["name"] ?? "");
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setProfilePic(response.data["profile_pic"] ?? "");
    return UserData.toMap(response.data);
  }catch(e){
    print("error in getting user data :$e");
    return null;
  }
  
  }


//to update the user data
Future updateUserDetails(
   String pic,{
     required String userId,
     required String name,
}
)async{
  try{
    final data=await databases.updateDocument(databaseId: db, collectionId: userCollection, documentId: userId,
      data: {
      "name": name,
        "profile_pic":pic
      }
    );

    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(name);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setProfilePic(pic);
    print(data);
    return true;
  }
  // ignore: unused_catch_clause
  on AppwriteException catch(e){
    print("cannot save to db");
    return false;
  }

}

//upload and save image to the storage bucket (create new image)
Future<String?> saveImageToBucket({required InputFile image}) async{
  try{
    final response=await storage.createFile(bucketId: storageBucket, fileId: ID.unique(), file: image);
    print("the response after save to bucket $response");
    return response.$id;
  }
  catch(e){
    print("error on saving image to bucket :$e");
    return null;
  }
}

//update image in bucket: first delete then create new image
Future<String ?> updateImageOnBucket(
   {required String oldImageId, required InputFile image})async{

  try{//to delete the old image
  deleteImagefromBucket(oldImageId: oldImageId);

  //create a new image
  final newImage = saveImageToBucket(image: image);

  return newImage;}
      catch(e){
      print("cannot upadate/delete image:$e");
      return null;
      }
}

//delete image from the strong bucket
Future<bool> deleteImagefromBucket(
    {required String oldImageId})async{

  try{//to delete the old image
    await storage.deleteFile(bucketId: storageBucket, fileId: oldImageId);


    return true;
  } catch(e){
    print("cannot upadate/delete image:$e");
    return false;
  }
}

//to search all the users from the database
Future<DocumentList?> searchUsers({required String searchItem, required String userId}) async{
  try{
    final DocumentList users = await databases.listDocuments(databaseId: db, collectionId: userCollection,
      queries: [
        Query.search("phone_no", searchItem),
        Query.notEqual("userId", userId)
      ]
    );
    
    print("total match users ${users.total}");
    return users;
  }
  catch(e){
    print("error on searching users: $e");
    return null;
  }
}

//create a new chat messages and save to data base
Future createNewChat({
  required String message,
  required String senderId,
  required String receiverId,
  bool isImage = false,

})async{
  try{
    // ignore: unused_local_variable
    final msg = await databases.createDocument(databaseId: db, collectionId: chatCollection, documentId: ID.unique(), data: {
      "message": message,
      "senderId": senderId,
      "receiverId": receiverId,
      "timestamp": DateTime.now().toIso8601String(),
      "isSeenbyReceiver": false,
      "isImage": isImage,
      "userData": [senderId, receiverId]
    });
    print("message send");
    return true;
  }
  catch(e){
    print("failed to send message :$e");
    return false;
  }
}
//to delete the chat from database correction
Future deleteCurrentUserChat({required String chatId})async{
  try{
    await databases.deleteDocument(databaseId: db, collectionId: chatCollection, documentId: chatId);
  }catch(e){
    print("error in deleting chat message : $e");
  }
}

//edit our chat message and update to  database
Future editChat({
  required String chatId,
  required String message})async{
  try{
    await databases.updateDocument(
        databaseId: db,
        collectionId: chatCollection,
        documentId: chatId,
      data: {"message": message});
    print("message updated");
  } catch(e){
    print("error on editing the message :$e");
  }
}

//to list all the chats belonging to the current user
Future<Map<String, List<ChatDataModel>>?> currentUserChats(String userId) async{
  try {
    var results = await databases.listDocuments(
        databaseId: db, collectionId: chatCollection,
        queries: [
          Query.or([
            Query.equal("senderId", userId),
            Query.equal("receiverId", userId)]),
          Query.orderDesc("timestamp"),
          Query.limit(2000)
        ]
    );

    final DocumentList chatDocuments = results;

    print("chat documents ${chatDocuments.total} and documents ${chatDocuments
        .documents.length}");
    Map<String, List<ChatDataModel>> chats = {};
    if (chatDocuments.documents.isNotEmpty) {
      for (var i = 0; i < chatDocuments.documents.length; i++) {
        var doc = chatDocuments.documents[i];
        String sender = doc.data["senderId"];
        String receiver = doc.data["receiverId"];

        MessageModel message = MessageModel.fromMap(doc.data);

        List<UserData> users = [];
        for (var user in doc.data["userData"]) {
          users.add(UserData.toMap(user));
        }
          String key = (sender == userId) ? receiver : sender;

          if (chats[key] == null) {
            chats[key] = [];
          }
          chats[key]!.add(ChatDataModel(message: message, users: users));
        }
      }
      return chats;
    }
    catch(e){
    print("error in reading current user chats :$e");
    return null;
    }
  }// to update isseen message status
Future updateIsSeen({required List <String> chatsIds}) async{
  try{
    for(var chatid in chatsIds){
      await databases.updateDocument(databaseId: db, collectionId: chatCollection,
          documentId: chatid,
      data: {
        "isSeenbyReceiver":true
      });
      print("update is seen");
    }
  }
  catch(e){
    print("error in update is seen by receiver :$e");
  }
}

//to update online status
Future updateOnlineStatus({required bool status, required String userId})async{
 try{
   await databases.updateDocument(
       databaseId: db,
       collectionId: userCollection,
       documentId: userId,
   data: {
         "isOnline":status});
   print("updated user online status");
 } catch(e){
   print ("unable to update online :$e");
 }
}



