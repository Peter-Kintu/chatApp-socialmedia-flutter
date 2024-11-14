// ignore_for_file: unused_import, unnecessary_null_comparison
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/constants/colors.dart';
import 'package:chatapp/controllers/controllers.dart';
import 'package:chatapp/models/chat_data_model.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import '../constants/formate_date.dart';
import '../models/user_data.dart';
import '../providers/chat_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentUserId = "";

  @override
  void initState() {
  currentUserId=
      Provider.of<UserDataProvider>(context, listen: false).getUserId;
      Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
      subscribeToRealtime(userId: currentUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateOnlineStatus(status: true, userId: currentUserId);
    return Scaffold(
      backgroundColor: Colors.white38,
      appBar: AppBar(

        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          "HeyChat", 
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: ()=> Navigator.pushNamed(context, "/profile"),
            child:
             Consumer<UserDataProvider>(builder: (context, value, child) {
               return
                 CircleAvatar(
                   backgroundImage: value.getUserProfile!=null || value.getUserProfile!=""?
                 CachedNetworkImageProvider("""
                     ${value.getUserProfile}""") //check 3h:17m for correction database
                   : const Image(
                     image: AssetImage(
                         "images/user.png"
                     ),
                   ).image,
                 );
    }))
        ],

      ),
      body: Consumer<ChatProvider>(builder: (context, value, child) {
        if(value.getAllChats.isEmpty){
          return const Center(
            child: Text("No Chat"),
          );
        }
        else{
          List otherUsers = value.getAllChats.keys.toList();
          return  ListView.builder(
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {

                List<ChatDataModel> chatData =
                   value.getAllChats[otherUsers[index]]!;

                int totalChats=chatData.length;

                UserData otherUser=
                chatData[0].users[0].userId==currentUserId
                    ? chatData[0].users[1]
                    :chatData[0].users[0];

                int unreadMsg = 0;
                chatData.fold(
                    unreadMsg,(previousValue, element){
                      if(element.message.isSeenByReceiver==false){
                        unreadMsg++;
                      }
                      return unreadMsg;
                }
                );
                return ListTile(
                    onTap: () => Navigator.pushNamed(context, "/chat",
                      arguments: otherUser
                    ),
                    leading: Stack(
                        children: [CircleAvatar(
                          backgroundImage:
                              otherUser.profilePic ==""||otherUser.profilePic==null?
                          const Image(image: AssetImage(
                              "images/user.png"),
                          ).image
                                  : CachedNetworkImageProvider ("${otherUser.profilePic}")
                        ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor:otherUser.isOnline==true
                                  ? Colors.green
                                  : Colors.grey.shade600,
                            ),
                          )
                        ]
                    ),
                    title: Text(
                      (otherUser.name!), style: const TextStyle(color: Colors.black),),
                    subtitle: Text(
                        "${chatData[totalChats - 1].message.sender==currentUserId?"You :":""}${chatData[totalChats - 1 ].message.isImage==true?"Sent an image": chatData[totalChats - 1].message.message}",
                    overflow: TextOverflow.ellipsis,
                    ),

                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    chatData[totalChats-1].message.sender!=currentUserId
                    ? unreadMsg!=0
                      ?CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 10,
                          child:
                          Text(
                          unreadMsg.toString(),
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        )
                        )
                        :const SizedBox()
                     :const SizedBox(),

                        const SizedBox(height: 8,),
                        Text(formatDate(chatData[totalChats-1].message.timestamp))
                      ],
                    ),
                  );
              } );

        }

    },

      ),
    floatingActionButton: FloatingActionButton(
    backgroundColor: Colors.green,
    onPressed: () {
    Navigator.pushNamed(context, "/search");
    },
    child: const Icon(Icons.add,),)

    );

  }

}