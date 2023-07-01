import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldOutline extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? textInputType;
  final void Function(String)? onSubmit;
  final void Function(String) onChange;
  final String? Function(String?)? validator;
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
  final FocusNode focusNode;
  final VoidCallback? onSuffixIconClick;
  final VoidCallback? onPrefixIconClick;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldOutline({
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
    required this.controller,
    required this.focusNode,
    required this.onChange,
  }) : super(key: key);

  @override
  _TextFieldOutlineState createState() => _TextFieldOutlineState();
}

class _TextFieldOutlineState extends State<TextFieldOutline> {
  var _hasError = false;

  @override
  void initState() {
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
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.textInputType ?? TextInputType.text,
          onFieldSubmitted: widget.onSubmit,
          onChanged: (text) {
            setState(() {
              widget.onChange(text);
            });
          },
          validator: (value) {
            if (widget.validator != null) {
              if (widget.validator!(value) != null) {
                setState(() {
                  _hasError = true;
                });
              } else {
                setState(() {
                  _hasError = false;
                });
              }
            }
            return widget.validator!(value);
          },
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
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColor,
            contentPadding: widget.padding,
            focusColor: Colors.black,
            counterText: "",
            border: widget.controller.text.isNotEmpty
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
            enabledBorder: widget.controller.text.isNotEmpty
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
                            : widget.focusNode.hasFocus ||
                                    widget.controller.text.isNotEmpty
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
                            : widget.focusNode.hasFocus ||
                                    widget.controller.text.isNotEmpty
                                ? widget.focusBorderColor
                                : widget.unFocusBorderColor,
                      ))),
                    ),
                  )
                : null,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
