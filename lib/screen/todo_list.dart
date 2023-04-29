import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo/screen/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items=[];
  bool isLoading= true;
  
    @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchData,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context , index){
            final item=items[index];
            final id= item['_id'] as String;
            return ListTile(
              leading: CircleAvatar(child: Text('${index +1}')),
              title: Text(item['title']),
              subtitle: Text(item['description']),
              trailing: PopupMenuButton(
                onSelected: (value){
                  if(value=='edit'){
                    navigateToEditPage(item);
                  }else if(value=='delete'){
                    deleteById(id);
                  }
                },
                itemBuilder: (context){
                
                return [
                  PopupMenuItem(child: Icon(Icons.edit) , value: 'edit',),
                  PopupMenuItem(child: Icon(Icons.delete) , value: 'delete',),
                ]
                ;
              }),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text('Add'),
      ),
    );
  }

 Future <void> navigateToAddPage() async{
    final route = MaterialPageRoute(builder: (context) => AddToDoPage());
   await Navigator.push(context, route);
    setState(() {
      isLoading=true;
    });
    fetchData();

  }
    Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(builder: (context) => AddToDoPage(todo: item,));
    Navigator.push(context, route);
     await Navigator.push(context, route);
    setState(() {
      isLoading=true;
    });
  }

Future<void> deleteById(String id)async{
  final url='https://api.nstack.in/v1/todos/$id';
  final uri= Uri.parse(url);
  final response=await http.delete(uri);
  if(response.statusCode==200){
    final filtered=items.where((element)=>element['_id']!=id).toList();
    setState(() {
      items=filtered;
    });
    print('success deleted');
    showSuccsessMessage('Delted Success!');
  }
  else{
    print('error with delete');
    showErrorMessage('Unabled to Delete');
  }
}
  Future<void> fetchData() async {
  
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if(response.statusCode==200){
      final json = jsonDecode(response.body) as Map;
      final result=json['items'] as List;
      setState(() {
        items=result;
      });
    }
    setState(() {
      isLoading=false;
    });
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
