import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'default_text_field.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

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

            DefaultTextField(
              controller: _statusController,
              hintText: 'Status',
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
                    BorderRadius.circular(25.0),
                  ),
                  primary: Colors.red,
                ),
                child: const Text('Submit'),
                onPressed: () async {
                  print('inside submit');
                  final String title = _titleController.text;
                  final String description = _descriptionController.text;
                  final String status = _statusController.text;
                  final String date = _dateController.text;
                  if (title.isNotEmpty) {
                    try {
                      print('inside try');
                      await _tasks.add({
                        "title": title,
                        "description": description,
                        "status": status,
                      });
                      print('added');
                      _titleController.text = '';
                      _descriptionController.text = '';
                      _dateController.text = '';
                      _statusController.text = '';
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text('Error : $e'),
                        ),
                      );
                    }
                  }

                },
              ),
            )
          ],
        ),
      ),
    );
  }

}
