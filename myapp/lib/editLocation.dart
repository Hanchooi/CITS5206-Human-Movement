import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import './Setting.dart';
import './main.dart';

class editLocation extends StatefulWidget {
  final List<dynamic> item;
  const editLocation({Key? key, required this.item}) : super(key: key);

  @override
  _editLocationState createState() => _editLocationState();
}

class _editLocationState extends State<editLocation> {
  TextEditingController _locationnameController = new TextEditingController();
  TextEditingController _transmodeController = new TextEditingController();
  TextEditingController _Activity1Controller = new TextEditingController();
  TextEditingController _Activity2Controller = new TextEditingController();
  TextEditingController _Activity3Controller = new TextEditingController();
  TextEditingController _enjoy1Controller = new TextEditingController();
  TextEditingController _enjoy2Controller = new TextEditingController();
  TextEditingController _enjoy3Controller = new TextEditingController();
  TextEditingController _CommentController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  location thislocation = new location(0.0,0.0);


  void editvalue(String key, double long, double lat, String locationName, String trans_mode, String Activ1, String enjoy1, String Activ2, String enjoy2, String Activ3, String enjoy3, String comment) async{

    String csv = "";
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path+"/locations.csv";
    print("path:" + path);
    File file = File(path);

    final input = new File(path).openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
    print(fields);

    for(int i =2; i<fields.length; i++) {
      List<dynamic> element = [];
      element = fields[i];
      if (element[2] == key) {
        element[0]=long;
        element[1]=lat;
        element[2]=locationName;
        element[3]=trans_mode;
        element[4]=Activ1;
        element[5]=enjoy1;
        element[6]=Activ2;
        element[7]=enjoy2;
        element[8]=Activ3;
        element[9]=enjoy3;
        element[10]=comment;
      }
    }

    await file.delete();
    csv = const ListToCsvConverter().convert(fields);
    await file.writeAsString(csv);
    //await file.delete();
    print(fields);
  }

  @override
  void initState() {
    super.initState();

    _locationnameController = TextEditingController(text: widget.item[2]);
    _transmodeController = TextEditingController(text: widget.item[3]);
    _Activity1Controller = TextEditingController(text: widget.item[4]);
    _enjoy1Controller = TextEditingController(text: widget.item[5].toString());
    _Activity2Controller = TextEditingController(text: widget.item[6]);
    _enjoy2Controller = TextEditingController(text: widget.item[7].toString());
    _Activity3Controller = TextEditingController(text: widget.item[8]);
    _enjoy3Controller = TextEditingController(text: widget.item[9].toString());
    _CommentController = TextEditingController(text: widget.item[10]);
    thislocation.longitude = widget.item[0];
    thislocation.latitude = widget.item[1];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Marker'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                key: Key('location_input'),
                controller: _locationnameController,
                onChanged: (text) {
                  _locationnameController = TextEditingController(text: text);
                },
                autofocus: true,
                //autocorrect: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name this location',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 18.0),

              TextFormField(
                key: Key('transport_input'),
                controller: _transmodeController,
                onChanged: (text) {
                  _transmodeController = TextEditingController(text: text);
                },
                autofocus: true,
                //autocorrect: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Usual Mode of Transport',
                  prefixIcon: Icon(Icons.emoji_transportation),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 18.0),

              TextFormField(
                key: Key('Activity_one'),
                controller: _Activity1Controller,
                onChanged: (text) {
                  _Activity1Controller = TextEditingController(text: text);
                },
                autofocus: true,
                //autocorrect: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Activity Name 1 (1=Most usual)',
                    prefixIcon: Icon(Icons.local_activity_outlined)
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Must fill at least one activity';
                  }
                  return null;
                },
              ),

              TextFormField(
                key: Key('Enjoy_one'),
                controller: _enjoy1Controller,
                onChanged: (text) {
                  _enjoy1Controller = TextEditingController(text: text);
                },
                autofocus: true,
                //autocorrect: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enjoyment Rating 1-10',
                    prefixIcon: Icon(Icons.mood)
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || int.parse(value)>10) {
                    return 'Max rate is 10';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.0),

              TextFormField(
                controller: _Activity2Controller,
                onChanged: (text) {
                  _Activity2Controller = TextEditingController(text: text);
                },
                autofocus: true,
                //autocorrect: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Activity Name 2 (2=usual)',
                  prefixIcon: Icon(Icons.local_activity_outlined),
                ),
              ),

              TextFormField(
                controller: _enjoy2Controller,
                onChanged: (text) {
                  _enjoy2Controller = TextEditingController(text: text);
                },
                autofocus: true,
                //autocorrect: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enjoyment Rating 1-10',
                    prefixIcon: Icon(Icons.mood)
                ),
                validator: (value) {
                  if(_Activity2Controller.text != "") {
                    if (value == null || value.isEmpty ||
                        int.parse(value) > 10) {
                      return 'Max rate is 10';
                    }
                    return null;
                  }
                },
              ),

              SizedBox(height: 20.0),

              TextFormField(
                controller: _Activity3Controller,
                onChanged: (text) {
                  _Activity3Controller = TextEditingController(text: text);
                },
                autofocus: true,
                //autocorrect: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Activity Name 3 (3=Least usual)',
                  prefixIcon: Icon(Icons.local_activity_outlined),
                ),
              ),

              TextFormField(
                controller: _enjoy3Controller,
                onChanged: (text) {
                  _enjoy3Controller = TextEditingController(text: text);
                },
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enjoyment Rating 1-10',
                    prefixIcon: Icon(Icons.mood)
                ),
                validator: (value) {
                  if(_Activity3Controller.text != "") {
                    if (value == null || value.isEmpty ||
                        int.parse(value) > 10) {
                      return 'Max rate is 10';
                    }
                    return null;
                  }
                },
              ),

              SizedBox(height: 20.0),

              TextFormField(
                key: Key('comment'),
                controller: _CommentController,
                onChanged: (text) {
                  _CommentController = TextEditingController(text: text);
                },
                autofocus: true,
                //autocorrect: true,
                keyboardType: TextInputType.text,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your comment',
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(height: 55.0),
                  child: ElevatedButton(
                    key: Key('confirm'),
                    //style: style,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        editvalue(widget.item[2], widget.item[0], widget.item[1], _locationnameController.text, _transmodeController.text, _Activity1Controller.text, _enjoy1Controller.text, _Activity2Controller.text, _enjoy2Controller.text, _Activity3Controller.text, _enjoy3Controller.text, _CommentController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Setting(thislocation: thislocation)),
                        );
                      }
                    },
                    child: const Text('Edit Marker'),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}