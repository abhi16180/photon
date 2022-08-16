import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/views/intro_page.dart';

class WidescreenHome extends StatefulWidget {
  const WidescreenHome({Key? key}) : super(key: key);

  @override
  State<WidescreenHome> createState() => _WidescreenHomeState();
}

class _WidescreenHomeState extends State<WidescreenHome> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isloading) ...{
          MaterialButton(
            color: Colors.lightGreenAccent.shade400.withAlpha(225),
            minWidth: size.width / 4,
            height: size.height / 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () async {
              //todo remove this after testing
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const IntroPage();
              }));
              // setState(() {
              //   isloading = true;
              // });
              // await handleSharing(context);
              // setState(() {
              //   isloading = false;
              // });
            },
            child: SizedBox(
              width: size.width / 4,
              height: size.height / 4,
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
                      width: 80,
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
          ),
          SizedBox(
            width: size.width / 10,
          ),
          MaterialButton(
            color: Colors.blue,
            minWidth: size.width / 4,
            height: size.height / 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              Navigator.of(context).pushNamed('/receivepage');
            },
            child: SizedBox(
              width: size.width / 4,
              height: size.height / 4,
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
                      width: 80,
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
                          child: Text('Receive',
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
                ],
              ),
            ),
          )
        } else ...{
          Center(
            child: SizedBox(
              width: size.width / 4,
              height: size.height / 4,
              child: Lottie.asset('assets/lottie/setting_up.json',
                  width: 40, height: 40),
            ),
          ),
          const Center(
            child: Text(
              'Please wait !',
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          )
        }
      ],
    );
  }
}
