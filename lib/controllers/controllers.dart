import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Status { waiting, downloaded, cancelled, downloading, error }

class PercentageController extends GetxController {
  var percentage = [].obs;
  var isCancelled = [].obs;
  var isReceived = [].obs;
  var speed = 0.0.obs;
  var minSpeed = 0.0.obs;
  var maxSpeed = 0.0.obs;
  var estimatedTime = ''.obs;
  var totalTimeElapsed = 0.obs;
  var fileStatus = [].obs;
  var isFinished = false.obs;
  List<CancelToken> cancelTokenList = [];
}

class ReceiverDataController extends GetxController {
  var receiverMap = {}.obs;
}

class RawTextController extends GetxController {
  var rawText = "".obs;
}
