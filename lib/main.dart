// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';

import 'package:cabme_driver/controller/dash_board_controller.dart';
import 'package:cabme_driver/controller/settings_controller.dart';
import 'package:cabme_driver/on_boarding_screen.dart';
import 'package:cabme_driver/page/auth_screens/login_screen.dart';
import 'package:cabme_driver/page/dash_board.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'page/chats_screen/conversation_screen.dart';
import 'page/localization_screens/localization_screen.dart';
import 'service/localization_service.dart';
import 'themes/constant_colors.dart';
import 'utils/Preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences.initPref();

  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  var request = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (!Platform.isIOS) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {}

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('=====ON MESSAGE======');
      if (message.notification != null) {
        display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('=====${message.data}======');
      if (message.notification != null) {
        if (message.data['status'] == "done") {
          await Get.to(ConversationScreen(), arguments: {
            'receiverId': int.parse(json.decode(message.data['message'])['senderId'].toString()),
            'orderId': int.parse(json.decode(message.data['message'])['orderId'].toString()),
            'receiverName': json.decode(message.data['message'])['senderName'].toString(),
            'receiverPhoto': json.decode(message.data['message'])['senderPhoto'].toString(),
          });
        } else if (message.data['statut'] == "new" && message.data['statut'] == "rejected") {
          await Get.to(DashBoard());
        } else if (message.data['type'] == "payment received") {
          DashBoardController dashBoardController = Get.put(DashBoardController());
          dashBoardController.selectedDrawerIndex.value = 4;
          await Get.to(DashBoard());
        }
      }
    });
    await FirebaseMessaging.instance.subscribeToTopic("cabme-driver");
  }

  Future<void> initialize(BuildContext context) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
    await FlutterLocalNotificationsPlugin().initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) async {});

    await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "01",
        "cabme-driver",
        importance: Importance.max,
        priority: Priority.high,
      ));
      print('===Data===${message.data}');
      await FlutterLocalNotificationsPlugin().show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } on Exception {}
  }

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    setupInteractedMessage(context);
    Future.delayed(const Duration(seconds: 3), () {
      if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
        LocalizationService().changeLocale(Preferences.getString(Preferences.languageCodeKey).toString());
      }
      API.header['accesstoken'] = Preferences.getString(Preferences.accesstoken);
    });
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'CabMe Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: ConstantColors.primary,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      ),
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.locale,
      translations: LocalizationService(),
      builder: EasyLoading.init(),
      home: GetBuilder(
        init: SettingsController(),
        builder: (controller) {
          return Preferences.getString(Preferences.languageCodeKey).toString().isEmpty
              ? const LocalizationScreens(intentType: "main")
              : Preferences.getBoolean(Preferences.isFinishOnBoardingKey)
                  ? Preferences.getBoolean(Preferences.isLogin)
                      ? DashBoard()
                      : LoginScreen()
                  : const OnBoardingScreen();
        },
      ),
    );
  }
}
