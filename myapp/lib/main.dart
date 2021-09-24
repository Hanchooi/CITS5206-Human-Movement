import 'package:flutter/material.dart';
import 'dart:async';
import 'package:carp_background_location/carp_background_location.dart';
import 'package:intl/intl.dart';
import './Login.dart';
import './Registration.dart';
import './Setting.dart';
import './UserData.dart';
import './UserInfo.dart';
import './Userguide.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cron/cron.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './UserProfile.dart';

const fetchBackground = "fetchBackground";

class location {
  double longitude;
  double latitude;

  location(this.longitude, this.latitude);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum LocationStatus { UNKNOWN, RUNNING, STOPPED }

String dtoToString(LocationDto dto) =>
    //'Location ${dto.latitude}, ${dto.longitude} at ${DateTime.fromMillisecondsSinceEpoch(dto.time.toInt())}';
    'Location ${dto.latitude}, ${dto.longitude} at ${dto.time}';

Widget dtoWidget(LocationDto? dto) {
  if (dto == null)
    return Text("No location yet");
  else
    return Column(
      children: <Widget>[
        Text(
          '${dto.latitude}, ${dto.longitude}, ${dto.speed}',
        ),
        Text(
          '@',
        ),
        //Text('${DateTime.fromMillisecondsSinceEpoch(dto.time.toInt())}')
      ],
    );
}

class _MyHomePageState extends State<MyHomePage> {
  final account_Info default_info = new account_Info("", "", "");
  String logStr = '';
  LocationDto?
      lastLocation; //= LocationDto.fromJson({ "key": "12", "key2": "13"});
  location thislocation = location(115.857048, -31.953512);
  DateTime? lastTimeLocation;
  Stream<LocationDto>? locationStream;
  StreamSubscription<LocationDto>? locationSubscription;
  LocationStatus _status = LocationStatus.UNKNOWN;
  List<DataPoint> UserData = [];
  String _garminId = "";
  int _num = 0;
  bool flag = false;
  bool firstState = false;
  bool secondState = false;

  @override
  void initState() {
    super.initState();
    // Subscribe to stream in case it is already running
    LocationManager().interval = 60;
    LocationManager().distanceFilter = 0;
    LocationManager().notificationTitle = 'CARP Location Example';
    LocationManager().notificationMsg = 'CARP is tracking your location';
    locationStream = LocationManager().locationStream;
    locationSubscription = locationStream?.listen(onData);
    _getGarminId();
    _getFileNum();
    userGuide();
  }

// @Cathyling
// get GarminId from shared_preference
  void _getGarminId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _garminId = (prefs.getString('GarminId') ?? "");
    });
  }

// get file number from shared_preference
  void _getFileNum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _num = (prefs.getInt('file number') ?? 0);
    });
  }

