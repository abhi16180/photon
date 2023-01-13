import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:photon/services/photon_sender.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class AppsList extends StatefulWidget {
  const AppsList({super.key});

  @override
  State<AppsList> createState() => _AppsListState();
}

class _AppsListState extends State<AppsList> {
  final future = DeviceApps.getInstalledApplications(includeAppIcons: true);
  List<ApplicationWithIcon> apps = <ApplicationWithIcon>[];
  List<String> paths = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
      ),
      body: FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot snap) {
            if (snap.connectionState == ConnectionState.done) {
              List<Application> data = snap.data;
              apps = data.cast<ApplicationWithIcon>();
              //create list of bool
              List<bool> boolList = List.generate(apps.length, (i) => false);

              return ListView.separated(
                  separatorBuilder: ((context, index) => const Divider(
                        thickness: 1.5,
                      )),
                  itemCount: apps.length,
                  itemBuilder: (context, item) {
                    return ChangeNotifierProvider(
                        create: (context) =>
                            ListTileState(isSelected: boolList),
                        builder: ((context, child) {
                          return Consumer(
                            builder: ((context, ListTileState value, child) =>
                                ListTile(
                                  selected: value.isSelected[item],
                                  onTap: () {
                                    value.isSelect(item);
                                    if (value.isSelected[item]) {
                                      paths.add(apps[item].apkFilePath);
                                    } else {
                                      paths.remove(apps[item].apkFilePath);
                                    }
                                  },
                                  leading: Image.memory(
                                    apps[item].icon,
                                    width: 36,
                                  ),
                                  title: Text(
                                    apps[item].appName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: value.isSelected[item]
                                      ? const Icon(UniconsLine.check_circle)
                                      : null,
                                )),
                          );
                        }));
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          PhotonSender.handleSharing(context, appList: paths);
        },
        label: const Text('Share'),
        icon: const Icon(UniconsLine.share),
      ),
    );
  }
}

class ListTileState extends ChangeNotifier {
  List<bool> isSelected;
  ListTileState({required this.isSelected});
  isSelect(i) {
    isSelected[i] = !isSelected[i];
    notifyListeners();
  }
}
