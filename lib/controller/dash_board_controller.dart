import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme_driver/constant/constant.dart';
import 'package:cabme_driver/constant/show_toast_dialog.dart';
import 'package:cabme_driver/model/drawer_route.dart';
import 'package:cabme_driver/model/driver_location_update.dart';
import 'package:cabme_driver/model/trancation_model.dart';
import 'package:cabme_driver/model/user_model.dart';
import 'package:cabme_driver/page/add_bank_details/show_bank_details.dart';
import 'package:cabme_driver/page/auth_screens/login_screen.dart';
import 'package:cabme_driver/page/contact_us/contact_us_screen.dart';
import 'package:cabme_driver/page/document_status/document_status_screen.dart';
import 'package:cabme_driver/page/localization_screens/localization_screen.dart';
import 'package:cabme_driver/page/my_profile/my_profile_screen.dart';
import 'package:cabme_driver/page/new_ride_screens/new_ride_screen.dart';
import 'package:cabme_driver/page/privacy_policy/privacy_policy_screen.dart';
import 'package:cabme_driver/page/terms_of_service/terms_of_service_screen.dart';
import 'package:cabme_driver/page/wallet/wallet_screen.dart';
import 'package:cabme_driver/routes/routes.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/utils/Preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class DashBoardController extends GetxController {
  Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  RxString totalEarn = "0".obs;

  @override
  void onInit() {
    getUsrData();
    locationSubscription = location.onLocationChanged.listen((event) {});
    getCurrentLocation();
    updateToken();
    updateCurrentLocation();
    getPaymentSettingData();

    super.onInit();
  }

  updateToken() async {
    // use the returned token to send messages to users from your custom server
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      updateFCMToken(token);
    }
  }

  getCurrentLocation() async {
    LocationData location = await Location().getLocation();
    setCurrentLocation(location.latitude.toString(), location.longitude.toString());
  }

  UserModel? userModel;

  getUsrData() async {
    userModel = Constant.getUserData();

    isActive.value = userModel!.userData!.online == "yes" ? true : false;

    final response =
        await http.get(Uri.parse("${API.walletHistory}?id_diver=${Preferences.getInt(Preferences.userId)}"), headers: API.header);

    Map<String, dynamic> responseBody = json.decode(response.body);

    if (response.statusCode == 200 && responseBody['success'] == "success") {
      TruncationModel model = TruncationModel.fromJson(responseBody);

      totalEarn.value = model.totalEarnings!.toString();
    } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
    } else {}
  }

  RxBool isActive = true.obs;

  RxString selectedRoute = Routes.ridesHistory.obs;

  final drawerRoutes = [
    DrawerRoute(Routes.ridesHistory, CupertinoIcons.car_detailed),
    DrawerRoute(Routes.documents, Icons.domain_verification),
    DrawerRoute(Routes.myProfile, Icons.person_outline),
    DrawerRoute(Routes.myEarnings, Icons.account_balance_wallet_outlined),
    DrawerRoute(Routes.addBank, Icons.account_balance),
    DrawerRoute(Routes.changeLanguage, Icons.language),
    DrawerRoute(Routes.contactUs, Icons.rate_review_outlined),
    DrawerRoute(Routes.termService, Icons.design_services),
    DrawerRoute(Routes.privacyPolicy, Icons.privacy_tip),
    DrawerRoute(Routes.signOut, Icons.logout),
  ];

  Widget buildSelectedRoute(String route) {
    return switch (route) {
      Routes.ridesHistory => NewRideScreen(),
      Routes.documents => DocumentStatusScreen(),
      Routes.myProfile => MyProfileScreen(),
      Routes.myEarnings => WalletScreen(),
      Routes.addBank => const ShowBankDetails(),
      Routes.changeLanguage => const LocalizationScreens(intentType: "dashBoard"),
      Routes.contactUs => const ContactUsScreen(),
      Routes.termService => const TermsOfServiceScreen(),
      Routes.privacyPolicy => const PrivacyPolicyScreen(),
      _ => const Text('Error'),
    };
  }

  void onRouteSelected(String route) {
    if (route == Routes.signOut) {
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Get.offAll(() => LoginScreen());
    } else {
      selectedRoute.value = route;
    }

    Get.back();
  }

  updateCurrentLocation() async {
    print(Preferences.getInt(Preferences.userId).toString());
    if (isActive.value) {
      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.granted) {
        location.enableBackgroundMode(enable: true);
        location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: 1);
        locationSubscription = location.onLocationChanged.listen((locationData) {
          LocationData currentLocation = locationData;
          Constant.currentLocation = locationData;
          DriverLocationUpdate driverLocationUpdate = DriverLocationUpdate(
              rotation: currentLocation.heading.toString(),
              active: isActive.value,
              driverId: Preferences.getInt(Preferences.userId).toString(),
              driverLatitude: currentLocation.latitude.toString(),
              driverLongitude: currentLocation.longitude.toString());
          Constant.driverLocationUpdate.doc(Preferences.getInt(Preferences.userId).toString()).set(driverLocationUpdate.toJson());
          setCurrentLocation(currentLocation.latitude.toString(), currentLocation.longitude.toString());
        });
      } else {
        location.requestPermission().then((permissionStatus) {
          if (permissionStatus == PermissionStatus.granted) {
            location.enableBackgroundMode(enable: true);
            location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: 1);
            locationSubscription = location.onLocationChanged.listen((locationData) {
              LocationData currentLocation = locationData;
              Constant.currentLocation = locationData;
              DriverLocationUpdate driverLocationUpdate = DriverLocationUpdate(
                  rotation: currentLocation.heading.toString(),
                  active: isActive.value,
                  driverId: Preferences.getInt(Preferences.userId).toString(),
                  driverLatitude: currentLocation.latitude.toString(),
                  driverLongitude: currentLocation.longitude.toString());
              Constant.driverLocationUpdate
                  .doc(Preferences.getInt(Preferences.userId).toString())
                  .set(driverLocationUpdate.toJson());
              setCurrentLocation(currentLocation.latitude.toString(), currentLocation.longitude.toString());
            });
          }
        });
      }
    } else {
      DriverLocationUpdate driverLocationUpdate = DriverLocationUpdate(
          rotation: "0",
          active: false,
          driverId: Preferences.getInt(Preferences.userId).toString(),
          driverLatitude: "0",
          driverLongitude: "0");
      Constant.driverLocationUpdate.doc(Preferences.getInt(Preferences.userId).toString()).set(driverLocationUpdate.toJson());
    }
  }

  // deleteCurrentOrderLocation() {
