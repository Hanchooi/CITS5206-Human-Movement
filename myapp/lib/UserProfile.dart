import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './main.dart';
import './UserInfo.dart';



class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  String username='';
  String garminId='';
  String numOfVehicle='';

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
      username = (prefs.getString("UserName")?? "");
      garminId = (prefs.getString("GarminId")?? "");
      numOfVehicle = (prefs.getString("NumOfVehicle")?? "");
    });
    
    print(username);
  }
  @override
  void initState() {
    super.initState();
    _getUser();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              "GarminID: ${garminId}",
              style: TextStyle(color: Colors.grey, fontSize: 20),  
            ),
            const SizedBox(height: 8),
            Text(
              "Number of Vehicles: ${numOfVehicle}",
              style: TextStyle(color: Colors.grey, fontSize: 20),  
            ),
            ElevatedButton(
                child: Text('Edit'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserInfo()),
                  );     
                },
            ),
          ],

        ),
      )
    );
  }

}