// import 'dart:io';
// import 'package:adaptive_theme/adaptive_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:photon/components/snackbar.dart';
// import 'package:photon/models/sender_model.dart';
// import 'package:photon/views/receive_ui/progress_page.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../../components/constants.dart';
// import '../../services/photon_receiver.dart';

// class QrReceivePage extends StatefulWidget {
//   const QrReceivePage({
//     super.key,
//   });

//   @override
//   State<QrReceivePage> createState() => _QrReceivePageState();
// }

// class _QrReceivePageState extends State<QrReceivePage> {
//   late Directory dir;
//   bool isCameraStopped = false;
//   bool isDenied = false;
//   bool isError = false;
//   bool isRequestSent = false;

//   MobileScannerController msController = MobileScannerController();

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return ValueListenableBuilder(
//         valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
//         builder: (_, AdaptiveThemeMode mode, __) {
//           return Scaffold(
//             appBar: AppBar(
//               backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
//               title: const Text(" QR - receive"),
//               leading: BackButton(
//                 color: Colors.white,
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               flexibleSpace: mode.isLight
//                   ? Container(
//                       decoration: appBarGradient,
//                     )
//                   : null,
//             ),
//             body: isCameraStopped
//                 ? isDenied
//                     ? const Center(
//                         child:
//                             Text("Access denied by sender. Please try again"))
//                     : const Center(
//                         child: Text(
//                           "Waiting for sender to approve.\n Ask sender to accept your request",
//                           textAlign: TextAlign.center,
//                         ),
//                       )
//                 : MobileScanner(
//                     controller: msController,
//                     onDetect: (code, _) {
//                       if (code.rawValue != null) {
//                         msController.stop();
//                         setState(() {
//                           isCameraStopped = true;
//                         });
//                         actions(code.rawValue);
//                       }
//                     },
//                   ),
//             floatingActionButton: isCameraStopped
//                 ? FloatingActionButton.extended(
//                     backgroundColor:
//                         mode.isDark ? Colors.blueGrey.shade900 : null,
//                     onPressed: () async {
//                       setState(() {
//                         isCameraStopped = false;
//                         isDenied = false;
//                         msController = MobileScannerController();
//                       });
//                     },
//                     label: const Text('Retry'),
//                     icon: const Icon(
//                       Icons.refresh,
//                       color: Color.fromARGB(255, 75, 231, 81),
//                     ),
//                   )
//                 : null,
//           );
//         });
//   }

//   actions(link) async {
//     try {
//       String host = Uri.parse(link).host;
//       int port = Uri.parse(link).port;
//       SenderModel senderModel =
//           await PhotonReceiver.isPhotonServer(host, port.toString());

//       var resp = await PhotonReceiver.isRequestAccepted(
//         senderModel,
//       );
//       if (resp['accepted']) {
//         // ignore: use_build_context_synchronously
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) {
//               return ProgressPage(
//                 senderModel: senderModel,
//                 secretCode: resp['code'],
//               );
//             },
//           ),
//         );
//       } else {
//         setState(() {
//           isDenied = true;
//         });
//       }
//     } catch (_) {
//       showSnackBar(
//           context, 'Wrong QR code / Devices are not connected to same network');
//     }
//   }
// }
