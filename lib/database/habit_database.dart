import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;
  /*setup



  */
  //initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  //save first date of app startup(for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(
        () => isar.appSettings.put(settings),
      );
    }
  }

  //get first date of app startup(for heatmap)

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*

  CRUD OPERATIONS


  */
  //list of habits
  final List<Habit> currentHabits = [];

  //create -add new habit
  Future<void> addHabit(String habitName) async {
    //create  a new one
    final newHabit = Habit()..name = habitName;

    //save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    //re read from db
    readHabits();
  }

  //read-read saved habits from db
  Future<void> readHabits() async {
    //fetch all the habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits array
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    //update the UI
    notifyListeners();
  }

  //update -check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find the specific habit
    final habit = await isar.habits.get(id);
    //update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        //if habit is completed--> add current date to completedDaysList
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();
          //add current date if its not already in the list
          habit.completedDays.add(DateTime(today.year, today.month, today.day));
        } else {
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        //save the updated habits to db
        await isar.habits.put(habit);
      });
    }
    //reread from db
    readHabits();
  }

  //update -edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    //get the habit name
    final habit = await isar.habits.get(id);

    //update it
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        //save to db
        await isar.habits.put(habit);
      });
    }

    //re read from db
    readHabits();
  }

  //delete-delete habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    //re read from db
    readHabits();
  }
}
