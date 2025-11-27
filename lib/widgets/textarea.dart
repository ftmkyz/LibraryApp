import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextAreaGroup extends StatelessWidget {
  const TextAreaGroup({
    super.key,
    required this.textType,
    required this.hintText,
    required this.textHeight,
    required this.textWidth,
    required this.errorText,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  final String textType;
  final double textHeight;
  final double textWidth;
  final String hintText;
  final String errorText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          if (textType == 'TextField')
            SizedBox(
              width: textWidth,
              height: textHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: hintText,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
              ),
            ),
          if (textType == 'TextFormField')
            SizedBox(
              width: textWidth,
              height: textHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(),
                child: TextFormField(
                  controller: controller,
                  validator:
                      validator ??
                      (value) {
                        if (errorText.isEmpty) return null;
                        return value!.isEmpty ? errorText : null;
                      },
                  decoration: InputDecoration(
                    // hintText: hintText,
                    labelText: hintText,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelStyle: TextStyle(
                      color:
                          theme.colorScheme.error, // Label rengi buradan gelir
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  // ignore: deprecated_member_use
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
