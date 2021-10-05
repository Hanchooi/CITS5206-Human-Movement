import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import './Setting.dart';
import './main.dart';

class MarkerForm extends StatefulWidget {

  const MarkerForm({Key? key, required this.latlang}) : super(key: key);
  final LatLng latlang;

  @override
  _MarkerFormState createState() => _MarkerFormState();
}

class _MarkerFormState extends State<MarkerForm> {
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

  void add_head(List<List<dynamic>> rows){
    List<dynamic> row = [];
    row.add("longitude");
    row.add("latitude");
    row.add("locationName");
    row.add("transport");
    row.add("Activity 1");
    row.add("Enjoyment1");
    row.add("Activity 2");
    row.add("Enjoyment2");
    row.add("Activity 3");
    row.add("Enjoyment3");
    row.add("Comment");
    rows.add(row);
  }

  void add_context(List<List<dynamic>> rows, LatLng latlang, String locationName, String trans_mode, String Activ1, String enjoy1, String Activ2, String enjoy2, String Activ3, String enjoy3, String comment) async{
    List<dynamic> row = [];
    List<dynamic> empty = [];
    rows.add(empty);

    row.add(latlang.longitude);
    row.add(latlang.latitude);
    row.add(locationName);
    row.add(trans_mode);
    row.add(Activ1);
    row.add(enjoy1);
    row.add(Activ2);
    row.add(enjoy2);
    row.add(Activ3);
    row.add(enjoy3);
    row.add(comment);
    rows.add(row);
  }

  Future<void> _recordvalue(LatLng latlang, String locationName, String trans_mode, String Activ1, String enjoy1, String Activ2, String enjoy2, String Activ3, String enjoy3, String comment) async{
    List<List<dynamic>> rows = [];

    String csv = "";
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path+"/locations.csv";
    print("path:" + path);

    File file = File(path);
    if(await file.exists()){
      add_context(rows, latlang, locationName, trans_mode, Activ1, enjoy1, Activ2, enjoy2, Activ3, enjoy3, comment);
      csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv, mode: FileMode.append);
    }else{
      add_head(rows);
      add_context(rows, latlang, locationName, trans_mode, Activ1, enjoy1, Activ2, enjoy2, Activ3, enjoy3, comment);
      csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);
    }

    final input = new File(path).openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
    print(fields);

    print("finish writing");
    //await file.delete();
  }

  @override
  Widget build(BuildContext context) {
    LatLng latlang = new LatLng(widget.latlang.latitude.toDouble(), widget.latlang.longitude.toDouble());
    print(latlang.longitude);
    print(latlang.latitude);
    location thislocation = new location(latlang.longitude, latlang.latitude);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Marker'),
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
                autofocus: true,
                autocorrect: true,
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
                autofocus: true,
                autocorrect: true,
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
                autofocus: true,
                autocorrect: true,
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
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enjoyment Rating',
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
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Activity Name 2 (2=usual)',
                  prefixIcon: Icon(Icons.local_activity_outlined),
                ),
              ),

              TextFormField(
                controller: _enjoy2Controller,
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enjoyment Rating',
                    prefixIcon: Icon(Icons.mood)
                ),
                /*validator: (value) {
                  if (value == null || value.isEmpty || int.parse(value)>10) {
                    return 'Max rate is 10';
                  }
                  return null;
                },*/
              ),

              SizedBox(height: 20.0),

              TextFormField(
                controller: _Activity3Controller,
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Activity Name 3 (3=Least usual)',
                  prefixIcon: Icon(Icons.local_activity_outlined),
                ),
              ),

              TextFormField(
                controller: _enjoy3Controller,
                autofocus: true,
                autocorrect: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enjoyment Rating',
                    prefixIcon: Icon(Icons.mood)
                ),
                /*validator: (value) {
                  if (value == null || value.isEmpty || int.parse(value)>10) {
                    return 'Max rate is 10';
                  }
                  return null;
                },*/
              ),

              SizedBox(height: 20.0),

              TextFormField(
                key: Key('comment'),
                controller: _CommentController,
                autofocus: true,
                autocorrect: true,
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
                    key: Key("submit"),
                    //style: style,
                    onPressed: () async{
                      if (_formKey.currentState!.validate()) {
                        await _recordvalue(latlang, _locationnameController.text, _transmodeController.text, _Activity1Controller.text, _enjoy1Controller.text, _Activity2Controller.text, _enjoy2Controller.text, _Activity3Controller.text, _enjoy3Controller.text, _CommentController.text);
                        Navigator.push(
                          this.context,
                          MaterialPageRoute(builder: (context) => Setting(thislocation: thislocation)),
                        );
                      }
                    },
                    child: const Text('Add Marker'),
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