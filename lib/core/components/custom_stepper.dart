import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<StepperStep> steps;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;
  final bool isLoading;
  final String? continueButtonText;
  final String? backButtonText;
  final String? finalStepButtonText;

  const CustomStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    this.onStepContinue,
    this.onStepCancel,
    this.isLoading = false,
    this.continueButtonText,
    this.backButtonText,
    this.finalStepButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Theme.of(context).colorScheme.surface.withAlpha(50) : Colors.white;
    final shadow = isDark
        ? <BoxShadow>[]
        : <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ];
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    // Height reserved at the bottom so content doesn't go under the floating controls
    const double bottomControlsHeight = 120;

    return Stack(
      children: [
        // Header + scrollable content
        Column(
          mainAxisSize: MainAxisSize.max,
      children: [
        // Custom Stepper Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: shadow,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isActive = currentStep == index;
                final isCompleted = currentStep > index;
                final isLast = index == steps.length - 1;
                
                return Row(
                  children: [
                    _buildStepCircle(
                      context: context,
                      index: index,
                      isActive: isActive,
                      isCompleted: isCompleted,
                      icon: step.icon,
                      primary: primary,
                      onPrimary: onPrimary,
                      background: cardColor,
                      showShadow: shadow.isNotEmpty,
                    ),
                        if (!isLast)
                          _buildStepConnector(context, isCompleted, primary),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        
            // Step Content (scrollable, with extra bottom padding so it can scroll behind the controls)
            Expanded(
              child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: shadow,
            ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        steps[currentStep].content,
                        const SizedBox(height: bottomControlsHeight),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Floating controls at the bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildStepControls(
            context,
            cardColor,
            shadow,
            primary,
            onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCircle({
    required BuildContext context,
    required int index,
    required bool isActive,
    required bool isCompleted,
    required IconData icon,
    required Color primary,
    required Color onPrimary,
    required Color background,
    required bool showShadow,
  }) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.primary.withValues(alpha: 0.3);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted 
            ? primary 
            : background,
        border: Border.all(
          color: isActive || isCompleted 
              ? primary 
              : outline,
          width: 2,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check,
                color: onPrimary,
                size: 20,
              )
            : Icon(
                icon,
                color: isActive 
                    ? onPrimary 
                    : isCompleted 
                        ? onPrimary 
                        : primary,
                size: 18,
              ),
      ),
    );
  }

  Widget _buildStepConnector(BuildContext context, bool isCompleted, Color primary) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted 
            ? primary 
            : primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStepControls(
    BuildContext context,
    Color cardColor,
    List<BoxShadow> shadow,
    Color primary,
    Color onPrimary,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Text colors for dark mode: white text
    final buttonTextColor = isDark ? Colors.white : onPrimary;
    final outlinedButtonTextColor = isDark ? Colors.white : primary;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: primary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  backButtonText ?? 'Back',
                  style: TextStyle(
                    fontSize: Constants.textSize,
                    fontWeight: FontWeight.w600,
                    color: outlinedButtonTextColor,
                  ),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onStepContinue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: primary,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      currentStep == steps.length - 1
                          ? (finalStepButtonText ?? continueButtonText ?? 'Register')
                          : (continueButtonText ?? 'Continue'),
                      style: TextStyle(
                        fontSize: Constants.textSize,
                        fontWeight: FontWeight.w600,
                        color: buttonTextColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class StepperStep {
  final String title;
  final String subtitle;
  final Widget content;
  final IconData icon;

  const StepperStep({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
  });
}
