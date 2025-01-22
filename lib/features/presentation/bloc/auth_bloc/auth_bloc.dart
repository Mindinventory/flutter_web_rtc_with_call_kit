import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/common_imports.dart';
import '../../../../../core/utils/fcm_helper.dart';
import '../../../data/model/user.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  User? user;
  StreamSubscription? userStream;

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_login);
    on<SignUpEvent>(_signUp);
    on<MultipleLoginEvent>(_handleMultipleLogin);
    on<UpdateFCMTokenEvent>(_updateFCMToken);
    on<LogoutEvent>(_logout);
  }

  FutureOr<void> _login(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoadingState());
      var user = await getUserByUsername(event.username);
      if (user != null) {
        this.user = User.fromJson(user.data().asMap);
        this.user?.userId = user.id;
        add(UpdateFCMTokenEvent());
        await SharedPrefs.setUserDetails(jsonEncode(this.user?.toJson()));
        emit(AuthSuccessState(message: 'User log in successfully'));
      } else {
        emit(AuthFailureState(
            message: 'user not available, please sign up first'));
      }
    } on Exception catch (e) {
      showLog(e.toString());
      emit(AuthFailureState(message: 'something went wrong'));
    }
  }

  FutureOr<void> _signUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoadingState());
      var user = await getUserByUsername(event.user.username ?? '');
      if (user == null) {
        var ds = db.collection('user').doc();
        await ds.set(event.user.toJson());
        this.user = event.user;
        this.user?.userId = ds.id;
        _setUpStream(db.collection('user').doc(ds.id).snapshots());
        emit(AuthSuccessState(message: 'User sign up successfully'));
      } else {
        emit(AuthFailureState(
            message: 'Username exist, please choose a different username'));
      }
    } on Exception catch (e) {
      showLog(e.toString());
      emit(AuthFailureState(message: 'something went wrong'));
    }
  }

  FutureOr<void> _handleMultipleLogin(
      MultipleLoginEvent event, Emitter<AuthState> emit) async {
    user = null;
    await SharedPrefs.remove();
    emit(AuthMultipleLoginState());
  }

  FutureOr<void> _updateFCMToken(
      UpdateFCMTokenEvent event, Emitter<AuthState> emit) async {
    user?.fcmToken = FCMHelper.fcmToken;
    await db
        .collection('user')
        .doc(user?.userId)
        .update({'fcmToken': FCMHelper.fcmToken});
    _setUpStream(db.collection('user').doc(user?.userId).snapshots());
  }

  FutureOr<void> _logout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await db.collection('user').doc(user?.userId).update({'fcmToken': null});
    user = null;
    SharedPrefs.remove();
  }

  Future<QueryDocumentSnapshot?> getUserByUsername(String username) async {
    List<QueryDocumentSnapshot> list = (await db
            .collection('user')
            .where('username', isEqualTo: username)
            .get())
        .docs;
    if (list.isNotEmpty) {
      return list.firstWhere((element) =>
          User.fromJson(element.data().asMap).username == username);
    }
    return null;
  }

  void _setUpStream(Stream<DocumentSnapshot> stream) {
    userStream = stream.listen((event) {
      String? fcmToken = User.fromJson(event.data().asMap).fcmToken;
      if (fcmToken != null && FCMHelper.fcmToken != fcmToken) {
        add(MultipleLoginEvent());
      }
    });
  }
}
