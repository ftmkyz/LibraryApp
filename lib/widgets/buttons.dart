import 'package:flutter/material.dart';

class ButtonTypesGroup extends StatelessWidget {
  const ButtonTypesGroup({
    super.key,
    required this.enabled,
    required this.buttonType,
    required this.buttonText,
    required this.buttonColor,
    required this.buttonHeight,
    required this.buttonWidth,
  });

  final bool enabled;
  final String buttonType;
  final String buttonText;
  final Color buttonColor;
  final double buttonHeight;
  final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onPressed = enabled ? () {} : null;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          if (buttonType == 'ElevatedButton')
            SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(buttonColor),
                ),
                onPressed: onPressed,
                child: Text(buttonText, style: TextStyle(color: Colors.white)),
              ),
            ),
          if (buttonType == 'FilledButton.tonal')
            SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: FilledButton.tonal(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(buttonColor),
                ),
                onPressed: onPressed,
                child: Text(buttonText, style: TextStyle(color: Colors.white)),
              ),
            ),
          if (buttonType == 'FilledButton')
            SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(buttonColor),
                ),
                onPressed: onPressed,
                child: Text(buttonText, style: TextStyle(color: Colors.white)),
              ),
            ),
          if (buttonType == 'OutlinedButton')
            SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: OutlinedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(buttonColor),
                ),
                onPressed: onPressed,
                child: Text(buttonText, style: TextStyle(color: Colors.white)),
              ),
            ),
          if (buttonType == 'TextButton')
            SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(buttonColor),
                ),
                onPressed: onPressed,
                child: Text('Text', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
