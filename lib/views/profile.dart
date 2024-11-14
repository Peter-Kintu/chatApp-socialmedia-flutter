// ignore_for_file: unnecessary_null_comparison

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/controllers/local_saved_data.dart';
import 'package:chatapp/providers/chat_provider.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(builder: (context, value, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("User Profile"),
        ),
        body: ListView(
          children: [
            ListTile(
              onTap: () => Navigator.pushNamed(context, "/update", arguments:
              {"title": "edit"}),
              leading: CircleAvatar(
                backgroundImage: value.getUserProfile!=null || value.getUserProfile!=""
            ?  CachedNetworkImageProvider("${value.getUserProfile}") //check 3h:17m for correction database
                : const Image(
                  image: AssetImage(
                   "images/user.png"
                ),
                ).image,
                ),
              title: Text(value.getUserName),
              subtitle: Text(value.getUserPhoneNumber),
              trailing: const Icon(Icons.edit_outlined),
            ),
            const Divider(),
            ListTile(
              onTap: () async{
                await LocalSavedData.clearAllData();
                Provider.of<UserDataProvider>(context, listen: false)
                    .clearAllProvider();

                Provider.of<ChatProvider>(context, listen: false)
                    .clearChats();

                updateOnlineStatus(
                    status: false,
                    userId:
                        Provider.of<UserDataProvider>(context,listen: false)
                            .getUserId);

                await logoutUser();
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
              },
              leading: const Icon(Icons.logout_outlined),
              title: const Text("Logout"),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.info_outlined),
              title: Text("About"),
            )
          ],
        ),
      );
    });

  }
}
