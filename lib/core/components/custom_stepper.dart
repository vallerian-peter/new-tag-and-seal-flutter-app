import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
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
    final cardColor = isDark
        ? Theme.of(context).colorScheme.surface.withAlpha(50)
        : Colors.white;
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

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const controlsHeight = 104.0;

    return Stack(
      children: [
        SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(bottom: bottomInset + controlsHeight + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom Stepper Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: shadow,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
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
                                  _buildStepConnector(
                                    context,
                                    isCompleted,
                                    primary,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: shadow,
                  ),
                  child: steps[currentStep].content,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomInset,
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
        color: isActive || isCompleted ? primary : background,
        border: Border.all(
          color: isActive || isCompleted ? primary : outline,
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
            ? Icon(Icons.check, color: whiteColor, size: 20)
            : Icon(
                icon,
                color: isActive
                    ? const Color(0xFFBEBEBE)
                    : isCompleted
                    ? whiteColor
                    : primary,
                size: 18,
              ),
      ),
    );
  }

  Widget _buildStepConnector(
    BuildContext context,
    bool isCompleted,
    Color primary,
  ) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted ? primary : primary.withValues(alpha: 0.2),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? Color.fromARGB(255, 85, 85, 85) : cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        boxShadow: shadow.isEmpty
            ? <BoxShadow>[]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
      ),
      constraints: const BoxConstraints(minHeight: 88),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark
                        ? Colors.grey
                        : primary.withValues(alpha: 0.3),
                  ),
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
                          ? (finalStepButtonText ??
                                continueButtonText ??
                                'Register')
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
