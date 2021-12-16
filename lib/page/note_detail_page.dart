import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db/notes_database.dart';
import 'package:notes_app/model/note.dart';
import 'package:notes_app/page/edit_note_page.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;
  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNote();
  }

// Refresh notes to see the updates

  Future refreshNote() async {
    setState(() => isLoading = true);
    note = await NotesDatabase.instance.readNote(widget.noteId);
    setState(() => isLoading = false);
  }

// Widget to display editable screen

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      DateFormat('yyyy-MMM-dd – kk:mm').format(DateTime.now()),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Title',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      note.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      note.description,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    )
                  ],
                ),
              ),
      );

// To display edit button

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(note: note),
        ));
        refreshNote();
      });

// To display delete button

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await NotesDatabase.instance.delete(widget.noteId);
          Navigator.of(context).pop();
        },
      );
}
