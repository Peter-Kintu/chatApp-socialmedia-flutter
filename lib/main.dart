// ignore_for_file: unused_import

import 'package:chatapp/controllers/controllers.dart';
import 'package:chatapp/providers/chat_provider.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:chatapp/views/chat_page.dart';
import 'package:chatapp/views/home.dart';
import 'package:chatapp/views/phone_login.dart';
import 'package:chatapp/views/profile.dart';
import 'package:chatapp/views/search_users.dart';
import 'package:chatapp/views/update_profile.dart';
import 'package:chatapp/views/video_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/local_saved_data.dart';

final navigatorKey=GlobalKey<NavigatorState>();

class LifecycleEventHandler extends WidgetsBindingObserver{
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    String currentUserId = Provider.of<UserDataProvider>(
      navigatorKey.currentState!.context, listen: false
      ).getUserId;
    super.didChangeAppLifecycleState(state);

    switch(state){
      case AppLifecycleState.resumed:
        updateOnlineStatus(status: true, userId: currentUserId);
        print("app resumed");
        break;

      case AppLifecycleState.inactive:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app inactive");
        break;

      case AppLifecycleState.paused:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app paused");
        break;

      case AppLifecycleState.detached:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app detached");
        break;

      case AppLifecycleState.hidden:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app hidden");
    }
  }

}

// run|debug|profile
  void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());
  await LocalSavedData.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'HeyChat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        routes: {

              "/": (context) => const checkUserSessions(),
              "/login": (context) => const PhoneLogin(),
              "/home": (context) => const HomePage(),
              "/chat":(context) => const ChatPage(),
              "/video":(context) => const VideoCallScreen(),
              "/profile":(context) => const ProfilePage(),
              "/update":(context) => const UpdateProfile(),
              "/search":(context) => const SearchUsers(),

        },
      ),
    );
  }
}

class checkUserSessions extends StatefulWidget {
  const checkUserSessions({super.key});

  @override
  State<checkUserSessions> createState() => _checkUserSessionsState();
}

class _checkUserSessionsState extends State<checkUserSessions> {

  @override
  void initState(){
    Future.delayed(Duration.zero, () {
      Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
    });
    checkSessions().then((value) {
      final userName =
          Provider.of<UserDataProvider>(context, listen: false).getUserName;
      print("username: $userName");
      if(value){
        // ignore: unnecessary_null_comparison
        if(userName != null && userName !=""){
          Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
        }else{
          Navigator.pushNamedAndRemoveUntil(
              context, "/update", (route) => false,
              arguments: {"title": "add"});
        }
      }else{
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}
