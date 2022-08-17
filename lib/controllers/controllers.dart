import 'package:dio/dio.dart';
import 'package:get/get.dart';

class PercentageController extends GetxController {
  var percentage = [].obs;
  var isCancelled = [].obs;
  List<CancelToken> cancelTokenList = [];
}
