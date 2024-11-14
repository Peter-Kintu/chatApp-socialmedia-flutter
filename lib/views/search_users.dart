import 'package:appwrite/models.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';
import '../models/user_data.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final TextEditingController _searchController = TextEditingController();
  late DocumentList searchedUsers = DocumentList(total: -1, documents: []);

  //handle the search
  void _handleSearch(){
    searchUsers(
        searchItem: _searchController.text,
        userId:
              Provider.of<UserDataProvider>(context, listen: false).getUserId).then((value){
                 if(value!=null){
                 setState(() {
                 searchedUsers=value;
                    });
              }
                 else{
                   setState(() {
                     searchedUsers=DocumentList(total: 0, documents: []);
                   });
              }
          });
        }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add and search users", style: TextStyle(fontWeight: FontWeight.bold,
        ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.green,
              borderRadius: BorderRadius.circular(6)
            ),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: _searchController,
                  onSubmitted: (value) => _handleSearch,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter phone number"
                  ),
                )),
                IconButton(icon: const Icon(Icons.search),
                  onPressed: () {
                    _handleSearch();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      body: searchedUsers.total==-1
          ? const Center(child: Text(
          "Use the search box to search users"))
          : searchedUsers.total == 0?
          const Center(child: Text("No user is found"),)
          :ListView.builder(
          itemCount: searchedUsers.documents.length,
          itemBuilder: (context, index){
            return ListTile(
              onTap: (){
                Navigator.pushNamed(context, "/chat",
                arguments: UserData.toMap(searchedUsers.documents[index].data));
              },
              leading:
              CircleAvatar(
                  backgroundImage:
                  searchedUsers.documents[index].data["profile_pic"]!=null &&
                      searchedUsers.documents[index].data["profile_pic"]!=""?
                      NetworkImage("${searchedUsers.documents[index].data['profile_pic']}")
                      : const Image(image: AssetImage("images/user.png"),).image
              ),
              title: Text(searchedUsers.documents[index].data["name"]),
              subtitle: Text(searchedUsers.documents[index].data["phone_no"]),
            );
      })
    );
  }
}
