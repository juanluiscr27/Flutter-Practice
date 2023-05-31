import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_practice/scr/neworking/device_screen.dart';

class BluetoothHome extends StatefulWidget {
  const BluetoothHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _BTHomePageState createState() => _BTHomePageState();
}

class _BTHomePageState extends State<BluetoothHome> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  bool _isScanning = false;

  @override
  initState() {
    super.initState();
    // reset bluetooth
    initBle();
  }

  void initBle() {
    // Listen to get BLE scan status
    flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      setState(() {});
    });
  }

  /// Start/Stop Scan function
  scan() async {
    if (!_isScanning) {
      // If not scanning
      // Delete the previously scanned list
      scanResultList.clear();

      // Start scanning, with a 4 seconds timeout
      flutterBlue.startScan(timeout: const Duration(seconds: 4));

      // Scan results listener
      flutterBlue.scanResults.listen((results) {
        scanResultList = results;
        // UI update
        setState(() {});
      });
    } else {
      // If scanning, stop scanning
      flutterBlue.stopScan();
    }
  }

  /// Device-specific output functions
  // Device signal value widget
  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* Device's MAC Address Widget  */
  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.id.id);
  }

  /* device's name widget  */
  Widget deviceName(ScanResult sr) {
    String name = '';

    if (sr.device.name.isNotEmpty) {
      // device.name, if there is a value in
      name = sr.device.name;
    } else if (sr.advertisementData.localName.isNotEmpty) {
      // advertisementData.localName, if there is a value in
      name = sr.advertisementData.localName;
    } else {
      // if neither, name unknown
      name = 'N/A';
    }
    return Text(name);
  }

  // BLE Icon Widget
  Widget leading(ScanResult r) {
    return const CircleAvatar(
      backgroundColor: Colors.cyan,
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
    );
  }

  // Function called when a device item is tapped
  void onTap(ScanResult sr) {
    // to print device the name
    print(sr.device.name);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeviceScreen(device: sr.device)),
    );
  }

  // Device item widget
  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => onTap(r),
      leading: leading(r),
      title: deviceName(r),
      subtitle: deviceMacAddress(r),
      trailing: deviceSignal(r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Show device list
        child: ListView.separated(
          itemCount: scanResultList.length,
          itemBuilder: (context, index) {
            return listItem(scanResultList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        ),
      ),
      // Search for devices or stop searching
      floatingActionButton: FloatingActionButton(
        onPressed: scan,
        // If scanning is in progress, a stop icon is displayed,
        // When is not scanning, a search icon is displayed.
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
