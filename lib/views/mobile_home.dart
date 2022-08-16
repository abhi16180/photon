import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
            color: Colors.lightGreenAccent.shade400.withAlpha(225),
            minWidth: size.width / 2,
            height: size.height / 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () async {
              setState(() {
                isloading = true;
              });
              await handleSharing(context);

              setState(() {
                isloading = false;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Transform.rotate(
                  angle: 0,
                  child: SvgPicture.asset(
                    'assets/icons/rocket-blue.svg',
                    color: Colors.white,
                    width: 60,
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: const SizedBox(
                    width: 120,
                    height: 30,
                    child: Center(
                        child: Text('Send',
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          MaterialButton(
            color: Colors.blue,
            minWidth: size.width / 2,
            height: size.height / 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () async {
              Navigator.of(context).pushNamed('/receivepage');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Transform.rotate(
                  angle: 0,
                  child: SvgPicture.asset(
                    'assets/icons/save.svg',
                    color: Colors.white,
                    width: 60,
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: const SizedBox(
                    width: 120,
                    height: 30,
                    child: Center(
                        child: Text(
                      'Receive',
                      style: TextStyle(color: Colors.black),
                    )),
                  ),
                )
              ],
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
