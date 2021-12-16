import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:notes_app/db/notes_database.dart';
import 'package:notes_app/model/note.dart';
import 'package:http/http.dart' as http;
import 'package:notes_app/page/edit_note_page.dart';
import 'package:notes_app/page/note_detail_page.dart';
import 'package:notes_app/widget/note_card_widget.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];
  bool isLoading = false;
  late var controller = TextEditingController();
  String name = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    Future.delayed(Duration.zero, () => asyncMethod());
    refreshNotes();
    fetchNotes();
  }

// Implementation of Dispose pattern callable

  @override
  void dispose() {
    NotesDatabase.instance.close();
    super.dispose();
  }

  void asyncMethod() async {
    final name = await openDialog();
    if (name == null || name.isEmpty) return;
    setState(() => this.name = name);
    refreshNotes();
  }

// This function is for fetching using json

  void fetchNotes() async {
    if (notes.isEmpty) {
      var response = await http.get(Uri.parse(
          'https://run.mocky.io/v3/9700e702-6c72-4918-b091-fa2d04e4e69c'));
      var note = <Note>[];
      if (response.statusCode == 200) {
        var notesJson = json.decode(response.body.toString());
        if (notesJson["status"] == "success") {
          var array = notesJson["Notes"];
          for (var val in array) {
            note.add(Note.fromjson(val));
          }
        }
      }
      setState(() {
        notes = note;
      });
    } else {
      refreshNotes();
    }
  }

// To refresh the notes

  Future refreshNotes() async {
    setState(() => isLoading = true);
    notes = await NotesDatabase.instance.readAllNotes();
    setState(() => isLoading = false);
  }

//build method

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notes',
            style: TextStyle(fontSize: 24),
          ),
        ),
        body: notes.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.only(top: 60.0, left: 20.0)),
                        const Text(
                          'Welcome   ',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.normal),
                        ),
                        Text(name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Center(
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : notes.isEmpty
                                ? const Text(
                                    'No Notes',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 24),
                                  )
                                : buildNotes()),
                  ],
                ),
              )
            : const Center(
                child: Text(
                  'Add notes',
                  style: TextStyle(fontSize: 20),
                ),
              ),

        // To add notes using floating action button

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEditNotePage()),
            );
            refreshNotes();
          },
        ),
      );

// To build notes to display in Listview

  Widget buildNotes() => ListView.builder(
        itemCount: notes.length,
        padding: const EdgeInsets.only(bottom: 120),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final note = notes[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailPage(noteId: note.id!),
              ));
              refreshNotes();
            },
            child: NoteCardWidget(note: note, index: index),
          );
        },
      );

// To display dialog box to enter name of user

  Future openDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Your name?"),
          content: TextField(
              decoration: const InputDecoration(hintText: 'Enter your name'),
              controller: controller,
              onSubmitted: (_) async {
                submit();
                if (notes.length > 1) refreshNotes();
              }),
          actions: [
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                submit();
                if (notes.length > 1) {
                  refreshNotes();
                }
              },
            )
          ],
        ),
      );

// This function to submit the name entered by user

  void submit() {
    Navigator.of(context).pop(controller.text);
    controller.clear();
  }
}
