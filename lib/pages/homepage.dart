import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    //read existing habits on startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  final TextEditingController controller = TextEditingController();

  void checkHabitonoff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabit(Habit habit) {
    controller.text = habit.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: controller,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              //get the new habit name
              String newHabitName = controller.text;
              //save to the db
              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitName);

              //pop box
              Navigator.pop(context);

              //clear controller
              controller.clear();
            },
            child: Text('Save'),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              controller.clear();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure yo want to delete'),
        actions: [
          MaterialButton(
            onPressed: () {
              //get the new habit name

              //save to the db
              context.read<HabitDatabase>().deleteHabit(
                    habit.id,
                  );

              //pop box
              Navigator.pop(context);

              //clear controller
            },
            child: Text('Delete'),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  //create new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Create a new habit'),
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              //get the new habit name
              String newHabitName = controller.text;
              //save to the db
              context.read<HabitDatabase>().addHabit(newHabitName);

              //pop box
              Navigator.pop(context);

              //clear controller
              controller.clear();
            },
            child: Text('Save'),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              controller.clear();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  //build habit List
  Widget _buildHabitList() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();
    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;
    //return Ui
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //get individual habit
        final habit = currentHabits[index];

        //check if habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        //return the UI
        return HabitTile(
          isCompleted: isCompletedToday,
          text: habit.name,
          onChanged: (value) => checkHabitonoff(value, habit),
          editHabit: (context) => editHabit(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
          title: Text(
            'Habit Tracker',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        children: [
          //HEAT MAP
          _buildHeatMap(),

          //HABIT LIST
          _buildHabitList(),
        ],
      ),
    );
  }

  //build heat map
  Widget _buildHeatMap() {
    //access to db
    final habitDatabase = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //Ui
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        //once date is available,build heatmap
        if (snapshot.hasData) {
          return MyHeatMap(
              startDate: snapshot.data,
              datasets: prepareHeatMapDataset(currentHabits));
        }

        //handle case when no date is there
        else {
          return Container();
        }
      },
    );
  }
}
