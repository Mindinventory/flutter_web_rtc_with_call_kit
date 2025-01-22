import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../../core/utils/callkit_helper.dart';
import '../../../../core/utils/common_imports.dart';
import '../../data/model/notification_payload.dart';
import '../bloc/signaling_bloc/signaling_bloc.dart';

class VideoCallPage extends StatefulWidget {
  final NotificationPayload payload;

  const VideoCallPage({
    super.key,
    required this.payload,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage>
    with SingleTickerProviderStateMixin {
  RTCVideoRenderer localRender = RTCVideoRenderer();
  RTCVideoRenderer remoteRender = RTCVideoRenderer();

  SignalingBloc signalingBloc = sl<SignalingBloc>();

  @override
  void initState() {
    super.initState();
    initializeRenderer();
    signalingBloc.onAddRemoteStream = (stream) {
      remoteRender.srcObject = stream;
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
      body: BlocBuilder(
        bloc: signalingBloc,
        builder: (context, state) {
          bool isConnected = state is SignalingConnectedState;
          showLog('check connection state: $isConnected');
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  if (isConnected)
                    RTCVideoView(
                      remoteRender,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  Align(
                    alignment: Alignment.topRight,
                    child: AnimatedContainer(
                      key: UniqueKey(),
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 1600),
                      margin: isConnected
                          ? const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 56)
                          : null,
                      height: isConnected ? 220 : constraints.maxHeight,
                      width: isConnected ? 142 : constraints.maxWidth,
                      child: ClipRRect(
                        borderRadius: 16.0.radiusAll,
                        child: RTCVideoView(
                          localRender,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 74,
                      margin: const EdgeInsets.symmetric(
                          vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black26.withValues(alpha: 0.3),
                        borderRadius: 20.0.radiusAll,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CustomIconButton(
                              bgColor: AppColors.grey.withValues(alpha: 0.5),
                              icon: CupertinoIcons.switch_camera_solid,
                              onPressed: () {},
                            ),
                            CustomIconButton(
                              bgColor: AppColors.grey.withValues(alpha: 0.5),
                              icon: CupertinoIcons.videocam_fill,
                              onPressed: () {},
                            ),
                            CustomIconButton(
                              bgColor: AppColors.grey.withValues(alpha: 0.5),
                              icon: CupertinoIcons.mic_fill,
                              onPressed: () {},
                            ),
                            CustomIconButton(
                              bgColor: AppColors.primary,
                              icon: CupertinoIcons.phone_down_fill,
                              onPressed: () {
                                Navigator.pop(context);
                                signalingBloc.add(HangUpCallEvent(
                                    localRender: localRender,
                                    payload: widget.payload));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> initializeRenderer() async {
    await localRender.initialize();
    await remoteRender.initialize();

    localRender.srcObject = await Helper.openCamera({
      'video': true,
      'audio': true,
    });

    if (widget.payload.callAction == CallAction.create) {
      signalingBloc.add(
        CreateRtcRoomEvent(
            localStream: localRender.srcObject!,
            roomId: widget.payload.webrtcRoomId ?? ''),
      );
    } else if (widget.payload.callAction == CallAction.join) {
      signalingBloc.add(
        JoinRtcRoomEvent(
            localStream: localRender.srcObject!,
            roomId: widget.payload.webrtcRoomId ?? ''),
      );
    }

    signalingBloc.add(SignalingConnectingEvent());
  }
}

class CustomIconButton extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    required this.bgColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: AppColors.white,
          size: 30,
        ),
      ),
    );
  }
}
