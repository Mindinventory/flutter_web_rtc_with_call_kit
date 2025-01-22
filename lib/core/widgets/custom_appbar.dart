import '../utils/common_imports.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? centerTitle;
  final TextStyle? titleStyle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.centerTitle = true,
    this.titleStyle,
    this.leading,
    this.actions,
    this.backgroundColor = AppColors.primary,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: getTitle,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: getLeading,
      actions: actions,
    );
  }

  Widget? get getTitle {
    if (title != null) {
      return Text(
        title ?? '',
        style: titleStyle ??
            const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
      );
    }
    return null;
  }

  Widget? get getLeading {
    if (leading != null) {
      return leading;
    } else {
      if (AppConstants.navigatorKey.currentState?.canPop() ?? false) {
        return IconButton(
          onPressed: () async {
            dismissFocus();
            await Future.delayed(const Duration(milliseconds: 200));
            Navigator.pop(AppConstants.navigatorKey.currentContext!);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        );
      }
    }
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
