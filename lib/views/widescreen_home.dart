import 'package:flutter/material.dart';
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
        if (!isloading) ...{
          Center(
            child: Card(
              child: MaterialButton(
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/lottie/rocket-send.json',
                      width: size.width / 4,
                      height: size.height / 4,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Share',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width / 10,
          ),
          Card(
            child: MaterialButton(
              clipBehavior: Clip.hardEdge,
              onPressed: () {
                Navigator.of(context).pushNamed('/receivepage');
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/lottie/receive-file.json',
                      width: size.width / 4, height: size.height / 4),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Receive',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
