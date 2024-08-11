import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/AuthPages/forgetPasswordOtpScreen.dart';
import 'package:vichaar/AuthPages/login.dart';
import 'package:vichaar/View/OnBoard/detailsScreen.dart';
import 'package:vichaar/View/OnBoard/onBoardHome.dart';
import 'package:vichaar/View/OnBoard/socialLinkScreen.dart';
import 'package:vichaar/View/conversationsScreen.dart';
import 'package:vichaar/View/exploreScreen.dart';
import 'package:vichaar/View/updateProfileScreen.dart';
import 'package:vichaar/View/linkedinLogin.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'AuthPages/signup.dart';
import 'Components/myNavBar.dart';
import 'Provider/notificationProvider.dart';
import 'Provider/preFetchProvider.dart';
import 'Provider/skillsProvider.dart';
import 'Provider/typingProvider.dart';
import 'Services/firebase_messaging_service.dart';
import 'Socket/webSocket.dart';
import 'View/addscreen.dart';
import 'View/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

void getDeviceToken() async {
  String? token = await messaging.getToken();
  print("FCM Token: $token");
  // Send the token to your server or store it in your database
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final FirebaseMessagingService firebaseMessagingService =
      FirebaseMessagingService();
  await firebaseMessagingService.requestPermission();
  await firebaseMessagingService.initialize();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => TypingProvider()),
    ChangeNotifierProvider(create: (_) => SkillsProvider()),
    ChangeNotifierProvider(create: (_) => PreFetchProvider()..fetchNotes()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    Provider<WebSocketService>(
      create: (_) => WebSocketService(), // Initialize once here
      dispose: (_, webSocketService) => webSocketService.dispose(),
    ),
  ], child: MyApp()));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WebSocketService();
    final webSocketService =
        Provider.of<WebSocketService>(context, listen: false);
    webSocketService.connect(); // Establish the WebSocket connection
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Provider.of<WebSocketService>(context, listen: false)
        .dispose(); // Dispose WebSocket connection
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final webSocketService =
        Provider.of<WebSocketService>(context, listen: false);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      webSocketService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      webSocketService.connect(); // Reconnect on resume
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.notification?.title}");
      // Handle foreground messages here
      // For example, show a dialog or snackbar
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message.notification?.title ?? 'Notification'),
          content: Text(message.notification?.body ?? ''),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.notification?.title}");
      // Handle notification click
      // For example, navigate to a specific screen
      Navigator.pushNamed(
          context, '/someScreen'); // Replace '/someScreen' with your route
    });

    return Portal(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.comfortaaTextTheme(),
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: AppBarTheme(
            foregroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            titleTextStyle:
                GoogleFonts.comfortaa(color: Colors.white, fontSize: 24),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        home: LoginScreen(),
        initialRoute: '/nav',
        routes: {
          '/nav': (context) => MyNavbar(),
          '/onBoard': (context) => OnboardingHomeScreen(),
          '/details': (context) => DetailsScreen(
                linkedinLink: '',
                gitHubLink: '',
              ),
          '/home': (context) => HomeScreen(),
          '/links': (context) => LinksScreen(),
          '/login': (context) => LoginScreen(),
          '/forgetpass': (context) => ForgetPasswordScreen(),
          '/signup': (context) => SignupScreen(),
          //'/otp': (context) => OtpScreen(),
          '/editProfile': (context) => UpdateProfileScreen(),
          '/add': (context) => AddScreen(),
          '/search': (context) => HomeScreen(),
          '/linked': (context) => WebViewExample(),
          '/explore': (context) => ExplorePage(),
          // '/chat': (context) => ChatScreen(senderId: '65a51d33ae9549ea16b57a84', receiverId: '666f621e20b65f427f01c765',),
          '/convolist': (context) => ConversationsScreen(userId: ''),
          // '/skill': (context) => ChooseSkillsScreen()
        },
      ),
    );
  }
}
