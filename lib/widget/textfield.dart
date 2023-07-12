import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef TextCallback = Function(String);

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? textInputType;

  final TextInputAction? textInputAction;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final String? hintText;
  final int? maxLines;
  final String? prefixIcon;
  final String? suffixIcon;
  final double height;
  final bool obscureText;
  final bool readOnly;
  final bool enable;
  final bool autoFocus;
  final String? initialValue;
  final void Function()? onTap;
  final Color focusBorderColor;
  final Color unFocusBorderColor;
  final int? maxLength;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  FocusNode? focusNode;
  final VoidCallback? onSuffixIconClick;
  final VoidCallback? onPrefixIconClick;
  final List<TextInputFormatter>? inputFormatters;
  TextCallback? validator;
  TextCallback? onChange;
  TextCallback? onSubmit;

  AppTextField({
    Key? key,
    this.textInputType,
    this.onSubmit,
    this.validator,
    this.textStyle,
    this.hintText,
    this.hintStyle,
    this.maxLines,
    this.prefixIcon,
    this.suffixIcon,
    this.height = 50,
    this.obscureText = false,
    this.readOnly = false,
    this.textInputAction,
    this.enable = true,
    this.autoFocus = false,
    this.initialValue,
    this.onTap,
    this.focusBorderColor = Colors.black,
    this.unFocusBorderColor = Colors.grey,
    this.maxLength,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.fillColor = Colors.transparent,
    this.onSuffixIconClick,
    this.onPrefixIconClick,
    this.inputFormatters,
    this.focusNode,
    required this.controller,
    this.onChange,
  }) : super(key: key) {
    //focusNode ??= FocusNode();
  }

  @override
  _AppTextFieldState createState() => _AppTextFieldState();

  factory AppTextField.builder(TextEditingController controller) {
    return AppTextField(
      controller: controller,
      focusNode: FocusNode(),
      onChange: (s) {},
    );
  }
}

class _AppTextFieldState extends State<AppTextField> {
  var _hasError = false;

  bool get hasFocus => widget.focusNode?.hasFocus ?? false;

  String get text => widget.controller.text;

  bool get iEmpty => text.isEmpty;

  bool get isNotEmpty => text.isNotEmpty;

  @override
  void initState() {
    widget.focusNode ??= FocusNode();
    widget.focusNode?.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var realHeight = widget.height + widget.margin.vertical;
    return SizedBox(
      height: realHeight,
      child: Padding(
        padding: widget.margin,
        child: textField(),
      ),
    );
  }

  Widget textField() {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInputType ?? TextInputType.text,
      onFieldSubmitted: widget.onSubmit,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      style: widget.textStyle ?? const TextStyle(fontSize: 16),
      enabled: widget.enable,
      textAlign: TextAlign.start,
      textInputAction: widget.textInputAction,
      autofocus: widget.autoFocus,
      initialValue: widget.initialValue,
      cursorColor: widget.focusBorderColor,
      onTap: widget.onTap,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      inputFormatters: widget.inputFormatters,
      decoration: inputDecoration(),
      onChanged: (s) {
        setState(() {
          widget.onChange?.call(s);
        });
      },
      validator: (value) {
        final s = value ?? "";
        if (widget.validator != null) {
          if (widget.validator!(s) != null) {
            setState(() {
              _hasError = true;
            });
          } else {
            setState(() {
              _hasError = false;
            });
          }
        }
        return widget.validator!(s);
      },
    );
  }

  InputDecoration inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: widget.fillColor,
      contentPadding: widget.padding,
      focusColor: Colors.black,
      counterText: "",
      border: isNotEmpty
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.focusBorderColor,
              ),
            )
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.unFocusBorderColor,
              ),
            ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: _hasError ? Colors.red : widget.focusBorderColor,
        ),
      ),
      enabledBorder: isNotEmpty
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.unFocusBorderColor,
              ),
            )
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.unFocusBorderColor,
              ),
            ),
      prefixIcon: widget.prefixIcon != null
          ? GestureDetector(
              onTap: widget.onPrefixIconClick,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                    child: SizedBox(
                        child: Image.asset(
                  widget.prefixIcon!,
                  width: 24,
                  height: 24,
                  color: _hasError
                      ? Colors.red
                      : hasFocus || isNotEmpty
                          ? widget.focusBorderColor
                          : widget.unFocusBorderColor,
                ))),
              ),
            )
          : null,
      suffixIcon: widget.suffixIcon != null
          ? GestureDetector(
              onTap: widget.onSuffixIconClick,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                    child: SizedBox(
                        child: Image.asset(
                  widget.suffixIcon!,
                  width: 24,
                  height: 24,
                  color: _hasError
                      ? Colors.red
                      : hasFocus || isNotEmpty
                          ? widget.focusBorderColor
                          : widget.unFocusBorderColor,
                ))),
              ),
            )
          : null,
      hintText: widget.hintText,
      hintStyle:
          widget.hintStyle ?? const TextStyle(fontSize: 16, color: Colors.grey),
    );
  }
}
