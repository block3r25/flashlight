import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/flashlight_service.dart';
import '../widgets/power_button.dart';
import '../widgets/pulse_circles.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen>
    with WidgetsBindingObserver {
  static const _accentColor = Color(0xFFFFC857);

  final FlashlightService _flashlight = FlashlightService();
  bool _isOn = false;
  bool _isBusy = false;
  bool? _isAvailable;
  int _operationGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshAvailability());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_turnOffForLifecycle());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAvailability());
    }
  }

  Future<void> _refreshAvailability() async {
    try {
      final available = await _flashlight.isAvailable();
      if (mounted) setState(() => _isAvailable = available);
    } on Object {
      if (mounted) setState(() => _isAvailable = false);
    }
  }

  Future<void> _toggleFlashlight() async {
    if (_isBusy) return;

    final generation = ++_operationGeneration;
    setState(() => _isBusy = true);
    try {
      await HapticFeedback.mediumImpact();
      if (_isOn) {
        await _flashlight.turnOff();
        if (mounted && generation == _operationGeneration) {
          setState(() => _isOn = false);
        }
      } else {
        await _flashlight.turnOn();
        if (mounted && generation == _operationGeneration) {
          setState(() {
            _isOn = true;
            _isAvailable = true;
          });
        }
      }
    } on FlashlightUnavailableException {
      _showFeedback('This device does not have a flashlight.');
    } on FlashlightPermissionException catch (error) {
      _showFeedback(
        error.permanentlyDenied
            ? 'Allow camera access in Settings to use the flashlight.'
            : 'Camera access is needed to use the flashlight.',
      );
    } on Object {
      _showFeedback('The flashlight could not be changed. Please try again.');
    } finally {
      if (mounted && generation == _operationGeneration) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _turnOffForLifecycle() async {
    final generation = ++_operationGeneration;
    if (mounted) {
      setState(() {
        _isOn = false;
        _isBusy = true;
      });
    }

    try {
      await _flashlight.turnOff();
    } on Object {
      if (mounted) {
        _showFeedback('The flashlight could not be turned off automatically.');
      }
    } finally {
      if (mounted && generation == _operationGeneration) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_flashlight.turnOff().catchError((Object _) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 22),
              Row(
                children: [
                  const Icon(
                    Icons.flashlight_on,
                    size: 18,
                    color: _accentColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'FLASHLIGHT',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFE9E9ED),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isAvailable == false
                          ? const Color(0xFF777982)
                          : _accentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAvailable == false ? 'UNAVAILABLE' : 'LED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF858690),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFF25262D)),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final diameter = math.min(
                      176.0,
                      math.max(120.0, constraints.maxHeight * 0.62 / 2.4),
                    );
                    final pulseSize = diameter * 2.4;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: pulseSize,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              PulseCircles(
                                isActive: _isOn,
                                diameter: diameter,
                                color: _accentColor,
                              ),
                              PowerButton(
                                isOn: _isOn,
                                isBusy: _isBusy,
                                diameter: diameter,
                                accentColor: _accentColor,
                                onPressed: _toggleFlashlight,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _isBusy
                                ? 'PLEASE WAIT'
                                : _isOn
                                ? 'ON'
                                : _isAvailable == false
                                ? 'NO FLASH DETECTED'
                                : _isAvailable == null
                                ? 'CHECKING DEVICE'
                                : 'OFF',
                            key: ValueKey((_isBusy, _isOn, _isAvailable)),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: _isOn
                                      ? _accentColor
                                      : const Color(0xFF8A8B94),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Text(
                  'KEEP YOUR DEVICE UNOBSTRUCTED',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF555761),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
