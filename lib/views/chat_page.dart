// ignore_for_file: unused_import
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/constants/chat_message.dart';
import 'package:chatapp/constants/colors.dart';
import 'package:chatapp/controllers/controllers.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';
import '../providers/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editmessageController = TextEditingController();
  
  
  late String currentUserId;
  late String currentUserName;

  FilePickerResult ? _filePickerResult;
  
  // List messages=[
  //   MessageModel(
  //     message: "hi how are you, please use heychat to chat with me",
  //     sender: "101",
  //     receiver: "202",
  //     timestamp: DateTime(2024,9,10),
  //     isSeenByReceiver: true,
  //     ),
  //
  //   MessageModel(message: "How are you, what is heychat?",
  //   sender: "202",
  //   receiver: "101",
  //   timestamp: DateTime(2024,9,10),
  //   isSeenByReceiver: false,
  //   ),
  //
  //   MessageModel(message: "it is a new best messaging app in town",
  //   sender: "101",
  //   receiver: "202",
  //   timestamp: DateTime(2024,10,11),
  //   isSeenByReceiver: true,
  //   ),
  //
  //   MessageModel(message: "is it better than watsap and how?",
  //     sender: "202",
  //     receiver: "101",
  //     timestamp: DateTime(2024,9,10),
  //     isSeenByReceiver: false,
  //   ),
  //   MessageModel(message: "yes of course",
  //     sender: "101",
  //     receiver: "202",
  //     timestamp: DateTime(2024,9,10),
  //     isSeenByReceiver: false,
  //     isImage: true,
  //   ),
  // ];
  @override
  void initState() {
   currentUserId = Provider.of<UserDataProvider>(context, listen: false).getUserId;
   currentUserName = Provider.of<UserDataProvider>(context, listen: false).getUserName;

   Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    super.initState();
  }
  //to open file picker
  void _openFilePicker(UserData receiver) async{
    FilePickerResult ? result = await FilePicker.platform
        .pickFiles(allowMultiple:  true, type: FileType.image);

    setState(() {
      _filePickerResult = result;
      uploadAllImage(receiver);
    });
  }

  //to upload files to our storage bucket and our database
  void uploadAllImage(UserData receiver) async{
    if(_filePickerResult!=null){
      _filePickerResult!.paths.forEach((path){
        if(path!=null){
          var file = File(path);
          final fileBytes=file.readAsBytesSync();
          final inputfile = InputFile.fromBytes(bytes: fileBytes, filename: file.path.split("/").last);

          //saving images to our storage bucket

          saveImageToBucket(image: inputfile).then((imageId){
            if(imageId!=null){
              createNewChat(message: imageId, senderId: currentUserId, receiverId: receiver.userId, isImage: true
              )
              .then((value) {
                if(value){
                  Provider.of<ChatProvider>(context, listen: false).addMessage(
                      MessageModel(

                          message: imageId,
                          sender: currentUserId,
                          receiver: receiver.userId,
                          timestamp: DateTime.now(),
                          isSeenByReceiver: false,
                          isImage: true,
                      ),
                      currentUserId, [
                        UserData(
                            phone: "", 
                            userId: currentUserId),
                    receiver
                  ]);
                }
              });

            }
          });
        }
      });
    }
    else{
         print("file picker cancelled by user");
    }
  }

  //to send simple text message
  void _sendMessage({required UserData receiver}){
    if(messageController.text.isNotEmpty){
      setState(() {
        createNewChat(
            message: messageController.text,
            senderId: currentUserId,
            receiverId: receiver.userId,
            isImage: false).then((value) {
              if(value) {
                Provider.of<ChatProvider>(context, listen: false).addMessage(
                    MessageModel(
                        message: messageController.text,
                        sender: currentUserId,
                        receiver: receiver.userId,
                        timestamp: DateTime.now(),
                        isSeenByReceiver: false),
                    currentUserId,
                    [UserData(phone: "", userId: currentUserId), receiver]);

                    messageController.clear();
              }
        });
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    return Consumer<ChatProvider>(
      builder:(context, value, child){
        final userAndOtherChats=value.getAllChats[receiver.userId]?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty?
        userAndOtherChats[0].users[0].userId==receiver.userId?userAndOtherChats[0].users[0].isOnline:
        userAndOtherChats[0].users[1].isOnline:false;


        List<String> receiverMsgList= [];

        for(var chat in userAndOtherChats){
          if(chat.message.receiver==currentUserId){
            if(chat.message.isSeenByReceiver==false){
              receiverMsgList.add(chat.message.messageId!);
            }
          }
        }
        updateIsSeen(chatsIds: receiverMsgList);

        return Scaffold(
          backgroundColor: const Color.fromARGB(96, 243, 200, 200),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 80, 124, 88),
            leadingWidth: 40,
            scrolledUnderElevation: 0,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                    backgroundImage: receiver.profilePic==""|| receiver.profilePic==null
                        ? const Image(
                      image: AssetImage("images/user.png"),
                    ).image
                        : const CachedNetworkImageProvider(
                        "https//clouds......"
                    )
                ),
                const SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name!,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    Text(
                      otherUserOnline == true? "Online":"Offline",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),

                  ],

                ),

              ],

            ),

          ),

          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: userAndOtherChats.length,
                    itemBuilder: (context, index){
                      final msg = userAndOtherChats[
                        userAndOtherChats
                            .length-1-index]
                          .message;

                      print(userAndOtherChats.length);

                     return GestureDetector(
                       onLongPress: (){
                         showDialog(context: context, builder: (context) => AlertDialog(
                           title: msg.isImage==true? const Text("choose what you what to do with this image")
                               : Text(
                               "${msg.message.length>10 ? msg.message.substring(0,10): msg.message} ..."),
                           content: msg.isImage==true? Text(msg.sender == currentUserId? 'Delete this image':
                           'This image cant be deleted'):
                           Text(msg.sender == currentUserId
                               ? 'Choose what you want to do with this massage'
                               : 'This message cant be modified.'),
                           actions: [
                             TextButton(
                             onPressed: (){
                               Navigator.pop(context);
                             }, 
                               child: const Text("cancel"),),
                             
                             msg.sender == currentUserId
                            ? TextButton(
                               onPressed: (){
                                 Navigator.pop(context);
                                 editmessageController.text =
                                     msg.message;
                                 
                                 showDialog(context: context, builder: (context) => 
                                   AlertDialog(
                                     title: const Text("Edit this message"),
                                     content: TextFormField(controller: editmessageController, maxLines: 10,),
                                     actions: [

                                       //ok button
                                       TextButton(
                                         onPressed: (){
                                           editChat(chatId:
                                           msg.messageId!,
                                               message:
                                               editmessageController.text
                                           );
                                            },
                                         child: const Text("ok")),

                                       //cancel button
                                       TextButton(
                                           onPressed: (){
                                             Navigator.pop(context);},
                                           child: const Text("cancel")),

                                     ],
                                   ));
                               },
                                 child: const Text(""))
                             : const SizedBox(),
                             msg.sender == currentUserId
                                 ? TextButton(
                               onPressed: (){
                                 Provider.of<ChatProvider>(context,
                                     listen: false)
                                     .deleteMessage(msg,
                                     currentUserId);
                                 Navigator.pop(context);
                               },
                               child: const Text("Delete"),) :
                             const SizedBox(),
                           ],
                         ),
                         );
                       },
                       child: ChatMessage(
                         isImage: msg.isImage??false,
                          msg: msg,currentUser: currentUserId,
                        ),
                     );
                    }),
              ),
             ),
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      onSubmitted: (value){
                        _sendMessage(receiver: receiver);
                      },
                      controller: messageController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message here..."),
                    )),
                    IconButton(onPressed: (){}, icon: const Icon(Icons.shop_2_outlined)),
                    IconButton(onPressed: (){
                      _openFilePicker(receiver);
                    }, icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: (){
                      _sendMessage(receiver: receiver);
                     }, icon: const Icon(Icons.send)),
                    //IconButton(onPressed: (){}, icon: const Icon(Icons.camera_alt_outlined)),

                  ],
                ),

              )
              ],
          ),

        );
      },

    );
  }
}