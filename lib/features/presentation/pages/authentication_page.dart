import 'package:flutter/gestures.dart';

import '../../../core/utils/common_imports.dart';
import '../../../core/widgets/custom_elevated_button.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: 24.0.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(AppAssets.mindInventory),
            ),
            const Text(
              'New Here?',
              style: TextStyle(
                fontSize: 50,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            40.0.spaceHeight,
            const Text(
              'Sign Up by username to discover new people and make calls',
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            40.0.spaceHeight,
            CustomElevatedButton(
              text: 'Login',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.loginPage);
              },
            ),
            12.0.spaceHeight,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Sign Up',
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, AppRoutes.signUpPage);
                      },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
