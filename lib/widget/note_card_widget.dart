import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/model/note.dart';

final _lightColors = [
  Colors.lightBlue.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.lightGreen.shade300,
];

class NoteCardWidget extends StatelessWidget {
  const NoteCardWidget({
    Key? key,
    required this.note,
    required this.index,
  }) : super(key: key);

  final Note note;
  final int index;

  /// To display notes by card in main page

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index

    final color = _lightColors[index % _lightColors.length];
    DateTime now = DateTime.parse(note.createdTime);
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    return Card(
      margin: const EdgeInsets.all(10),
      color: color,
      child: Container(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(
              height: 10,
              width: 90,
            ),
            Text(
              note.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
              width: 90,
            ),
            Text(
              note.description,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
