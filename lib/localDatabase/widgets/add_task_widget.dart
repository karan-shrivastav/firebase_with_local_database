import 'package:flutter/material.dart';
import 'package:task_project/models/sql_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_project/widgets/default_text_field.dart';

class AddTaskLocal extends StatefulWidget {
  final SQLModel? todo;
  final ValueChanged<Map<String, String>> onSubmit;
  const AddTaskLocal({
    super.key,
    this.todo,
    required this.onSubmit,
  });

  @override
  State<AddTaskLocal> createState() => _AddTaskLocalState();
}

class _AddTaskLocalState extends State<AddTaskLocal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.brown,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 30,
          bottom: 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextField(
              controller: _titleController,
              hintText: 'Title',
            ),
            const SizedBox(
              height: 15,
            ),
            DefaultTextField(
              controller: _descriptionController,
              hintText: 'Description',
            ),

            const SizedBox(
              height: 15,
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Set border radius here
                  ),
                  primary: Colors.red, // Set the button color to red
                ),
                child: const Text('Submit'),
                onPressed: () async {
                  final title = _titleController.text;
                  final description = _descriptionController.text;
                  widget.onSubmit({
                    'title': title,
                    'description': description,
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


