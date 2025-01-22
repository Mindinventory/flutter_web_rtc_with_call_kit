import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/utils/callkit_helper.dart';
import '../../../../core/utils/common_imports.dart';
import '../../../../core/widgets/custom_image_loader.dart';
import '../../data/model/notification_payload.dart';
import '../bloc/signaling_bloc/signaling_bloc.dart';

class AudioCallPage extends StatefulWidget {
  final NotificationPayload data;

  const AudioCallPage({
    super.key,
    required this.data,
  });

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  RTCVideoRenderer localRender = RTCVideoRenderer();
  RTCVideoRenderer remoteRender = RTCVideoRenderer();

  bool isLoading = true;

  SignalingBloc signalingBloc = sl<SignalingBloc>();

  @override
  void initState() {
    super.initState();
    initializeRenderer();
    signalingBloc.onAddRemoteStream = (stream) {
      remoteRender.srcObject = stream;
      setState(() {});
    };
    signalingBloc.onDisconnect = () {
      Navigator.pop(context);
    };
  }

  @override
  void dispose() {
    localRender.dispose();
    remoteRender.dispose();
    signalingBloc.dispose();
    signalingBloc.add(SignalingInitialEvent());
    CallKitHelper.endAllCalls();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.black87.withValues(alpha: 0.8)),
          padding: 16.0.paddingAll,
          child: Column(
            children: [
              kToolbarHeight.spaceHeight,
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImageLoader(
                      url: 'https://i.pravatar.cc/${Random().nextInt(5) * 100}',
                      width: 128,
                      height: 128,
                      isRounded: true,
                    ),
                    36.0.spaceHeight,
                    const Text(
                      "Audio call",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    8.0.spaceHeight,
                    Text(
                      widget.data.username ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  padding: 24.0.paddingHorizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor:
                              Colors.grey.shade200.withValues(alpha: 0.2),
                        ),
                        child: Container(
                          height: 56,
                          width: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.mic,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          signalingBloc.add(HangUpCallEvent(
                              localRender: localRender, payload: widget.data));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor: AppColors.primary,
                        ),
                        child: Container(
                          height: 64,
                          width: 64,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.phone_down_fill,
                            color: AppColors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor:
                              Colors.grey.shade200.withValues(alpha: 0.2),
                        ),
                        child: Container(
                          height: 56,
                          width: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200.withValues(alpha: 0.2),
                          ),
                          child: const Icon(
                            CupertinoIcons.speaker_2,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initializeRenderer() async {
    await localRender.initialize();
    await remoteRender.initialize();

    localRender.srcObject = await Helper.openCamera({
      'video': false,
      'audio': true,
    });

    if (widget.data.callAction == CallAction.create) {
      signalingBloc.add(
        CreateRtcRoomEvent(
            localStream: localRender.srcObject!,
            roomId: widget.data.webrtcRoomId ?? ''),
      );
    } else if (widget.data.callAction == CallAction.join) {
      signalingBloc.add(
        JoinRtcRoomEvent(
            localStream: localRender.srcObject!,
            roomId: widget.data.webrtcRoomId ?? ''),
      );
    }

    setState(() {
      isLoading = false;
    });
  }
}
