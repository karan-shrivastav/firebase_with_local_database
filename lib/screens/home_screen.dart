import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_project/localDatabase/services/todo_functions.dart';
import 'package:task_project/localDatabase/widgets/add_task_widget.dart';
import 'package:task_project/models/sql_model.dart';
import 'package:task_project/widgets/add_task.dart';
import 'package:task_project/widgets/default_text_field.dart';

class HomePage extends StatefulWidget {
  static const route = '/home-screen';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  bool isConnected = false;
  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> _create() async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: Colors.brown,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return const AddTask();
        });
  }

  Future<void> _createLocalData() async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: Colors.brown,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return AddTaskLocal(
            onSubmit: (Map<String, String> data) async {
              final title = data['title'];
              final description = data['description'];
              final status = data['status'];
              await todoDB.create(
                  title: title ?? '', description: description ?? '', );
              if (!mounted) return;
              fetchTodos();
              Navigator.of(context).pop();
            },
          );
        });
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _titleController.text = documentSnapshot['title'];
      _descriptionController.text = documentSnapshot['description'].toString();
      _statusController.text = documentSnapshot['status'];
    }
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: Colors.brown,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            25.0,
                          ),
                        ),
                        primary: Colors.red,
                      ),
                      child: const Text('Update'),
                      onPressed: () async {
                        final String title = _titleController.text;
                        final String description = _descriptionController.text;
                        final String status = _statusController.text;
                        if (title != null) {
                          await _tasks.doc(documentSnapshot!.id).update({
                            "title": title,
                            "description": description,
                            "status": status,
                          });
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _updateLocalData(
      int id, String? title, String? description) async {
    _titleController.text = title ?? '';
    _descriptionController.text = description ?? '';
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: Colors.brown,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            25.0,
                          ),
                        ),
                        primary: Colors.red,
                      ),
                      child: const Text('Update'),
                      onPressed: () async {
                        final String title = _titleController.text;
                        final String description = _descriptionController.text;
                        todoDB.update(
                            id: id, title: title, description: description);
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _delete(String productId) async {
    await _tasks.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have successfully deleted a Data'),
      ),
    );
  }

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    fetchTodos();
    _connectivity = Connectivity();
    _checkConnection();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result;
      });
    });
  }

  Future<void> _checkConnection() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    setState(() {
      _connectionStatus = result;
    });
  }

  Future<List<SQLModel>>? futureTodos;
  final todoDB = TodoFunctions();

  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchTodos();
    if (_connectionStatus == ConnectivityResult.none) {
      isConnected = false;
      print('Not connected');
    } else {
      isConnected = true;
      print('Connected');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('All Tasks')),
      ),
      drawer: const SizedBox(),
      body: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          // Return your content for each tab here
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (context) => Center(
                  child: isConnected
                      ? StreamBuilder(
                          stream: _tasks.snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                            if (streamSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (!streamSnapshot.hasData ||
                                streamSnapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('No tasks available.'),
                              );
                            } else {
                              return ListView.builder(
                                itemCount: streamSnapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final DocumentSnapshot documentSnapshot =
                                      streamSnapshot.data!.docs[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        documentSnapshot['title'].toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        documentSnapshot['description']
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      trailing: SizedBox(
                                        width: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                _update(streamSnapshot
                                                    .data!.docs[index]);
                                                setState(() {});
                                              },
                                              child: const Icon(
                                                Icons.edit,
                                                size: 20,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                _delete(streamSnapshot
                                                    .data!.docs[index].id);
                                                setState(() {});
                                              },
                                              child: const Icon(
                                                Icons.delete,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {},
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        )
                      : FutureBuilder<List<SQLModel>>(
                          future: futureTodos,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              if (snapshot.hasData && snapshot.data != null) {
                                final todos = snapshot.data!;
                                return todos.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No tasks available.',
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: todos.length,
                                        itemBuilder: (context, index) {
                                          final todo = todos[index];
                                          return Card(
                                            child: ListTile(
                                              title: Text(
                                                todo.title,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Text(
                                                todo.description ??'',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              trailing: SizedBox(
                                                width: 50,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        _updateLocalData(
                                                          todo.id,
                                                          todo.title,
                                                          todo.description,
                                                        );
                                                        Navigator.of(context)
                                                            .pop();

                                                        setState(() {});
                                                      },
                                                      child: const Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        await todoDB
                                                            .delete(todo.id);
                                                        fetchTodos();
                                                        setState(() {});
                                                      },
                                                      child: const Icon(
                                                        Icons.delete,
                                                        size: 20,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                              } else {
                                return const Center(
                                  child: Text(
                                    'No data available',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                ),
              );
            case 1:
              return CupertinoTabView(
                builder: (context) => const Center(
                  child: Text('Search Screen'),
                ),
              );
            case 2:
              return CupertinoTabView(
                builder: (context) => const Center(
                  child: Text('Settings Screen'),
                ),
              );
            default:
              return CupertinoTabView(
                builder: (context) => const Center(
                  child: Text('Error'),
                ),
              );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          onPressed: () async {
            if (isConnected) {
              _create();
            } else {
              _createLocalData();
              setState(() {});
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
