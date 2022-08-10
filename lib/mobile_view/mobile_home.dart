import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:glass/glass.dart';
import 'package:photon/services/photon_server/photon_server.dart';

import '../methods/methods.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  PhotonServer photonServer = PhotonServer();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MaterialButton(
          color: Colors.lightGreenAccent.shade700,
          minWidth: size.width / 2,
          height: size.height / 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () async {
            await handleSharing(context);
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
              ).asGlass(
                  clipBorderRadius: BorderRadius.circular(10),
                  tintColor: Colors.grey),
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: const SizedBox(
                  width: 120,
                  height: 30,
                  child: Center(child: Text('Send')),
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
              ).asGlass(
                clipBorderRadius: BorderRadius.circular(10),
                tileMode: TileMode.mirror,
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: const SizedBox(
                  width: 120,
                  height: 30,
                  child: Center(child: Text('Receive')),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
