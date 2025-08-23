import 'package:flutter/material.dart';

class TextAreaGroup extends StatelessWidget {
  const TextAreaGroup({
    super.key,
    required this.textType,
    required this.hintText,
    required this.textHeight,
    required this.textWidth,
    required this.errorText,
    required this.controller,
  });

  final String textType;
  final double textHeight;
  final double textWidth;
  final String hintText;
  final String errorText;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
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
                  ),
                ),
              ),
            ),
          if (textType == 'TextFormField')
            SizedBox(
              width: textWidth,
              height: textHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  // horizontal: 8,
                  // vertical: 20,
                ),
                child: TextFormField(
                  controller: controller,
                  validator: (value) {
                    if (errorText.isEmpty) return null;
                    return value!.isEmpty ? errorText : null;
                  },
                  decoration: InputDecoration(
                    // border: UnderlineInputBorder(),
                    labelText: hintText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
