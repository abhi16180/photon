import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/cupertino.dart';

class DeviceService {
  static BonsoirService? bonsoirService;
  static BonsoirBroadcast? broadcast;
  static BonsoirDiscovery? discovery;
  static String serviceType = "_http._tcp";
  static DeviceService? deviceService;
  List<BonsoirService?> discoveredServices = [];

  static getDeviceService() {
    deviceService ??= DeviceService();
    return deviceService;
  }

  void advertise(String ip) async {
    try {
      bonsoirService = BonsoirService(
          name: 'photon',
          type: '_http._tcp',
          port: 4040,
          attributes: {
            "ip": ip,
          });
      broadcast = BonsoirBroadcast(service: bonsoirService!);
      await broadcast!.ready;
      await broadcast!.start();
    } catch (e) {
      debugPrint("unable to advertise ${e.toString()}");
    }
  }

  Future<void> stopAdvertising() async {
    if (broadcast != null) {
      return await broadcast!.stop();
    }
  }

  Future<List<BonsoirService?>> discover() async {
    Completer<List<BonsoirService?>> completer = Completer();
    discovery = BonsoirDiscovery(type: serviceType);
    await discovery!.ready;
    discovery!.eventStream!.listen((event) {
      if (event.service != null) {
          discoveredServices.add(event.service);
      }
    });
    discovery!.start();
    Future.delayed(const Duration(seconds: 2), () {
      discovery!.stop();
      if (!completer.isCompleted) {
        completer.complete(
            discoveredServices);
      }
    });
    return completer.future;
  }

  void stopDiscovery() async {
    await discovery!.stop();
  }
}
