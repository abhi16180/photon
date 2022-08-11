import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glass/glass.dart';
import 'package:lottie/lottie.dart';

import '../methods/methods.dart';

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
        !isloading
            ? MaterialButton(
                color: Colors.lightGreenAccent.shade700,
                minWidth: size.width / 4,
                height: size.height / 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onPressed: () async {
                  setState(() {
                    isloading = true;
                  });
                  await handleSharing(context);
                  setState(() {
                    isloading = false;
                  });
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
              )
            : Center(
                child: SizedBox(
                  width: size.width / 4,
                  height: size.height / 4,
                  child: Lottie.asset('assets/lottie/load.json',
                      width: 40, height: 40),
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
                ).asGlass(
                  clipBorderRadius: BorderRadius.circular(10),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
