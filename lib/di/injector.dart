import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/presentation/bloc/auth_bloc/auth_bloc.dart';
import '../features/presentation/bloc/signaling_bloc/signaling_bloc.dart';

GetIt sl = GetIt.instance;

Future<void> initInjector() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => AuthBloc());
  sl.registerLazySingleton(() => SignalingBloc(authBloc: sl()));
}
