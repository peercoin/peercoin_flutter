import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class SetupProgressIndicator extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;
  final int step;

  SetupProgressIndicator(
    this.step, {
    Key? key,
  })  : preferredSize = Size.fromHeight(50.0),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).padding,
      color: Theme.of(context).primaryColor,
      child: StepProgressIndicator(
        totalSteps: 4,
        currentStep: step,
        selectedColor: Theme.of(context).colorScheme.secondary,
        unselectedColor: Colors.white,
        roundedEdges: Radius.circular(90),
        size: 4,
        padding: 4,
      ),
    );
  }
}
