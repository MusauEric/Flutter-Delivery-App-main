import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotification {

  late AndroidNotificationChannel channel;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void initNotifacion() async {

    channel = const AndroidNotificationChannel(
      'high_importance_channel', 
      'High Importance Notifications', 
      'This channel is used for important notifications',
      importance: Importance.high
    );

    flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );
  }

  void onMessagingListener() {

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message){
      if( message != null ){
        print('NUEVA NOTIFICACION : $message');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) { 

      RemoteNotification? notification = message.notification;

      AndroidNotification? android = message.notification?.android;

      if( notification != null && android != null ){

        flutterLocalNotificationsPlugin.show(
          notification.hashCode, 
          notification.title, 
          notification.body, 
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, 
              channel.name, 
              channel.description,
              icon: 'launch_background'
            )
          )
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('NUEVA NOTIFICACION : $message');
    });

  }


  Future<String?> getNotificationToken() async {

    return await FirebaseMessaging.instance.getToken();

  }


  //  Authorization - YOUR Server key of Cloud Messaging
  Future<void> sendNotification(String to, Map<String, dynamic> data, String title, String body) async {

    Uri uri = Uri.https('fcm.googleapis.com', '/fcm/send');

    await http.post(uri, 
      headers: <String, String>{ 
        'Content-Type' : 'application/json',
        'Authorization' : 'key=AAAAqOg_kBg:APA91bGGlEhHMKSRQorAWFdz8Y0Yo4C_cDMi4b-gZNFV2Mp6pJ_9sBkDVshKrBW4yPUbJL75zsZ7nLgjgB_9SKe-rkT7qgNHUZsQclQ838SXgd-7X1p6k4X04eCoWV6iXqFjEnf7sEIw'
      },
      body: jsonEncode( <String, dynamic>{
        'notification' : {
          'body' : body,
          'title' : title
        },
        'priority' : 'high',
        'ttl' : '4500s',
        'data': data,
        'to' : to
      })
    );
  }

  Future<void> sendNotificationMultiple(List<String> toList, Map<String, dynamic> data, String title, String body) async {

    Uri uri = Uri.https('fcm.googleapis.com', '/fcm/send');

    await http.post(uri, 
      headers: <String, String>{ 
        'Content-Type' : 'application/json',
        'Authorization' : 'AAAACqjI_Fw:APA91bE3QIOfD9vDLxc7oy7n7AF9wvt4bQGWRO0i1rjYL5j9LU3jlnoO1mDTccyUsFw6StnHNdrHOjLCvthHH9-bf_e9KRrf-elepQvQrHWaooksm81bzydMIOaoSlIcGxda5xoidhlj'
      },
      body: jsonEncode( <String, dynamic>{
        'notification' : {
          'body' : body,
          'title' : title
        },
        'priority' : 'high',
        'ttl' : '4500s',
        'data': data,
        'registration_ids' : toList
      })
    );
  }


}

final pushNotification = PushNotification();