import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_db/FirebaseModel.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<FirebaseModel> firebaseModel = [];
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  FirebaseModel returnModel(DatabaseEvent event) {
    Map<String, dynamic> data = jsonDecode(jsonEncode(event.snapshot.value));
    final jsonModel = Map<String, dynamic>.from(data);
    var fbModel = FirebaseModel.fromJson(jsonModel);
    return fbModel;
  }

  @override
  void initState() {
    super.initState();
    ref.onChildAdded.listen((event) {
      print(" in child added ${event.snapshot.value}");
      var fbModel = returnModel(event);
      fbModel.referenceId = event.snapshot.key;
      firebaseModel.add(fbModel);
      print("firebase model ${fbModel.name}");
      setState(() {});
    });
    ref.onChildChanged.listen((event) {
      var fbModel = returnModel(event);
      fbModel.referenceId = event.snapshot.key;
      int index = firebaseModel.indexWhere((element) {
        return element.name == fbModel.name &&
            element.rollno == fbModel.rollno &&
            element.firebaseModelClass == fbModel.firebaseModelClass;
      });
      firebaseModel.removeAt(index);
      firebaseModel.insert(index, fbModel);

      print(" in child changed ${event.snapshot.value}");
    });
    ref.onChildRemoved.listen((event) {
      var fbModel = returnModel(event);

      firebaseModel.removeWhere((element) {
        return element.name == fbModel.name &&
            element.rollno == fbModel.rollno &&
            element.firebaseModelClass == fbModel.firebaseModelClass;
      });
      setState(() {});
      print(" in child removed ${event.snapshot.value}");
    });
  }

  Future<void> _addInDb([FirebaseModel? firebaseModel]) async {
    TextEditingController nameController = new TextEditingController();
    TextEditingController classController = new TextEditingController();
    TextEditingController rollNoController = new TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool isUpdate = false;
    if (firebaseModel?.name?.isNotEmpty == true) {
      isUpdate = true;
      nameController.text = firebaseModel?.name ?? "";
      classController.text = firebaseModel?.firebaseModelClass ?? "";
      // rollNoController.text = firebaseModel?.rollno??"";
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add/Update"),
          content: SingleChildScrollView(
              child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(hintText: "Enter name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: classController,
                  decoration: InputDecoration(hintText: "Enter class"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter class';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: rollNoController,
                  decoration: InputDecoration(hintText: "Enter roll no"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter rollno';
                    }
                    return null;
                  },
                ),
                TextButton(
                  child: const Text('Approve'),
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      if (isUpdate == true) {
                        firebaseModel?.name = nameController.text;
                        firebaseModel?.firebaseModelClass =
                            classController.text;
                        firebaseModel?.rollno =
                            int.parse(rollNoController.text);
                        ref
                            .child(firebaseModel?.referenceId ?? "")
                            .update((firebaseModel ?? FirebaseModel()).toJson())
                            .then((value) {});
                      } else {
                        var firebaseModel = FirebaseModel(
                            name: nameController.text,
                            firebaseModelClass: classController.text.toString(),
                            rollno:
                                int.parse(rollNoController.text.toString()));
                        ref.push().set(firebaseModel.toJson()).then((value) {});
                      }
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.separated(
        itemCount: firebaseModel.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Text(firebaseModel[index].name ?? ""),
              IconButton(
                  onPressed: () {
                    _addInDb(firebaseModel[index]);
                  },
                  icon: Icon(Icons.edit)),
              IconButton(
                  onPressed: () {
                    ref.child(firebaseModel[index].referenceId ?? "").remove();
                  },
                  icon: Icon(Icons.delete))
            ],
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 10,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addInDb,
        tooltip: 'Add Database',
        child: const Icon(Icons.add),
      ),
    );
  }
}
