import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photon/services/photon_sender.dart';

import '../../methods/methods.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  PhotonSender photonSePhotonSender = PhotonSender();
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isloading) ...{
          Card(
            color: const Color.fromARGB(255, 18, 23, 26),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: InkWell(
              onTap: () async {
                setState(() {
                  isloading = true;
                });
                await handleSharing(context);
                setState(() {
                  isloading = false;
                });
              },
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/lottie/rocket-send.json',
                    width: size.width / 1.6,
                    height: size.height / 6,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Share',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Card(
            color: const Color.fromARGB(255, 18, 23, 26),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: InkWell(
              onTap: () async {
                var status = await Permission.storage.status;
                if (status.isGranted) {
                  Navigator.of(context).pushNamed('/receivepage');

                  print('1');
                } else if (status.isDenied) {
                  var resp = await Permission.storage.request();
                  if (resp.isGranted) {
                    Navigator.of(context).pushNamed('/receivepage');
                  } else {
                    print('2');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Permission denied'),
                      ),
                    );
                  }
                } else {
                  print('3');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Permission denied forever'),
                    ),
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Lottie.asset(
                    'assets/lottie/receive-file.json',
                    width: size.width / 1.6,
                    height: size.height / 6,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Receive',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        } else ...{
          Center(
            child: SizedBox(
              width: size.width / 4,
              height: size.height / 4,
              child: Lottie.asset(
                'assets/lottie/setting_up.json',
                width: 100,
                height: 100,
              ),
            ),
          ),
          const Center(
            child: Text(
              'Please wait !',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          )
        },
      ],
    );
  }
}
