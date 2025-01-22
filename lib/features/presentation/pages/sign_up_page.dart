import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/common_imports.dart';
import '../../../../core/utils/fcm_helper.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../data/model/user.dart';
import '../bloc/auth_bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FocusNode nameFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  AuthBloc authBloc = sl<AuthBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameFocus.dispose();
    usernameFocus.dispose();
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Sign Up',
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
                          hintText: 'Name',
                          controller: nameController,
                          focusNode: nameFocus,
                          nextFocusNode: usernameFocus,
                          autoFocus: true,
                          maxLength: 24,
                          textCapitalization: TextCapitalization.words,
                        ),
                        24.0.spaceHeight,
                        CustomTextField(
                          hintText:
                              'Username (it should be unique to identify)',
                          controller: usernameController,
                          focusNode: usernameFocus,
                          textInputAction: TextInputAction.done,
                          maxLength: 24,
                        ),
                        const Spacer(),
                        CustomElevatedButton(
                          text: 'Submit',
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) {
                              'please enter name'.showSnackBar;
                            } else if (usernameController.text.trim().isEmpty) {
                              'please enter username'.showSnackBar;
                            } else {
                              authBloc.add(
                                SignUpEvent(
                                  user: User(
                                    name: nameController.text,
                                    username: usernameController.text,
                                    fcmToken: FCMHelper.fcmToken,
                                  ),
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
