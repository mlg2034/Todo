import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddToDoPage extends StatefulWidget {
  final Map? todo;
  const AddToDoPage({super.key ,  this.todo});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  TextEditingController titleEditingController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit= false;
  @override
  void initState() {
    final todo=widget.todo;
     if(todo!=null){
      isEdit=true;
      final title = todo['title'];
      final description = todo['description'];
      titleEditingController.text=title;
      descriptionController.text=description;
     }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEdit?'Edit ToDo':'Add ToDo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleEditingController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              hintText: 'Description',
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height: 16,
          ),
          GestureDetector(
            onTap: updateData,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), color: Colors.grey),
              child: Center(
                  child: Text(
                isEdit?'Update':'Submit',
                style: TextStyle(fontSize: 20),
              )),
              width: double.infinity,
              height: 40,
            ),
          )
        ],
      ),
    );
  }
  Future<void> updateData()async{
    final todo=widget.todo;
    if(todo==null){
      print('Error with update data');
      return;

    }
    final id=todo['_id'];
    final title = titleEditingController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
     final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body),
         headers: {'Content-type': 'application/json'}
         );
    if (response.statusCode == 200) {
      showSuccsessMessage( 'Updated Success');
    } else {
      showErrorMessage('Updated Error');
    }

  }

  Future<void> submitData() async {
    final title = titleEditingController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body),
         headers: {'Content-type': 'application/json'}
         );
    if (response.statusCode == 201) {
      showSuccsessMessage( 'Creation Success');
      titleEditingController.text='';
      descriptionController.text='';
    } else {
      showErrorMessage('Creation Error');
    }

  }

  void showSuccsessMessage(String message) {
    final snackBar = SnackBar(
        content: Center(
      child: Text(message),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
   void showErrorMessage(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
        content: 
          Center(
            
              child: Text(message ,style: TextStyle(color: Colors.white),),
            ),
        );
        
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
 
}
