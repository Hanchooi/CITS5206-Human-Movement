import 'dart:convert';
import './main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //Import intl in the file this is being done
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _garminIdController = new TextEditingController();
  TextEditingController _stravaIdController = new TextEditingController();
  TextEditingController _genderController = new TextEditingController();
  String dd_gender="";
  String num_vechical = '';
  String type_vehicle = '';


  void _formSubmitted() {
    // get the current state of the form
    var _form = _formKey.currentState;
    if (_form!.validate()) {
      _form.save();
    }
  }
  // generate userProfile csv file
  void _generateUserProfile(String username, String garminId, String stravaId, String gender, String numOfVehicle, String vehicleType) async {
    Map<String, dynamic> _userInfo = {
      'UserName': username,
      'GarminId': garminId,
      'StravaId': stravaId ,
      'Gender': gender,
      'NumberOfVehicle': numOfVehicle,
      'VehicleType': vehicleType
    };   
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File file = File('$path/${garminId}userProfile.json');
    // write user info into a json file
    file.writeAsString(jsonEncode(_userInfo));
    // set file path on firebase storage
    final destination = '$garminId/${garminId}userProfile.json';
    Reference storageReference =
        FirebaseStorage.instance.ref().child("$destination");
    // upload file to firebase
    final UploadTask uploadTask = storageReference.putFile(file);
  }

  // load user information form shared preference
  void _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
    _usernameController.text = (prefs.getString("UserName")?? "");
    _garminIdController.text = (prefs.getString("GarminId")?? "");
    _stravaIdController.text = (prefs.getString("StravaId")?? "");
    num_vechical = (prefs.getString("NumOfVehicle")?? "");
    dd_gender = (prefs.getString("Gender")?? "");
    type_vehicle = (prefs.getString("VehicleType")?? "");
    });
  }
  // store user information to shared_preference
  void _setUserInfo(String username, String garminId, String stravaId, String gender, String numOfVehicle, String vehicleType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("UserName", username);
    prefs.setString("GarminId", garminId);
    prefs.setString("StravaId", stravaId);
    prefs.setString("Gender", gender);
    prefs.setString("NumOfVehicle", numOfVehicle);
    prefs.setString("VehicleType", vehicleType);
    // String gId = (prefs.getString('GarminId') ?? "");
    // print("get ${gId}");
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Please Enter Your Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
              SizedBox(height: 18.0),
              TextFormField(
                controller: _garminIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Garmin Account ID',
                  prefixIcon: Icon(Icons.manage_accounts),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
              SizedBox(height: 18.0),
              TextFormField(
                controller: _stravaIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Strava Account ID',
                  prefixIcon: Icon(Icons.manage_accounts),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
              /**
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(
                  hintText: 'Gender',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),*/
              SizedBox(height: 18.0),
              DropdownButtonFormField(
                hint: dd_gender == ""
                    ? Text('Gender')
                    : Text(
                  dd_gender,
                  style: TextStyle(color: Colors.blue),
                ),
                isExpanded: true,
                iconSize: 30.0,
                style: TextStyle(color: Colors.blue),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.transgender),
                ),
                items: ['Male', 'Female'].map(
                      (value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                          dd_gender = value.toString();
                    },
                  );
                },
              ),

            /*TextFormField(
              controller: _numOfVehicleController,
              decoration: const InputDecoration(
                hintText: 'Number of Vehicle Owned',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              }),*/
              SizedBox(height: 18.0),
              DropdownButtonFormField(
                hint: num_vechical == ""
                    ? Text('Number of Vehicle Owned')
                    : Text(
                  num_vechical,
                  style: TextStyle(color: Colors.blue),
                ),
                isExpanded: true,
                iconSize: 30.0,
                style: TextStyle(color: Colors.blue),
                decoration: const InputDecoration(
                  labelText: 'Number of Vehicle Owned',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.emoji_transportation),
                ),
                items: ['0', '1', '2', '3'].map(
                      (value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    num_vechical = value.toString();
                  },
                  );
                },
              ),
              SizedBox(height: 18.0),
              DropdownButtonFormField(
                hint: type_vehicle == ""
                    ? Text('Vehicle Type')
                    : Text(
                  type_vehicle,
                  style: TextStyle(color: Colors.blue),
                ),
                isExpanded: true,
                iconSize: 30.0,
                style: TextStyle(color: Colors.blue),
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.car_repair),
                ),
                items: ['None', 'SUV', 'Truck', 'Van', 'Coupe', 'Luxury Car', 'Hybrid/Electric'].map(
                      (value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    type_vehicle = value.toString();
                  },
                  );
                },
              ),
              /**TextFormField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(
                  hintText: 'Vehicle Type',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                    return null;
                }),*/
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  key: Key('Submit'),
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    _formSubmitted();
                    _setUserInfo(_usernameController.text, _garminIdController.text, _stravaIdController.text, dd_gender, num_vechical, type_vehicle);
                    _generateUserProfile(_usernameController.text, _garminIdController.text, _stravaIdController.text, dd_gender, num_vechical, type_vehicle);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyHomePage(title: "Home")),
                    );
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
