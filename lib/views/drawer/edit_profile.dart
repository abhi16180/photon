import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  List selected = List.generate(4, (index) => false);
  Box box = Hive.box('appData');
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit your profile"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Select avatar by tapping',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  width: w > 720 ? w / 2.6 : w - 20,
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.2, crossAxisCount: 2),
                    itemBuilder: ((context, index) => Card(
                            child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selected.fillRange(0, 4, false);
                              selected[index] = true;
                              box.put('avatarPath',
                                  'assets/avatars/${index + 1}.png');
                            });
                          },
                          child: Card(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset('assets/avatars/${index + 1}.png'),
                                if (selected[index]) ...{
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: SvgPicture.asset(
                                      'assets/icons/right_mark.svg',
                                      color: const Color.fromARGB(
                                          255, 128, 242, 132),
                                      width: 40,
                                    ),
                                  )
                                }
                              ],
                            ),
                          ),
                        ))),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: w > 720 ? w / 2.6 : w - 20,
                    child: TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          hintText: 'Edit your username here'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (usernameController.text.trim() != '') {
            box.put('username', usernameController.text.trim());
          }
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        },
        label: const Text('Done'),
        icon: const Icon(Icons.done),
      ),
    );
  }
}
