import 'package:flutter/material.dart';

/// Shared auth form field: label, leading icon, visibility toggle for
/// passwords and accessible inline error text (Material error text is
/// automatically announced when validation fails).
class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    required this.prefixIcon,
    this.controller,
    this.keyboardType,
    this.obscure = false,
    this.validator,
    this.autofillHints,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  final String label;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _obscured = false;
  bool _hasBeenVisible = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: widget.obscure
            ? Semantics(
                label: _obscured
                    ? 'Show ${widget.label.toLowerCase()}'
                    : 'Hide ${widget.label.toLowerCase()}',
                button: true,
                child: IconButton(
                  tooltip: _obscured ? 'Show' : 'Hide',
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscured = !_obscured;
                      _hasBeenVisible = true;
                    });
                  },
                ),
              )
            : null,
      ),
      keyboardType: widget.keyboardType,
      obscureText: _obscured,
      validator: (value) {
        final error = widget.validator?.call(value);
        if (error != null && widget.obscure && _hasBeenVisible) {
          // Once revealed, keep the text visible so the user can check it
          // while fixing the error — a small but real UX detail.
          setState(() => _obscured = false);
        }
        return error;
      },
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofocus: widget.autofocus,
    );
  }
}
