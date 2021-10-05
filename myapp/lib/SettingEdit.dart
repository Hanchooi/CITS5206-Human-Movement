import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import './main.dart';
import './Setting.dart';
import './editLocation.dart';

class SettingEdit extends StatefulWidget {
  final List<List<dynamic>> field;
  const SettingEdit({Key? key, required this.field}) : super(key: key);

  @override
  _SettingEditState createState() => _SettingEditState();
}

class _SettingEditState extends State<SettingEdit> {
  //List<List<dynamic>> fields = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Visited Places'),
          backgroundColor: Colors.green[700],
        ),
        body: ListView.builder(
          itemCount: widget.field.length,
          itemBuilder: (context, index) {
            if (index < 2) {
              return Container();
            } else {
              final item = widget.field[index];
              return Post(item: item);
            }
            /*ListTile(
              title: Text(fields[index].toString()),
            ),*/
          },
        ),
      ),
    );
  }
}

class Post extends StatefulWidget {
  final item;
  const Post({Key? key, required this.item}) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  Future<void> deleteLocation(String name) async {
    String csv = "";

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/locations.csv";
    print("path:" + path);

    final input = new File(path).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(new CsvToListConverter())
        .toList();

    for (int i = 2; i < fields.length; i++) {
      List<dynamic> element = [];
      element = fields[i];
      if (element[2] == name) {
        fields.remove(element);
        print("remove done");
      }
    }

    File file = new File(path);
    await file.delete();
    csv = const ListToCsvConverter().convert(fields);
    await file.writeAsString(csv);

    print(fields);
  }

  @override
  Widget build(BuildContext context) {
    location thislocation = new location(0.0, 0.0);
    thislocation.longitude = widget.item[0];
    thislocation.latitude = widget.item[1];

    //String name = widget.item[2];
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              widget.item[2],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          new FloatingActionButton.extended(
            key: Key('edit'),
            heroTag: null,
            onPressed: () {
              Navigator.push(
                this.context,
                MaterialPageRoute(
                    builder: (context) => editLocation(item: widget.item)),
              );
            },
            label: Text('Edit'),
            icon: const Icon(Icons.edit),
            backgroundColor: Colors.red,
          ),
          new FloatingActionButton.extended(
            key: Key('delete'),
            heroTag: null,
            onPressed: () async{
              await deleteLocation(widget.item[2]);
              Navigator.push(
                this.context,
                MaterialPageRoute(
                    builder: (context) => Setting(thislocation: thislocation)),
              );
            },
            label: Text(''),
            icon: const Icon(Icons.delete),
            backgroundColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
