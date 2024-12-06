import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:photon/components/constants.dart';
import 'package:photon/components/snackbar.dart';
import 'package:photon/services/photon_sender.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:installed_apps/installed_apps.dart';

class AppsList extends StatefulWidget {
  const AppsList({super.key});

  @override
  State<AppsList> createState() => _AppsListState();
}

class _AppsListState extends State<AppsList> {
  static const platform = MethodChannel('dev.abhi.photon');
  Future<List<AppInfo>> future = InstalledApps.getInstalledApps(true, true);
  Map<String, String> appToFilePathMapping = {};
  List<AppInfo> apps = <AppInfo>[];
  List<String> paths = [];
  TextEditingController searchController = TextEditingController();
  List<AppInfo> searchData = [];
  late List<AppInfo> data;
  bool isSearched = false;

  Future<String> _getAppPath(String packageName) async {
    try {
      final String result = await platform
          .invokeMethod('getAppPath', {'packageName': packageName});
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to get app path: '${e.message}'.");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Search"),
                        content: TextFormField(
                          controller: searchController,
                          decoration: inputDecoration,
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                searchData = [];
                                for (var element in data) {
                                  if (element.name.toLowerCase().contains(
                                      searchController.text.toLowerCase())) {
                                    searchData.add(element);
                                  }
                                }
                                setState(() {
                                  isSearched = true;
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text("Search"))
                        ],
                      );
                    });
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot<List<AppInfo>> snap) {
            if (snap.connectionState == ConnectionState.done) {
              data = snap.data!;
              apps = isSearched ? searchData : data;
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
                                  onTap: () async {
                                    value.isSelect(item);
                                    if (value.isSelected[item]) {
                                      var path = await _getAppPath(
                                          apps[item].packageName);
                                      appToFilePathMapping[
                                          apps[item].packageName] = path;
                                      paths.add(path);
                                    } else {
                                      var packageName = apps[item].packageName;
                                      paths.remove(
                                          appToFilePathMapping[packageName]);
                                    }
                                  },
                                  leading: Image.memory(
                                    apps[item].icon!,
                                    width: 36,
                                  ),
                                  title: Text(
                                    apps[item].name,
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
          if (paths.isNotEmpty) {
            PhotonSender.handleSharing(fileList: paths);
          } else {
            Navigator.of(context).pop();
            showSnackBar(context, 'No apk chosen');
          }
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

  search() {}
}
