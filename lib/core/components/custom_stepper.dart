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
    
    return Column(
      children: [
        // Custom Stepper Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
                    ),
                    if (!isLast) _buildStepConnector(context, isCompleted),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        
        // Step Content
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: steps[currentStep].content,
        ),
        
        const SizedBox(height: 24),
        
        // Step Controls
        _buildStepControls(context),
      ],
    );
  }

  Widget _buildStepCircle({
    required BuildContext context,
    required int index,
    required bool isActive,
    required bool isCompleted,
    required IconData icon,
  }) {
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted 
            ? Constants.primaryColor 
            : Colors.white,
        border: Border.all(
          color: isActive || isCompleted 
              ? Constants.primaryColor 
              : Constants.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : Icon(
                icon,
                color: isActive 
                    ? Colors.white 
                    : isCompleted 
                        ? Colors.white 
                        : Constants.primaryColor,
                size: 18,
              ),
      ),
    );
  }

  Widget _buildStepConnector(BuildContext context, bool isCompleted) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Constants.primaryColor 
            : Constants.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStepControls(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Constants.primaryColor.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  backButtonText ?? 'Back',
                  style: TextStyle(
                    fontSize: Constants.textSize,
                    fontWeight: FontWeight.w600,
                    color: Constants.primaryColor,
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
                backgroundColor: Constants.primaryColor,
                foregroundColor: Colors.white,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      continueButtonText ?? (currentStep == steps.length - 1 ? (finalStepButtonText ?? 'Register') : 'Continue'),
                      style: TextStyle(
                        fontSize: Constants.textSize,
                        fontWeight: FontWeight.w600,
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
