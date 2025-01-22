import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/common_imports.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.primary,
          disabledForegroundColor: Colors.white70,
          disabledBackgroundColor: const Color(0xFFf5959f),
          shape: RoundedRectangleBorder(borderRadius: 16.0.radiusAll),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12,
          ),
        ),
        child: isLoading
            ? const SpinKitThreeBounce(
                size: 20,
                color: AppColors.white,
                duration: Duration(milliseconds: 800),
              )
            : Text(text),
      ),
    );
  }
}
