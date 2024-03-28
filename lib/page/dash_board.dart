// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:cabme_driver/constant/constant.dart';
import 'package:cabme_driver/constant/show_toast_dialog.dart';
import 'package:cabme_driver/controller/dash_board_controller.dart';
import 'package:cabme_driver/routes/routes.dart';
import 'package:cabme_driver/themes/constant_colors.dart';
import 'package:cabme_driver/utils/Preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../model/user_model.dart';

class DashBoard extends StatelessWidget {
  DashBoard({super.key});

  DateTime backPress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: ConstantColors.primary,
      ),
    );
    return GetX<DashBoardController>(
      init: DashBoardController(),
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            final timeGap = DateTime.now().difference(backPress);
            final cantExit = timeGap >= const Duration(seconds: 2);
            backPress = DateTime.now();
            if (cantExit) {
              const snack = SnackBar(
                content: Text(
                  'Press Back button again to Exit',
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
              return false; // false will do nothing when back press
            } else {
              return true; // true will exit the app
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor:
                  controller.selectedRoute.value == Routes.myProfile ? ConstantColors.primary : ConstantColors.background,
              elevation: 0,
              centerTitle: true,
              title: Text(
                controller.selectedRoute.value.toString().tr,
                style: TextStyle(
                  color:
                      controller.selectedRoute.value != Routes.ridesHistory || controller.selectedRoute.value != Routes.documents
                          ? Colors.black
                          : Colors.white,
                ),
              ),
              leading: Builder(
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: ConstantColors.primary.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/icons/ic_side_menu.png",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            drawer: buildAppDrawer(context, controller),
            body: controller.buildSelectedRoute(controller.selectedRoute.value),
          ),
        );
      },
    );
  }

  buildAppDrawer(BuildContext context, DashBoardController controller) {
    final List<Widget> drawerRoutes = controller.drawerRoutes.map((route) {
      return ListTile(
        leading: Icon(route.drawerIcon),
        title: Text(route.route.tr),
        selected: route.route == controller.selectedRoute.value,
        onTap: () => controller.onRouteSelected(route.route),
      );
    }).toList();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          controller.userModel == null
              ? Center(
                  child: CircularProgressIndicator(color: ConstantColors.primary),
                )
              : UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: ConstantColors.primary,
                  ),
                  currentAccountPicture: ClipOval(
                    child: Container(
                      color: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl: controller.userModel!.userData!.photoPath.toString(),
                        fit: BoxFit.fill,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  accountName: Text(
                    '${controller.userModel!.userData!.prenom.toString()} ${controller.userModel!.userData!.nom.toString()}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.userModel!.userData!.email.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        width: 50,
                        child: Switch(
                          value: controller.isActive.value,
                          activeColor: ConstantColors.blue,
                          inactiveThumbColor: Colors.red,
                          onChanged: (value) {
                            controller.isActive.value = value;

                            Map<String, dynamic> bodyParams = {
                              'id_driver': Preferences.getInt(Preferences.userId),
                              'online': controller.isActive.value ? 'yes' : 'no',
                            };

                            controller.changeOnlineStatus(bodyParams).then((value) {
                              if (value != null) {
                                if (value['success'] == "success") {
                                  UserModel userModel = Constant.getUserData();
                                  userModel.userData!.online = value['data']['online'];
                                  Preferences.setString(Preferences.user, jsonEncode(userModel.toJson()));
                                  controller.getUsrData();
                                  ShowToastDialog.showToast(value['message']);
                                } else {
                                  ShowToastDialog.showToast(value['error']);
                                }
                              }
                            });
                            //Do you things
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          Column(children: drawerRoutes),
        ],
      ),
    );
  }
}

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}
