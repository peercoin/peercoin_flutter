import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class SetupProgressIndicator extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final int step;

  const SetupProgressIndicator(
    this.step, {
    Key? key,
  })  : preferredSize = const Size.fromHeight(50.0),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).padding,
      color: Theme.of(context).primaryColor,
      child: StepProgressIndicator(
        totalSteps: 5,
        currentStep: step,
        selectedColor: Theme.of(context).colorScheme.secondary,
        unselectedColor: Theme.of(context).colorScheme.secondaryContainer,
        roundedEdges: const Radius.circular(90),
        size: 4,
      ),
    );
  }
}
