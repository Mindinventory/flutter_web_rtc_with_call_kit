import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../../../core/utils/common_imports.dart';
import '../../../../../core/utils/fcm_helper.dart';
import '../../../data/model/notification_payload.dart';
import '../auth_bloc/auth_bloc.dart';

part 'signaling_event.dart';

part 'signaling_state.dart';

class SignalingBloc extends Bloc<SignalingEvent, SignalingState> {
  RTCPeerConnection? peerConnection;

  MediaStream? localStream;
  MediaStream? remoteStream;

  Function(MediaStream stream)? onAddRemoteStream;
  VoidCallback? onDisconnect;

  AuthBloc authBloc;

  FirebaseFirestore db = FirebaseFirestore.instance;

  SignalingBloc({
    required this.authBloc,
  }) : super(SignalingInitialState()) {
    on<CreateRtcRoomEvent>(_createRoom);
    on<JoinRtcRoomEvent>(_joinRoom);
    on<HangUpCallEvent>(_hangUp);
    on<SignalingInitialEvent>((event, emit) => emit(SignalingInitialState()));
    on<SignalingConnectingEvent>(
        (event, emit) => emit(SignalingConnectingState()));
    on<SignalingConnectedEvent>(
        (event, emit) => emit(SignalingConnectedState()));
    on<SignalingDisConnectedEvent>(
        (event, emit) => emit(SignalingDisconnectedState()));
  }

  Future<void> _createRoom(
    CreateRtcRoomEvent event,
    Emitter<SignalingState> emit,
  ) async {
    localStream = event.localStream;
    DocumentReference roomRef = db.collection('room').doc(event.roomId);

    showLog(
        'Create PeerConnection with configuration: ${AppConstants.webrtcConfiguration}');
    peerConnection =
        await createPeerConnection(AppConstants.webrtcConfiguration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Code for collecting ICE candidates below
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      showLog('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    showLog('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);
    var roomId = roomRef.id;
    showLog('New room created with SDK offer. Room ID: $roomId');
    // Created a Room

    peerConnection?.onTrack = (RTCTrackEvent event) {
      showLog('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        showLog('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    // Listening for remote session description below
    roomRef.snapshots().listen((snapshot) async {
      showLog('Got updated room: ${snapshot.data()}');

      if (snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (peerConnection?.getRemoteDescription() != null &&
            data['answer'] != null) {
          var answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );

          showLog("Someone tried to connect");
          await peerConnection?.setRemoteDescription(answer);
        }
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          showLog('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });
    // Listen for remote ICE candidates above

    roomId = roomRef.id;
  }

  Future<void> _joinRoom(
    JoinRtcRoomEvent event,
    Emitter<SignalingState> emit,
  ) async {
    localStream = event.localStream;
    DocumentReference roomRef = db.collection('room').doc(event.roomId);
    var roomSnapshot = await roomRef.get();
    showLog('Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      showLog(
          'Create PeerConnection with configuration: ${AppConstants.webrtcConfiguration}');
      peerConnection =
          await createPeerConnection(AppConstants.webrtcConfiguration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        showLog('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        showLog('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          showLog('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      showLog('Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      showLog('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        for (var document in snapshot.docChanges) {
          var data = document.doc.data() as Map<String, dynamic>;
          showLog(data.toString());
          showLog('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    }
  }

  Future<void> _hangUp(
    HangUpCallEvent event,
    Emitter<SignalingState> emit,
  ) async {
    try {
      //close media & connection

      List<MediaStreamTrack>? tracks = event.localRender.srcObject?.getTracks();
      tracks?.forEach((track) {
        track.stop();
      });

      if (remoteStream != null) {
        remoteStream?.getTracks().forEach((track) => track.stop());
      }

      dispose();

      //clear from firebase collection

      var roomRef = db.collection('room').doc(event.payload.webrtcRoomId);
      await roomRef.get().then((value) async {
        if (value.data()?.containsKey('answer') == false) {
          event.payload.userId = authBloc.user?.userId;
          event.payload.name = authBloc.user?.name;
          event.payload.username = authBloc.user?.username;
          event.payload.imageUrl = authBloc.user?.imageUrl;
          event.payload.fcmToken = authBloc.user?.fcmToken;
          event.payload.callAction = CallAction.end;
          await FCMHelper.sendNotification(
            fcmToken: event.payload.fcmToken ?? '',
            payload: event.payload,
          );
        }
      });

      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      for (var document in calleeCandidates.docs) {
        document.reference.delete();
      }

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      for (var document in callerCandidates.docs) {
        document.reference.delete();
      }

      await roomRef.delete();
    } on Exception catch (e) {
      showLog(e.toString());
      emit(SignalingFailureState());
    }
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      showLog('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        onDisconnect?.call();
        add(SignalingDisConnectedEvent());
      } else if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        add(SignalingConnectedEvent());
      } else if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        add(SignalingConnectingEvent());
      }
      showLog('Connection state change: $state ${DateTime.now()}');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      showLog('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      showLog('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      showLog("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }

  void dispose() {
    peerConnection?.close();
    localStream?.dispose();
    remoteStream?.dispose();
  }
}
