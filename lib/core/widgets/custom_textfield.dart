import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_rtc_with_call_kit/core/utils/extensions.dart';

import '../constant/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autoFocus;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final FocusNode? nextFocusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;
  final GestureTapCallback? onTap;
  final bool readOnly;
  final String hintText;
  final TextStyle? hintStyle;
  final TextStyle? inputTextStyle;
  final Widget? suffix;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;
  final ValueChanged<String>? onChanged;
  final bool? enable;
  final EdgeInsets? contentPadding;
  final TextAlign? textAlign;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.obscureText = false,
    this.textInputAction,
    this.keyboardType,
    this.nextFocusNode,
    this.inputFormatters,
    this.textCapitalization,
    this.onTap,
    this.readOnly = false,
    this.hintStyle,
    this.suffix,
    this.maxLength,
    this.buildCounter,
    this.onChanged,
    this.enable,
    this.contentPadding,
    this.textAlign,
    this.inputTextStyle,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late ValueNotifier<bool> isFocus;

  @override
  void initState() {
    super.initState();
    isFocus = ValueNotifier(false);
    widget.focusNode?.addListener(
      () {
        if (widget.focusNode?.hasFocus ?? false) {
          isFocus.value = true;
        } else {
          isFocus.value = false;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isFocus,
      builder: (context, value, child) {
        return TextField(
          enabled: widget.enable,
          focusNode: widget.focusNode,
          controller: widget.controller,
          autofocus: widget.autoFocus,
          obscureText: widget.obscureText,
          inputFormatters: widget.inputFormatters ?? [],
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          maxLength: widget.maxLength,
          style: widget.inputTextStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
          textAlign: widget.textAlign ?? TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            enabledBorder: OutlineInputBorder(
                borderRadius: 4.0.radiusAll, borderSide: BorderSide.none),
            disabledBorder: OutlineInputBorder(
                borderRadius: 4.0.radiusAll, borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: 4.0.radiusAll,
              borderSide: const BorderSide(
                width: 1,
                color: AppColors.lightGrey,
              ),
            ),
            fillColor: AppColors.white,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            contentPadding: widget.contentPadding ?? 12.0.paddingAll,
            suffixIcon: widget.suffix,
            suffixIconConstraints: const BoxConstraints(maxHeight: 18),
          ),
          buildCounter: widget.buildCounter ??
              (BuildContext? context,
                      {int? currentLength, int? maxLength, bool? isFocused}) =>
                  null,
          onSubmitted: (_) {
            if (widget.nextFocusNode != null) {
              if (FocusScope.of(context).canRequestFocus) {
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              }
            }
          },
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          readOnly: widget.readOnly,
          cursorColor: AppColors.primary,
        );
      },
    );
  }
}
