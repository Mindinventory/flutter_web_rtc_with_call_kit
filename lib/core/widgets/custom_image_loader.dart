import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../utils/common_imports.dart';

class CustomImageLoader extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final bool isRounded;
  final BorderRadius? borderRadius;

  const CustomImageLoader({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.isRounded = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: isRounded ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isRounded ? null : borderRadius,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: isRounded ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: const CupertinoActivityIndicator(),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          shape: isRounded ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isRounded ? null : borderRadius,
          image: DecorationImage(
            image: AssetImage(
              isRounded
                  ? AppAssets.placeHolderRounded
                  : AppAssets.placeHolderRectangle,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
