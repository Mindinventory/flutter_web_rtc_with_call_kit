import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/common_imports.dart';
import '../../../../core/utils/fcm_helper.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/custom_image_loader.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/model/notification_payload.dart';
import '../../data/model/user.dart';
import '../bloc/auth_bloc/auth_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  AuthBloc authBloc = sl<AuthBloc>();

  @override
  void initState() {
    super.initState();
    showLog('navigator key hashCode: ${AppConstants.navigatorKey.hashCode}');
    WidgetsBinding.instance.addObserver(this);
    checkForPendingCall();
    registerCallActionListeners();
  }

  Future<void> checkForPendingCall() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List && calls.isNotEmpty) {
      showLog('call.first: ${calls.first.toString()}');

      Map<String, dynamic> temp = calls.first['extra'].cast<String, dynamic>();
      NotificationPayload data = NotificationPayload.fromJson(temp);
      showLog('check here: ${data.toJson()}');
      if (data.callType == CallType.video) {
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.videoCallPage,
              arguments: data);
        }
      }
    }
  }

  Future<void> registerCallActionListeners({Function? callback}) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        showLog(
            'FlutterCallkitIncoming Event: ${event?.event} body: ${event?.body}');
        switch (event!.event) {
          case Event.actionCallIncoming:
            // received an incoming call
            break;
          case Event.actionCallStart:
            // started an outgoing call
            // show screen calling in Flutter
            break;
          case Event.actionCallAccept:
            Map<String, dynamic> temp =
                event.body['extra'].cast<String, dynamic>();
            NotificationPayload data = NotificationPayload.fromJson(temp);
            showLog('check here: ${data.toJson()}');
            if (mounted) {
              if (data.callType == CallType.video) {
                Navigator.pushNamed(
                  AppConstants.navigatorKey.currentContext!,
                  AppRoutes.videoCallPage,
                  arguments: data,
                );
              } else if (data.callType == CallType.audio) {
                Navigator.pushNamed(
                  AppConstants.navigatorKey.currentContext!,
                  AppRoutes.audioCallPage,
                  arguments: data,
                );
              }
            }
            break;
          case Event.actionCallDecline:
            // declined an incoming call
            break;
          case Event.actionCallEnded:
            // ended an incoming/outgoing call
            break;
          case Event.actionCallTimeout:
            // missed an incoming call
            break;
          case Event.actionCallCallback:
            // only Android - click action `Call back` from missed call notification
            break;
          case Event.actionCallToggleHold:
            // only iOS
            break;
          case Event.actionCallToggleMute:
            // only iOS
            break;
          case Event.actionCallToggleDmtf:
            // only iOS
            break;
          case Event.actionCallToggleGroup:
            // only iOS
            break;
          case Event.actionCallToggleAudioSession:
            // only iOS
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            // only iOS
            break;
          case Event.actionCallCustom:
            // Handle this case.
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });
    } on Exception {
      showLog('call event exception');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: authBloc.user?.name,
        actions: [
          IconButton(
            onPressed: () {
              showCupertinoDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text('Logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          authBloc.add(LogoutEvent());
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.authenticationPage);
                        },
                        child: const Text("Yes"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('no data'),
            );
          } else if (snapshot.hasData) {
            List<User> users = snapshot.data?.docs.map((e) {
                  User user = User.fromJson(e.data());
                  user.userId = e.id;
                  return user;
                }).toList() ??
                [];

            users.removeWhere(
                (element) => element.username == authBloc.user?.username);

            return users.isNotEmpty
                ? ListView.separated(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      User user = users[index];
                      return ListTile(
                        title: Text(user.name ?? ''),
                        subtitle: Text(user.username ?? ''),
                        leading: CustomImageLoader(
                          url:
                              'https://i.pravatar.cc/${Random().nextInt(5) * 100}',
                          width: 48,
                          height: 48,
                          isRounded: true,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                // 'Please wait, Calling ${user.name}'.showSnackBar;
                                final payload = NotificationPayload(
                                  userId: authBloc.user?.userId,
                                  name: authBloc.user?.name,
                                  username: authBloc.user?.username,
                                  imageUrl: authBloc.user?.imageUrl,
                                  fcmToken: authBloc.user?.fcmToken,
                                  callAction: CallAction.join,
                                  callType: CallType.audio,
                                  notificationId: const Uuid().v1(),
                                  webrtcRoomId: const Uuid().v1(),
                                );
                                final response =
                                    await FCMHelper.sendNotification(
                                  fcmToken: user.fcmToken ?? '',
                                  payload: payload,
                                );
                                if (response?.statusCode == 200) {
                                  payload.fcmToken = user.fcmToken;
                                  payload.callAction = CallAction.create;
                                  payload.userId = user.userId;
                                  payload.name = user.name;
                                  payload.username = user.username;
                                  payload.imageUrl = user.imageUrl;
                                  payload.fcmToken = user.fcmToken;
                                  if (context.mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.audioCallPage,
                                      arguments: payload,
                                    );
                                  }
                                } else {
                                  'User not available please try later'
                                      .showSnackBar;
                                }
                              },
                              splashRadius: 28,
                              icon: const Icon(CupertinoIcons.phone_solid,
                                  color: AppColors.primary),
                            ),
                            IconButton(
                              onPressed: () async {
                                // 'Please wait, Calling ${user.name}'.showSnackBar;
                                final payload = NotificationPayload(
                                  userId: authBloc.user?.userId,
                                  name: authBloc.user?.name,
                                  username: authBloc.user?.username,
                                  imageUrl: authBloc.user?.imageUrl,
                                  fcmToken: authBloc.user?.fcmToken,
                                  callAction: CallAction.join,
                                  callType: CallType.video,
                                  notificationId: const Uuid().v1(),
                                  webrtcRoomId: const Uuid().v1(),
                                );
                                final response =
                                    await FCMHelper.sendNotification(
                                  fcmToken: user.fcmToken ?? '',
                                  payload: payload,
                                );
                                if (response?.statusCode == 200) {
                                  payload.fcmToken = user.fcmToken;
                                  payload.callAction = CallAction.create;
                                  payload.userId = user.userId;
                                  payload.name = user.name;
                                  payload.username = user.username;
                                  payload.imageUrl = user.imageUrl;
                                  payload.fcmToken = user.fcmToken;
                                  if (context.mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.videoCallPage,
                                      arguments: payload,
                                    );
                                  }
                                } else {
                                  'User not available please try later'
                                      .showSnackBar;
                                }
                              },
                              splashRadius: 28,
                              icon: const Icon(CupertinoIcons.videocam_fill,
                                  color: AppColors.primary),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        height: 8,
                        thickness: 1,
                      );
                    },
                  )
                : const Center(
                    child: LoadingIndicator(),
                  );
          }
          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }
}