//   RideData? rideData = Constant.getCurrentRideData();
//   if (rideData != null) {
//     String orderId = "";
//     if (rideData.rideType! == 'driver') {
//       orderId = '${rideData.idUserApp}-${rideData.id}-${rideData.idConducteur}';
//     } else {
//       orderId = (double.parse(rideData.idUserApp.toString()) < double.parse(rideData.idConducteur!))
//           ? '${rideData.idUserApp}-${rideData.id}-${rideData.idConducteur}'
//           : '${rideData.idConducteur}-${rideData.id}-${rideData.idUserApp}';
//     }
//     Location location = Location();
//     location.enableBackgroundMode(enable: false);
//     Constant.locationUpdate.doc(orderId).delete().then((value) async {
//       await updateCurrentLocation(data: rideData);
//       Preferences.clearKeyData(Preferences.currentRideData);
//       locationSubscription.cancel();
//     });
//   }
// }

  Future<dynamic> setCurrentLocation(String latitude, String longitude) async {
    try {
      Map<String, dynamic> bodyParams = {
        'id_user': Preferences.getInt(Preferences.userId),
        'user_cat': userModel!.userData!.userCat,
        'latitude': latitude,
        'longitude': longitude
      };
      final response = await http.post(Uri.parse(API.updateLocation), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> updateFCMToken(String token) async {
    try {
      Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
        'fcm_id': token,
        'device_id': "",
        'user_cat': userModel!.userData!.userCat
      };
      final response = await http.post(Uri.parse(API.updateToken), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> changeOnlineStatus(bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.changeStatus), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        updateCurrentLocation();
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getPaymentSettingData() async {
    try {
      final response = await http.get(Uri.parse(API.paymentSetting), headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(Preferences.paymentSetting, jsonEncode(responseBody));
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
