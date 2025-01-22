import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/utils/common_imports.dart';
import 'core/utils/fcm_helper.dart';
import 'features/data/model/user.dart';
import 'features/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMHelper.init();
  await initInjector();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AuthBloc authBloc = sl<AuthBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    String? userPref = SharedPrefs.getUserDetails;
    if (userPref != null) {
      User user = User.fromJson(jsonDecode(userPref));
      authBloc.user = user;
      authBloc.add(UpdateFCMTokenEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: authBloc,
      listener: (context, state) {
        if (state is AuthMultipleLoginState) {
          showMultipleLoginAlertDialog();
        }
      },
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: AppColors.primarySwatch,
            scaffoldBackgroundColor: AppColors.white,
          ),
          navigatorKey: AppConstants.navigatorKey,
          scaffoldMessengerKey: AppConstants.scaffoldMessengerKey,
          onGenerateRoute: AppNavigator.materialAppRoutes,
          initialRoute: authBloc.user == null
              ? AppRoutes.authenticationPage
              : AppRoutes.homePage,
        );
      },
    );
  }

  Future showMultipleLoginAlertDialog() async {
    return await showDialog(
      barrierDismissible: false,
      context: AppConstants.navigatorKey.currentContext!,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: CupertinoAlertDialog(
            title: const Text('User login in multiple device'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.authenticationPage,
                    (route) => false,
                  );
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      },
    );
  }
}
