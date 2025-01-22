import 'common_imports.dart';

extension SizedboxEntension on double {
  Widget get spaceHeight => SizedBox(height: this);

  Widget get spaceWidth => SizedBox(width: this);
}

extension PaddingExtension on double {
  EdgeInsets get paddingAll => EdgeInsets.all(this);

  EdgeInsets get paddingHorizontal => EdgeInsets.symmetric(horizontal: this);

  EdgeInsets get paddingVertical => EdgeInsets.symmetric(vertical: this);
}

extension BorderRadiusExtension on double {
  BorderRadius get radiusAll => BorderRadius.all(Radius.circular(this));
}

extension Type on Object? {
  Map<String, dynamic> get asMap => this as Map<String, dynamic>;
}

extension ShowSnackBar on String? {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? get showSnackBar {
    AppConstants.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    return AppConstants.scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(this ?? ''),
        duration: const Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
