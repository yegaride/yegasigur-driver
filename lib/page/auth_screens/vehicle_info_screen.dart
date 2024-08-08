import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cabme_driver/constant/show_toast_dialog.dart';
import 'package:cabme_driver/controller/vehicle_info_controller.dart';
import 'package:cabme_driver/model/brand_model.dart';
import 'package:cabme_driver/page/auth_screens/add_profile_photo_screen.dart';
import 'package:cabme_driver/page/auth_screens/login_screen.dart';
import 'package:cabme_driver/themes/constant_colors.dart';
import 'package:cabme_driver/themes/text_field_them.dart';

class VehicleInfoScreen extends StatelessWidget {
  VehicleInfoScreen({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey();

  static final TextEditingController brandController = TextEditingController();
  static final TextEditingController modelController = TextEditingController();
  static final TextEditingController colorController = TextEditingController();
  static final TextEditingController carMakeController = TextEditingController();
  static final TextEditingController millageController = TextEditingController();
  static final TextEditingController kmDrivenController = TextEditingController();
  static final TextEditingController numberPlateController = TextEditingController();
  static final TextEditingController numberOfPassengersController = TextEditingController();

  final vehicleInfoController = Get.put(VehicleInfoController());

  void _onContinueButtonPressed() async {
    if (!_formKey.currentState!.validate()) {
      ShowToastDialog.showToast("Please select vehicle type".tr);
      return;
    }

    if (vehicleInfoController.selectedCategoryID.value.isEmpty) {
      return;
    }

    ShowToastDialog.showLoader('Please wait');

    Map<String, String> bodyParams1 = {
      "brand": vehicleInfoController.selectedBrandID.value,
      "model": modelController.text.trim(),
      "color": colorController.text,
      "carregistration": numberPlateController.text.toUpperCase(),
      "passenger": numberOfPassengersController.text,
      "id_driver": vehicleInfoController.userModel!.userData!.id.toString(),
      "id_categorie_vehicle": vehicleInfoController.selectedCategoryID.value,
      "car_make": carMakeController.text,
      "milage": millageController.text,
      "km_driven": kmDrivenController.text,
    };

    await vehicleInfoController.vehicleRegister(bodyParams1).then((value) {
      ShowToastDialog.closeLoader();

      if (value == null) {
        return;
      }

      if (value.success.toLowerCase() != "success") {
        ShowToastDialog.showToast(value.error);
      }

      Get.to(() => AddProfilePhotoScreen(fromOtp: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom == 0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstantColors.background,
        body: WillPopScope(
          onWillPop: () async {
            Get.offAll(() => LoginScreen());
            return true;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        'Enter your vehicle information'.tr,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 22, color: Colors.black, letterSpacing: 1.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 55),
                  Image.asset('assets/images/appIcon.png', width: 100),
                  const SizedBox(height: 23),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              vehicleInfoController.getBrand().then((value) {
                                if (value!.isNotEmpty) {
                                  brandDialog(context, value);
                                } else {
                                  ShowToastDialog.showToast("Please contact administrator".tr);
                                }
                              });
                            },
                            child: TextFieldThem.boxBuildTextField(
                              hintText: 'Brand'.tr,
                              controller: brandController,
                              textInputType: TextInputType.text,
                              maxLength: 20,
                              enabled: false,
                              contentPadding: EdgeInsets.zero,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFieldThem.boxBuildTextField(
                            hintText: 'Model'.tr,
                            controller: modelController,
                            textInputType: TextInputType.text,
                            maxLength: 20,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'required'.tr;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFieldThem.boxBuildTextField(
                            hintText: 'Color'.tr,
                            controller: colorController,
                            textInputType: TextInputType.emailAddress,
                            maxLength: 20,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'required'.tr;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFieldThem.boxBuildTextField(
                            hintText: 'Number Plate'.tr,
                            controller: numberPlateController,
                            textInputType: TextInputType.text,
                            maxLength: 40,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'required'.tr;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: keyboardIsOpen,
                    child: Center(
                      child: FloatingActionButton(
                        backgroundColor: ConstantColors.primary,
                        onPressed: _onContinueButtonPressed,
                        child: const Icon(
                          Icons.navigate_next,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  brandDialog(BuildContext context, List<BrandData>? brandList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Brand list'),
          content: SizedBox(
            height: 300.0,
            width: 300.0,
            child: brandList!.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: brandList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: InkWell(
                          onTap: () {
                            brandController.text = brandList[index].name.toString();
                            vehicleInfoController.selectedBrandID.value = brandList[index].id.toString();
                            Get.back();
                          },
                          child: Text(brandList[index].name.toString()),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
