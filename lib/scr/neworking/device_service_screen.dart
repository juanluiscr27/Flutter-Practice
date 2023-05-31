import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceServiceScreen extends StatefulWidget {
  const DeviceServiceScreen({Key? key, required this.device}) : super(key: key);
  // Receive device information
  final BluetoothDevice device;

  @override
  _DeviceServiceScreenState createState() => _DeviceServiceScreenState();
}

class _DeviceServiceScreenState extends State<DeviceServiceScreen> {
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

  // List of bluetooth device services
  List<BluetoothService> bluetoothService = [];

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

  /// Start connection
  Future<bool> connect() async {
    Future<bool>? returnValue;
    setState(() {
      /* Change the status display to Connecting */
      stateText = 'Connecting';
    });

    // Set timeout to 10 seconds (10000ms) and turn off auto connect
    // For reference, if auto connect is set to true, the connection may be delayed.

    await widget.device
        .connect(autoConnect: false)
        .timeout(const Duration(milliseconds: 10000), onTimeout: () {
      //timeout occurs
      // set returnValue to false
      returnValue = Future.value(false);
      debugPrint('timeout failed');

      //change the connection status to disconnected
      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) async {
      bluetoothService.clear();
      if (returnValue == null) {
        // If returnValue is null, connection succeeded because timeout did not occur
        debugPrint('connection successful');
        print('start discover service');
        List<BluetoothService> bleServices =
            await widget.device.discoverServices();
        setState(() {
          bluetoothService = bleServices;
        });
        // output each property to debug
        for (BluetoothService service in bleServices) {
          print('============================================');
          print('Service UUID: ${service.uuid}');
          for (BluetoothCharacteristic c in service.characteristics) {
            print('\tcharacteristic UUID: ${c.uuid.toString()}');
            print('\t\twrite: ${c.properties.write}');
            print('\t\tread: ${c.properties.read}');
            print('\t\tnotify: ${c.properties.notify}');
            print('\t\tisNotifying: ${c.isNotifying}');
            print(
                '\t\twriteWithoutResponse: ${c.properties.writeWithoutResponse}');
            print('\t\tindicate: ${c.properties.indicate}');
          }
        }
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /* connection status */
              Text('$stateText'),
              /* Connect and disconnect buttons */
              OutlinedButton(
                  onPressed: () {
                    if (deviceState == BluetoothDeviceState.connected) {
                      /* Disconnect if connected */
                      disconnect();
                    } else if (deviceState ==
                        BluetoothDeviceState.disconnected) {
                      /* Connect if disconnected */
                      connect();
                    }
                  },
                  child: Text(connectButtonText)),
            ],
          ),

          /* Output service information of connected BLE */
          Expanded(
            child: ListView.separated(
              itemCount: bluetoothService.length,
              itemBuilder: (context, index) {
                return listItem(bluetoothService[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            ),
          ),
        ],
      )),
    );
  }

  /* Each characteristic information display widget */
  Widget characteristicInfo(BluetoothService r) {
    String name = '';
    String properties = '';
    // Take out the characteristics one by one and display them
    for (BluetoothCharacteristic c in r.characteristics) {
      properties = '';
      name += '\t\t${c.uuid}\n';
      if (c.properties.write) {
        properties += 'Write ';
      }
      if (c.properties.read) {
        properties += 'Read ';
      }
      if (c.properties.notify) {
        properties += 'Notify ';
      }
      if (c.properties.writeWithoutResponse) {
        properties += 'WriteWR';
      }
      if (c.properties.indicate) {
        properties += 'Indicate ';
      }
      name += '\t\t\tProperties: $properties\n';
    }
    return Text(name);
  }

  /* Service UUID widget */
  Widget serviceUUID(BluetoothService r) {
    String name = '';
    name = r.uuid.toString();
    return Text(name);
  }

  /* Service information item widget */
  Widget listItem(BluetoothService r) {
    return ListTile(
      onTap: null,
      title: serviceUUID(r),
      subtitle: characteristicInfo(r),
    );
  }
}
