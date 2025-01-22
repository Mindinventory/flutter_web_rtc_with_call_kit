import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/common_imports.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../bloc/auth_bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode usernameFocus = FocusNode();
  TextEditingController usernameController = TextEditingController();

  AuthBloc authBloc = sl<AuthBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Login',
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            padding: 24.0.paddingAll,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: constraint.maxHeight - kToolbarHeight),
              child: IntrinsicHeight(
                child: BlocConsumer<AuthBloc, AuthState>(
                  bloc: authBloc,
                  listener: (context, state) {
                    if (state is AuthSuccessState) {
                      state.message.showSnackBar;
                      dismissFocus();
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.homePage, (route) => false);
                    } else if (state is AuthFailureState) {
                      state.message.showSnackBar;
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        CustomTextField(
                          hintText: 'Username',
                          controller: usernameController,
                          focusNode: usernameFocus,
                          autoFocus: true,
                          maxLength: 24,
                        ),
                        const Spacer(),
                        CustomElevatedButton(
                          text: 'Submit',
                          onPressed: () {
                            if (usernameController.text.trim().isEmpty) {
                              'please enter username'.showSnackBar;
                            } else {
                              authBloc.add(
                                LoginEvent(
                                  username: usernameController.text.trim(),
                                ),
                              );
                            }
                          },
                          isLoading: state is AuthLoadingState,
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
