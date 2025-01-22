import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/common_imports.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return const SpinKitRing(
      color: AppColors.primary,
      size: 4,
    );
  }
}
