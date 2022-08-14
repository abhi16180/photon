import 'package:unicons/unicons.dart';

import '../models/sender_model.dart';
import 'package:flutter/material.dart';

infoList(SenderModel senderModel, double width, double height, bool sender) {
  var iconList = [
    Icon(
      UniconsLine.location_point,
      color: Colors.blue.shade600,
    ),
    const Icon(
      UniconsLine.process,
    ),
    if (senderModel.os == "android") ...{
      Icon(
        Icons.android,
        color: Colors.greenAccent.shade400,
      )
    } else if (senderModel.os == "ios") ...{
      Icon(
        Icons.apple,
        color: Colors.blueGrey.shade300,
      )
    } else if (senderModel.os == "windows") ...{
      Icon(
        Icons.laptop_windows,
        color: Colors.blue.shade400,
      )
    } else if (senderModel.os == "macos") ...{
      Icon(
        Icons.laptop_mac,
        color: Colors.blueGrey.shade300,
      )
    } else if (senderModel.os == "linux") ...{
      Icon(
        UniconsLine.linux,
        color: Colors.blueGrey.shade300,
      )
    },
    const Icon(
      UniconsLine.info_circle,
    )
  ];
  var serverDataList = [
    {'type': 'IP'.padRight(12), 'value': senderModel.ip},
    {'type': 'Port'.padRight(10), 'value': senderModel.port},
    {'type': 'Os'.padRight(11), 'value': senderModel.os},
    {'type': 'Version', 'value': senderModel.version}
  ];
  List<Widget> data = [];
  for (int i = 0; i < iconList.length; i++) {
    data.add(Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconList[i],
          const SizedBox(
            width: 20,
          ),
          RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: width > 720
                  ? serverDataList[i]['type']
                  : serverDataList[i]['type'] + ' : ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255).withAlpha(200),
                  overflow: TextOverflow.ellipsis),
              children: [
                TextSpan(
                    text: serverDataList[i]['value'].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          )
        ],
      ),
    ));
  }
  if (sender) {
    data.insert(
      0,
      Text(
        'Receiver can discover you as,',
        style: TextStyle(fontSize: width > 720 ? 20 : 16),
        textAlign: TextAlign.center,
      ),
    );
  }
  return data;
}
