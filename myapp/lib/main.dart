import 'package:flutter/material.dart';
import 'dart:async';
import 'package:carp_background_location/carp_background_location.dart';
import 'package:intl/intl.dart';
import './Login.dart';
import './Registration.dart';
import './Setting.dart';
import './UserData.dart';
import './UserInfo.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

const fetchBackground = "fetchBackground";


void main() {
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
    'Location ${dto.latitude}, ${dto.longitude} at ${DateTime.fromMillisecondsSinceEpoch(dto.time.toInt())}';

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

  final account_Info default_info = new account_Info("","","");
  String logStr = '';
  LocationDto lastLocation = LocationDto.fromJson({ "key1":"value1"});
  DateTime? lastTimeLocation;
  Stream<LocationDto>? locationStream;
  StreamSubscription<LocationDto>? locationSubscription;
  LocationStatus _status = LocationStatus.UNKNOWN;
  List<DataPoint> UserData = [];

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
  }
  void add_head(List<List<dynamic>> rows){
    List<dynamic> row = [];
    row.add("date");
    row.add("latitude");
    row.add("longitude");
    row.add("speed");
    rows.add(row);
  }
  void add_context(List<List<dynamic>> rows){
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
  }
  void _generateCsvFile() async{
    List<List<dynamic>> rows = [];

    String csv = "";
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path+"/user.csv";
    print("path:" + path);

    File file = File(path);
    if(await file.exists()){
      add_context(rows);
      csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv, mode: FileMode.append);
      UserData.clear();
    }else{
      add_head(rows);
      add_context(rows);
      csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);
    }

    final input = new File(path).openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
    print(fields);
    //await file.delete();

  }

  void setDatapoint(LocationDto dto){
    String time = DateTime.fromMillisecondsSinceEpoch(dto.time.toInt()).toString();
    DataPoint segment = new DataPoint(time, dto.longitude, dto.latitude, dto.speed);
    UserData.add(segment);
  }

  void onGetCurrentData(){
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
      print(dto.latitude);
      print(dto.longitude);
      lastTimeLocation = DateTime.now();
      setDatapoint(dto);
    });
  }

  void start() async {
    // Subscribe if it hasn't been done already
    if (locationSubscription != null) {
      locationSubscription?.cancel();
    }
    locationSubscription = locationStream?.listen(onData);
    await LocationManager().start();
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
    final directory =  await getApplicationDocumentsDirectory();
    final path = directory.path +"/user.csv";

    File file = File(path);
    final fileName = basename(file.path);
    final destination = 'files/$fileName';
    print(path);
    Reference storageReference = FirebaseStorage.instance.ref().child("$destination");
    final UploadTask uploadTask = storageReference.putFile(file);
  }

  Widget stopButton() {
    String msg = 'STOP';

    return SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text(msg),
        onPressed: stop,
      ),
    );
  }

  Widget startButton() {
    String msg = 'START';
    return SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text(msg),
        onPressed: start,
      ),
    );
  }

  Widget status() {
    String msg = _status.toString().split('.').last;
    return Text("Status: $msg");
  }

  Widget lastLoc() {
    return Text(
        lastLocation != null
            ? dtoToString(lastLocation)
            : 'Unknown last location',
        textAlign: TextAlign.center);
  }

  Widget getButton() {
    return ElevatedButton(
      child: Text("Get Current Data collection"),
      onPressed: onGetCurrentData,
    );
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
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              startButton(),
              stopButton(),
              Divider(),
              status(),
              Divider(),
              dtoWidget(lastLocation),
              getButton()
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
              accountName: Text("Wu"),
              accountEmail: Text("Wu@gmail.com"),
              currentAccountPicture: new CircleAvatar(
                backgroundColor: Colors.blue,
                child: new Image.asset('assets/images/Wu.jpg'), //For Image Asset
              ),
            ),
            ListTile(
              title: const Text('Login'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login(info: default_info)),
                );
              },
            ),
            ListTile(
              title: const Text('User Info'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfo()),
                );
              },
            ),
            ListTile(
              title: const Text('Setting'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Setting(curposition: lastLocation)),
                );
              },
            ),

            ListTile(
              title: const Text('Upload file'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                _generateCsvFile();
                uploadFile();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),

            ListTile(
              title: const Text('Dialog'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Dialog()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
