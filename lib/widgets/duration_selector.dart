import 'package:flutter/material.dart';

class DurationSelector extends StatelessWidget {
  final int currentDuration;
  final Function(int) onDurationSelected;

  const DurationSelector({
    required this.currentDuration,
    required this.onDurationSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [5, 10, 15, 20, 25, 30].map((number) {
        final durationInSeconds = number * 60;
        return ChoiceChip(
          label: Text(number.toString()),
          selected: currentDuration == durationInSeconds,
          selectedColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          showCheckmark: false,
          onSelected: (selected) {
            if (selected) {
              onDurationSelected(durationInSeconds);
            }
          },
        );
      }).toList(),
    );
  }
}
