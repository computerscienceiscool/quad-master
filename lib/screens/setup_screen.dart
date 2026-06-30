import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/app_state.dart';
import '../models/quadrant.dart';
import '../utils/color_utils.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _uuid = const Uuid();
  int _currentStep = 0;

  final List<TextEditingController> _nameControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<Color> _selectedColors =
      List.from(ColorUtils.defaultQuadrantColors);

  final List<String> _stepTitles = [
    'Name your first quadrant',
    'Name your second quadrant',
    'Name your third quadrant',
    'Name your fourth quadrant',
  ];

  final List<String> _positionHints = [
    'Top-left',
    'Top-right',
    'Bottom-left',
    'Bottom-right',
  ];

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _selectedColors[_currentStep];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const SizedBox(height: 40),
              const Text(
                'Quad Master',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                '"Four corners. Total control."',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    4,
                    (index) => Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index <= _currentStep
                                ? _selectedColors[index]
                                : Colors.grey[300],
                          ),
                        )),
              ),

              const SizedBox(height: 32),

              // Current step title
              Text(
                _stepTitles[_currentStep],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '(${_positionHints[_currentStep]})',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Name input
              TextField(
                controller: _nameControllers[_currentStep],
                decoration: InputDecoration(
                  hintText: 'Enter name...',
                  filled: true,
                  fillColor: Color.lerp(currentColor, Colors.white, 0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: currentColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: currentColor, width: 2),
                  ),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 24),

              // Color picker
              const Text(
                'Choose a color:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: ColorUtils.quadrantColors.map((color) {
                  final isSelected = currentColor == color;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedColors[_currentStep] = color;
                    }),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color.lerp(color, Colors.black, 0.5)!,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: ColorUtils.getContrastingTextColor(color),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentColor,
                        foregroundColor:
                            ColorUtils.getContrastingTextColor(currentColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentStep < 3 ? 'Next' : 'Create Board',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canProceed =>
      _nameControllers[_currentStep].text.trim().isNotEmpty;

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _createBoard();
    }
  }

  void _createBoard() {
    final quadrants = List.generate(
        4,
        (index) => Quadrant(
              id: _uuid.v4(),
              name: _nameControllers[index].text.trim(),
              color: _selectedColors[index],
            ));

    context.read<AppState>().createBoard('My Board', quadrants);
  }
}