// incrementing file number and save it in shared_preference
  void _setFileNum(int n) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('file number', n + 1);
    setState(() {
      _num = n + 1;
    });
  }

  Future<bool> setUserState() async {
    //String userProfile = "${_garminId}userProfile.json";
    final directory = await getApplicationDocumentsDirectory();
    final userInfoPath = "${directory.path}/${_garminId}userProfile.json";
    File userfile = File(userInfoPath);
    if (await userfile.exists()) {
      setState(() {
        firstState = true;

        print("first" + firstState.toString());
      });
    } else {
      setState(() {
        firstState = false;
        print("first" + firstState.toString());
      });
    }
    return firstState;
  }

  Future<bool> setLocationState() async {
    String location = "locations.csv";

    final directory = await getApplicationDocumentsDirectory();
    final locationPath = "${directory.path}/${location}";
    File locations = File(locationPath);
    if (await locations.exists()) {
      setState(() {
        secondState = true;
        print("second" + secondState.toString());
      });
    } else {
      setState(() {
        secondState = false;
        print("second" + secondState.toString());
      });
    }
    return secondState;
  }

  Future<bool> userGuide() async {
    await setUserState();
    await setLocationState();
    if (firstState && secondState) {
      setState(() {
        flag = true;
        print(flag.toString());
      });
    } else {
      setState(() {
        flag = false;
        print(flag.toString());
      });
    }

    return flag;
  }

  Widget firstLink() {
    return InkWell(
      child: new Text(
        'Open user profile',
        style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      onTap: () {
        // Update the state of the app
        // Then close the drawer
        Navigator.push(
          this.context,
          MaterialPageRoute(builder: (context) => UserInfo()),
        ).then((value) {
          _getGarminId();
        });
      },
    );
  }

  Widget secondLink() {
    return InkWell(
      child: new Text(
        'Open Map Setting',
        style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      onTap: () {
        Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => Setting(thislocation: thislocation)),
        );
      },
    );
  }

  // csv file header
  void add_head(List<List<dynamic>> rows) {
    List<dynamic> row = [];
    row.add("unixTime");
    row.add("latitude");
    row.add("longitude");
    row.add("speed");
    rows.add(row);
  }

  // adding new rows to csv file
  void add_context(List<List<dynamic>> rows) {
    List<dynamic> row = [];
    rows.add(row);

    for (int i = 0; i < UserData.length; i++) {
      List<dynamic> row = [];
      row.add(UserData[i].date);
      row.add(UserData[i].latitude);
      row.add(UserData[i].longitude);
      row.add(UserData[i].speed);
      rows.add(row);
    }

    UserData = [];
  }

  void generateCsvFile() async {
    // generate file name
    String file_name = "${_garminId}${_num}.csv";
    List<List<dynamic>> rows = [];

    String csv = "";
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${file_name}";
    print("path:" + path);

    File file = File(path);
    if (await file.exists()) {
      add_context(rows);
      csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv, mode: FileMode.append);
      UserData.clear();
    } else {
      // create csv file
      await file.create();
      add_head(rows);
      add_context(rows);
      csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);
      UserData.clear();
    }

    final input = new File(path).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(new CsvToListConverter())
        .toList();
    print(fields);
    //await file.delete();
  }

  void setDatapoint(LocationDto dto) {
    //String time = DateTime.fromMillisecondsSinceEpoch(dto.time.toInt()).toString();
    double time = dto.time;
    DataPoint segment =
        new DataPoint(time, dto.longitude, dto.latitude, dto.speed);
    UserData.add(segment);
  }

  void onGetCurrentData() {
    //LocationDto dto = await LocationManager().getCurrentLocation();
    UserData.forEach((element) => print(element.toString()));
    UserData.clear();
  }

  void onData(LocationDto dto) {
    print(dtoToString(dto));
    setState(() {
      if (_status == LocationStatus.UNKNOWN) {
        _status = LocationStatus.RUNNING;
      }
      lastLocation = dto;
      //print(dto.latitude);
      //print(dto.longitude);
      lastTimeLocation = DateTime.now();
      setDatapoint(dto);
    });
    thislocation.longitude = dto.longitude;
    thislocation.latitude = dto.latitude;
  }

  void start() async {
    // Subscribe if it hasn't been done already
    if (locationSubscription != null) {
      locationSubscription?.cancel();
    }
    locationSubscription = locationStream?.listen(onData);
    await LocationManager().start();
    startAutoUpdate();
    setState(() {
      _status = LocationStatus.RUNNING;
    });
  }

  void stop() async {
    setState(() {
      _status = LocationStatus.STOPPED;
    });
    locationSubscription?.cancel();
    await LocationManager().stop();
  }

  // @Cathyling
  // user upload the csv file
  void uploadFile() async {
    final directory = await getApplicationDocumentsDirectory();
    String file_name = "${_garminId}${_num}.csv";
    final path = "${directory.path}/${file_name}";
    File file = File(path);
    // file path on firebase storage
    final destination = '${_garminId}/$file_name';
    print(path);
    print(destination);
    Reference storageReference =
        FirebaseStorage.instance.ref().child("$destination");
    //final UploadTask uploadTask = storageReference.putFile(file);
    // upload file to firebase storage
    storageReference.putFile(file);
    // delete file in the memory
    file.delete();
    // incrementing file number
    _setFileNum(_num);
  }

  // @Cathyling
  // send file to fire base every day at 10am
  void startAutoUpdate() {
    final cron = new Cron();
    cron.schedule(new Schedule.parse('0 10 * * *'), () async {
      generateCsvFile();
      uploadFile();
    });
  }
  // write UserData into csv every hour at minute 0
  void writeCSV() {
    final cron = new Cron();
    cron.schedule(new Schedule.parse('0 * * * *'), () async {
      generateCsvFile();
    });
  }

  Widget stopButton() {
    String msg = 'STOP';

    return SizedBox(
      width: 100,
      height: 100,
      child: ElevatedButton(
        child: Icon(Icons.stop_circle_outlined, color: Colors.white, size: 60),
        onPressed: stop,
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          primary: Colors.red, // <-- Button color
          onPrimary: Colors.red, // <-- Splash color
        ),
      ),
    );
  }

  Widget startButton() {
    String msg = 'START';
    return SizedBox(
      width: 100,
      height: 100,
      child: ElevatedButton(
        child: Icon(Icons.not_started_outlined, color: Colors.black, size: 60),
        onPressed: () {
          start(); 
          startAutoUpdate();
          writeCSV();
        },
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          primary: Colors.green, // <-- Button color
          onPrimary: Colors.green, // <-- Splash color
        ),
      ),
    );
  }

  Widget status() {
    String msg = _status.toString().split('.').last;
    return Text(
      "Status: $msg",
      style: TextStyle(
          fontSize: 25,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold),
    );
  }

  /**Widget lastLoc() {
    return Text(
        lastLocation != null
            ? dtoToString(lastLocation)
            : 'Unknown last location',
        textAlign: TextAlign.center,
    );
  }*/

  Widget getButton() {
    return ElevatedButton(
      child: Text("Get Current Data collection"),
      onPressed: onGetCurrentData,
    );
  }

  Widget deleteButton() {
    return ElevatedButton(
      child: Text("Delete Data collection"),
      onPressed: () {
        _deleteFile();
        Navigator.push(
          this.context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: "Home")),
        );
      },
    );
  }

  void _deleteFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final userpath = directory.path + "/user.csv";
    final locationpath = directory.path + "/locations.csv";
    final profile = directory.path + "/${_garminId}userProfile.json";

    File userfile = File(userpath);
    File locationfile = File(locationpath);
    File profilefile = File(profile);

    print(userfile);
    if (await userfile.exists()) {
      await userfile.delete();
      print("user delete done");
    }
    if (await locationfile.exists()) {
      await locationfile.delete();
      print("location delete done");
    }
    if (await profilefile.exists()) {
      await profilefile.delete();
      print("location delete done");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MAIN PAGE"),
        /**leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.home, color: Colors.white), //dynamic icon
            onPressed: () {
              //
              Scaffold.of(context).openDrawer();
            },
          );
        }),*/
      ),
      // important resources https://book.flutterchina.club/chapter5/material_scaffold.html#_5-6-1-scaffold

      body: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (flag) ...[
                SizedBox(height: 30.0),
                startButton(),
                SizedBox(height: 30.0),
                stopButton(),
                SizedBox(height: 30.0),
                status(),
                SizedBox(height: 30.0),
                dtoWidget(lastLocation),
                //getButton(),
                deleteButton()
              ],
              if (flag == false) ...[
                if (!firstState) ...[
                  SizedBox(height: 30.0),
                  firstStep(),
                  firstLink(),
                ],
                if (!secondState) ...[
                  SizedBox(height: 30.0),
                  secondStep(),
                  secondLink(),
                ],
              ],
            ],
          ),
        ),
      ),

      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_garminId),
              accountEmail: Text(""),
              currentAccountPicture: new CircleAvatar(
                backgroundColor: Colors.blue,
                child:
                    new Image.asset('assets/images/Wu.jpg'), //For Image Asset
              ),
            ),
            /**ListTile(
              title: const Text('Login'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login(info: default_info)),
                );
              },
            ),*/
            /*
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfo()),
                ).then((value) {
                  _getGarminId();
                });
              },
            ),*/
            ListTile(
              title: const Text('UserProfile'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );
              },
            ),
            ListTile(
              title: const Text('Visited Places'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Setting(thislocation: thislocation)),
                );
              },
            ),
            ListTile(
              title: const Text('Upload Data'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                generateCsvFile();
                uploadFile();

                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
            //ListTile(
            //title: const Text('Dialog'),
            //onTap: () {
            // Update the state of the app
            // Then close the drawer
            //Navigator.push(
            //context,
            //MaterialPageRoute(builder: (context) => Dialog()),
            //);
            //},
            //),
            //ListTile(
            //title: const Text('display file'),
            //onTap: () {
            // Update the state of the app
            // Then close the drawer
            //generateCsvFile();
            //},
            //),
            ListTile(
              title: const Text('Start Auto Upload'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                startAutoUpdate();
                writeCSV();
              },
            ),
          ],
        ),
      ),
    );
  }
}
