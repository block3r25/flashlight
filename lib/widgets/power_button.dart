import 'package:flutter/material.dart';

class PowerButton extends StatelessWidget {
  const PowerButton({
    required this.isOn,
    required this.isBusy,
    required this.diameter,
    required this.accentColor,
    required this.onPressed,
    super.key,
  });

  final bool isOn;
  final bool isBusy;
  final double diameter;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonColor = isOn ? accentColor : const Color(0xFF202127);
    final iconColor = isOn ? const Color(0xFF17130B) : const Color(0xFF797B84);

    return Semantics(
      button: true,
      toggled: isOn,
      label: 'Flashlight',
      hint: isOn ? 'Turn flashlight off' : 'Turn flashlight on',
      child: GestureDetector(
        onTap: isBusy ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: buttonColor,
            border: Border.all(
              color: isOn
                  ? accentColor.withValues(alpha: 0.9)
                  : const Color(0xFF3A3B43),
              width: 1.5,
            ),
            boxShadow: [
              if (isOn)
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.32),
                  blurRadius: 46,
                  spreadRadius: 5,
                ),
            ],
          ),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isBusy ? 0.92 : 1,
              child: Icon(
                Icons.power_settings_new,
                size: diameter * 0.39,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
