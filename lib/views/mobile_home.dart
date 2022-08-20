import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:photon/services/photon_sender.dart';

import '../methods/methods.dart';

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
          MaterialButton(
            onPressed: () async {
              setState(() {
                isloading = true;
              });
              await handleSharing(context);
              setState(() {
                isloading = false;
              });
            },
            child: Card(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/lottie/rocket-send.json',
                    width: size.width / 2,
                    height: size.height / 5,
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
            child: MaterialButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/receivepage');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Lottie.asset(
                    'assets/lottie/receive-file.json',
                    width: size.width / 2,
                    height: size.height / 5,
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
