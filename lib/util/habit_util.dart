//given a habit list of completed days
//is the habit completed today
import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completeDays) {
  final today = DateTime.now();
  return completeDays.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day);
}

//prepare heat map dataset

Map<DateTime, int> prepareHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> dataset = {};
  for (var habit in habits) {
    for (var date in habit.completedDays) {
      //normalize date to avoid time mismatch
      final normalisedDate = DateTime(date.year, date.month, date.day);

      //if date already exists,increment its count
      if (dataset.containsKey(normalisedDate)) {
        dataset[normalisedDate] = dataset[normalisedDate]! + 1;
      } else {
        //initialize with count of 1
        dataset[normalisedDate] = 1;
      }
    }
  }
  return dataset;
}
