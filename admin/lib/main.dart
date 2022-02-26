import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:core';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: Colors.white,
      primary: Color.fromARGB(255, 106, 107, 177),
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: ElevatedButton.icon(
          style: raisedButtonStyle,
          icon: const Icon(Icons.add_location),
          onPressed: () async {
            if (await Permission.locationWhenInUse.request().isGranted) {
              // Either the permission was already granted before or the user just granted it.
            }

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses =
                await [Permission.locationWhenInUse].request();
            print(statuses[Permission.locationWhenInUse]);

            if (await Permission.locationWhenInUse.request().isGranted) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => (PinCodeVerificationScreen()))));
            }
            ;
          },
          label: const Text('Click here to grant Location permissions'),
        ),
      ),
    );
  }
}

class PinCodeVerificationScreen extends StatefulWidget {
  @override
  _PinCodeVerificationScreenState createState() =>
      _PinCodeVerificationScreenState();
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Material App',
        home: Scaffold(
            appBar: AppBar(
              title: Text('Material App Bar'),
            ),
            body: Center(
                child: Column(
              children: [
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.blue.shade50,
                  enableActiveFill: true,
                  controller: textEditingController,
                  onCompleted: (v) {
                    print("Completed");
                  },
                  onChanged: (value) {
                    print(value);
                    //setState(() {
                    //currentText = value;
                    //});
                  },
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.done),
                  tooltip: 'Confirm entered PIN',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BusSelectipnPage()));
                  },
                ),
              ],
            ))));
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class BusSelectipnPage extends StatefulWidget {
  const BusSelectipnPage({Key? key}) : super(key: key);

  @override
  _BusSelectipnPageState createState() => _BusSelectipnPageState();
}

class _BusSelectipnPageState extends State<BusSelectipnPage> {
  // Initial Selected Value
  String dropdownvalue = 'Red';

  // List of items in our dropdown menu
  var items = [
    'Red',
    'Red Express(Morning)',
    'Red Express(Lunch)',
    'Blue',
    'Blue Express(Morning)',
    'Blue Express(Lunch)',
    'Green(Campus Rider)',
    'Brown(Campus Weekend Rider)'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page: Bus Setting"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              // Initial Value
              value: dropdownvalue,

              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),

              // Array list of items
              items: items.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),
            FloatingActionButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
                onPressed: () async {
                  bool serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  if (serviceEnabled == false) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                                title: Text('GPS'),
                                content: Text(
                                    'Are you sure your GPS is on?\nPlease turn on your GPS'),
                                actions: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                ]));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TerminatePage()));
                  }
                },
                child: const Text('Select'))
          ],
        ),
      ),
    );
  }
}

class TerminatePage extends StatefulWidget {
  const TerminatePage({Key? key}) : super(key: key);

  @override
  _TerminatePage createState() => _TerminatePage();
}

class _TerminatePage extends State<TerminatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page: Enter Terminate Location"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: 50,
          width: 100,
          child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Saraca'),
                          content: Text(
                              'You have chose Saraca as your termination location'),
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        ));
                //HAVE TO ADD FUNCTION
              },
              child: const Text('SARACA')),
        ),
        Text(''),
        SizedBox(
          height: 50,
          width: 100,
          child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Hall 11'),
                          content: Text(
                              'You have chose Hall 11 as your termination location'),
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        ));
                //HAVE TO ADD FUNCTION
              },
              child: const Text('HALL 11')),
        ),
        Text(''),
        SizedBox(
          height: 50,
          width: 100,
          child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Hall 12/13'),
                          content: Text(
                              'You have chose Hall 12/13 as your termination location'),
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        ));
                //HAVE TO ADD FUNCTION
              },
              child: const Text('HALL 12/13')),
        ),
        Text(''),
        SizedBox(
          height: 50,
          width: 100,
          child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Hall 14/15'),
                          content: Text(
                              'You have chose Hall 14/15 as your termination location'),
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        ));
                //HAVE TO ADD FUNCTION
              },
              child: const Text('HALL 14/15')),
        ),
        Text(''),
        SizedBox(
          height: 50,
          width: 100,
          child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Hall 4/5'),
                          content: Text(
                              'You have chose Hall 4/5 as your termination location'),
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        ));
                //HAVE TO ADD FUNCTION
              },
              child: const Text('HALL 4/5')),
        ),
        Text(''),
        Text(''),
        Text(''),
        SizedBox(
          height: 100,
          width: 200,
          child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('TERMINATE'),
                          content:
                              Text('Are you sure you would like to terminate?'),
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  //HAVE TO ADD FUNCTION
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MyHomePage()),
                                  );
                                }),
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        ));
                //HAVE TO ADD FUNCTION
              },
              child: const Text('Terminate')),
        ),
      ])),
    );
  }
}

/*Future<http.Response> addNewBus(String bus_type, List<Float> geo_code){
  return http.post(
    Uri.parse('https:/????/send.driver.geocode()'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),
    );
}*/
