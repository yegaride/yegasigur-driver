import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme_driver/constant/show_toast_dialog.dart';
import 'package:cabme_driver/model/ride_model.dart';
import 'package:cabme_driver/utils/Preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:cabme_driver/constant/constant.dart';
import 'package:cabme_driver/service/api.dart';

class MapViewController extends GetxController {
  // LatLng arubaCenter = const LatLng(12.516667, -69.95);
  LatLng arubaCenter = LatLng(
    Constant.currentLocation?.latitude ?? 12.516667,
    Constant.currentLocation?.longitude ?? -69.95,
  );

  RxString availableJobs = '0'.obs;
  RxBool isLoading = true.obs;

  late final Timer timer;

  @override
  void onInit() {
    getAvailableJobs();

    timer = Timer.periodic(const Duration(seconds: 20), (_) => getAvailableJobs());

    super.onInit();
  }

  @override
  void onClose() {
    timer.cancel();

    super.onClose();
  }

  void getAvailableJobs() async {
    try {
      final response = await http.get(
        Uri.parse("${API.driverAllRides}?id_driver=${Preferences.getInt(Preferences.userId)}"),
        headers: API.header,
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading(false);
        RideModel model = RideModel.fromJson(responseBody);

        final newRides = model.data!.where((ride) => ride.statut == 'new');

        availableJobs.value = newRides.length.toString();

        // rideList.value = model.data!;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        availableJobs.value = 'E';
      } else {
        ShowToastDialog.showToast('Unauthorized');
      }
    } on TimeoutException catch (e) {
      availableJobs.value = 'E';
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      availableJobs.value = 'E';
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      availableJobs.value = 'E';
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      availableJobs.value = 'E';
      ShowToastDialog.showToast(e.toString());
    } 
    return null;
  }
}
