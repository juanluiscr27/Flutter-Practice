import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);
  // Receive device information
  final BluetoothDevice device;

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  // flutterBlue
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  // connection status display string
  String stateText = 'Connecting';

  // connect button string
  String connectButtonText = 'Disconnect';

  // for storing the current connection state
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  // Connection status listener handle To release the listener when the screen is closed
  StreamSubscription<BluetoothDeviceState>? _stateListener;

  @override
  initState() {
    super.initState();
    // register state connection listener
    _stateListener = widget.device.state.listen((event) {
      debugPrint('event : $event');
      if (deviceState == event) {
        // Ignore if state is the same
        return;
      }
      // change connection state information
      setBleConnectionState(event);
    });
    // start connection
    connect();
  }

  @override
  void dispose() {
    // clear status listener
    _stateListener?.cancel();
    // disconnect
    disconnect();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      // Only update when the screen is mounted
      super.setState(fn);
    }
  }

  /* Update connection status */
  setBleConnectionState(BluetoothDeviceState event) {
    switch (event) {
      case BluetoothDeviceState.disconnected:
        stateText = 'Disconnected';
        // change button state
        connectButtonText = 'Connect';
        break;
      case BluetoothDeviceState.disconnecting:
        stateText = 'Disconnecting';
        break;
      case BluetoothDeviceState.connected:
        stateText = 'Connected';
        // change button state
        connectButtonText = 'Disconnect';
        break;
      case BluetoothDeviceState.connecting:
        stateText = 'Connecting';
        break;
    }
    //save previous state event
    deviceState = event;
    setState(() {});
  }

  /* start connection */
  Future<bool> connect() async {
    Future<bool>? returnValue;
    setState(() {
      /* Change the status display to Connecting */
      stateText = 'Connecting';
    });

    /*
      Set timeout to 10 seconds (10000ms) and turn off autoconnect
       For reference, if autoconnect is set to true, the connection may be delayed.
     */
    await widget.device
        .connect(autoConnect: false)
        .timeout(Duration(milliseconds: 10000), onTimeout: () {
      //timeout occurs
      // set returnValue to false
      returnValue = Future.value(false);
      debugPrint('timeout failed');

      //change the connection status to disconnected
      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) {
      if (returnValue == null) {
        // If returnValue is null, connection succeeded because timeout did not occur
        debugPrint('connection successful');
        returnValue = Future.value(true);
      }
    });

    return returnValue ?? Future.value(false);
  }

  /* Disconnect */
  void disconnect() {
    try {
      setState(() {
        stateText = 'Disconnecting';
      });
      widget.device.disconnect();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /* device name */
        title: Text(widget.device.name),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /* connection status */
          Text('$stateText'),
          /* Connect and disconnect buttons */
          OutlinedButton(
              onPressed: () {
                if (deviceState == BluetoothDeviceState.connected) {
                  /* Disconnect if connected */
                  disconnect();
                } else if (deviceState == BluetoothDeviceState.disconnected) {
                  /* Connect if disconnected */
                  connect();
                } else {}
              },
              child: Text(connectButtonText)),
        ],
      )),
    );
  }
}
