// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:cabme_driver/constant/show_toast_dialog.dart';
import 'package:cabme_driver/controller/sign_up_controller.dart';
import 'package:cabme_driver/themes/button_them.dart';
import 'package:cabme_driver/themes/constant_colors.dart';
import 'package:cabme_driver/themes/text_field_them.dart';
import 'package:cabme_driver/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'vehicle_info_screen.dart';

class SignupScreen extends StatefulWidget {
  String? phoneNumber;

  SignupScreen({super.key, required this.phoneNumber});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // account phone
  TextEditingController _accountPhoneController = TextEditingController();

  // main user information
  final _mainUserFirstNameController = TextEditingController();
  final _mainUserLastNameController = TextEditingController();
  final _mainUserPhone = TextEditingController();
  String? _mainUserGender;

  // secondary user information
  final _secondaryUserFirstNameController = TextEditingController();
  final _secondaryUserLastNameController = TextEditingController();
  final _secondaryUserPhone = TextEditingController();
  String? _secondaryUserGender;

  final _accountMail = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordController = TextEditingController();

  final controller = Get.put(SignUpController());

  Future<void> onSignUpPressed() async {
    if (_mainUserGender == _secondaryUserGender) {
      // TODO i18n
      ShowToastDialog.showToast('Both users cannot be of the same sex');
      return;
    }

    FocusScope.of(context).unfocus();

    if (SignupScreen._formKey.currentState!.validate()) {
      Map<String, String> bodyParams = {
        'phone': _accountPhoneController.text.trim(), // account phone
        'firstname': _mainUserFirstNameController.text.trim().toString(),
        'lastname': _mainUserLastNameController.text.trim().toString(),
        'main_user_phone': _mainUserPhone.text.trim().toString(),
        'main_user_gender': _mainUserGender.toString(),
        'secondary_user_firstname': _secondaryUserFirstNameController.text.trim(),
        'secondary_user_lastname': _secondaryUserLastNameController.text.trim(),
        'secondary_user_phone': _secondaryUserPhone.text.trim(),
        'secondary_user_gender': _secondaryUserGender.toString(),
        'email': _accountMail.text.trim(),
        'password': _passwordController.text,
        'login_type': 'phone',
        'tonotify': 'yes',
        'account_type': 'driver',
        'age': "25",
      };
      await controller.signUp(bodyParams).then((value) async {
        if (value == null) return;

        if (value.success != "success") {
          ShowToastDialog.showToast(value.error!);
          return;
        }

        Preferences.setInt(
          Preferences.userId,
          int.parse(
            value.userData!.id.toString(),
          ),
        );

        Preferences.setString(
          Preferences.user,
          jsonEncode(value),
        );

        await Preferences.setUserData(value);
        Get.to(VehicleInfoScreen());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _accountPhoneController = TextEditingController(text: widget.phoneNumber);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstantColors.background,
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Form(
                  key: SignupScreen._formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Image.asset('assets/images/appIcon.png', width: 120),
                        const SizedBox(height: 25),
                        Text(
                          "Sign up".tr.toUpperCase(),
                          style: const TextStyle(
                            letterSpacing: 0.60,
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Divider(
                            color: ConstantColors.primary,
                            thickness: 3,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // TODO i18n
                            'account phone number'.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'phone'.tr,
                            controller: _accountPhoneController,
                            textInputType: TextInputType.number,
                            maxLength: 13,
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
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // TODO i18n
                            'main user information'.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldThem.boxBuildTextField(
                                hintText: 'Name'.tr,
                                controller: _mainUserFirstNameController,
                                textInputType: TextInputType.text,
                                maxLength: 22,
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
                              width: 10,
                            ),
                            Expanded(
                              child: TextFieldThem.boxBuildTextField(
                                hintText: 'Last Name'.tr,
                                controller: _mainUserLastNameController,
                                textInputType: TextInputType.text,
                                maxLength: 22,
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
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'phone'.tr,
                            controller: _mainUserPhone,
                            textInputType: TextInputType.text,
                            obscureText: false,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value != null) {
                                return null;
                              } else {
                                // TODO i18n
                                return 'Main user phone is required'.tr;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: DropdownButtonFormField(
                            key: const Key('gender'),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left: 8),
                              errorStyle: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                            // isExpanded: true,
                            hint: Text(
                              'gender'.tr,
                              style: const TextStyle(height: 1.8),
                            ),
                            value: _mainUserGender,
                            onChanged: (value) {
                              setState(() {
                                _mainUserGender = value!;
                              });
                            },
                            items: ['male', 'female'].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.tr,
                                  style: const TextStyle(height: 1.8),
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (_mainUserGender == null) {
                                return 'required'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // TODO i18n
                            'secondary user information'.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldThem.boxBuildTextField(
                                hintText: 'Name'.tr,
                                controller: _secondaryUserFirstNameController,
                                textInputType: TextInputType.text,
                                maxLength: 22,
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
                              width: 10,
                            ),
                            Expanded(
                              child: TextFieldThem.boxBuildTextField(
                                hintText: 'Last Name'.tr,
                                controller: _secondaryUserLastNameController,
                                textInputType: TextInputType.text,
                                maxLength: 22,
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
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'phone'.tr,
                            controller: _secondaryUserPhone,
                            textInputType: TextInputType.text,
                            obscureText: false,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value != null) {
                                return null;
                              } else {
                                // TODO i18n
                                return 'Main user phone is required'.tr;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: DropdownButtonFormField(
                            key: const Key('secondaryUserGender'),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left: 8),
                              errorStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                            // isExpanded: true,
                            hint: Text(
                              'gender'.tr,
                              style: const TextStyle(height: 1.8),
                            ),
                            value: _secondaryUserGender,
                            onChanged: (value) {
                              setState(() {
                                _secondaryUserGender = value!;
                              });
                            },
                            items: ['male', 'female'].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.tr,
                                  style: const TextStyle(height: 1.8),
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (_secondaryUserGender == null) {
                                return 'required'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // TODO i18n
                            'choose email and password'.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'email'.tr,
                            controller: _accountMail,
                            textInputType: TextInputType.emailAddress,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              bool emailValid = RegExp(
                                r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
                              ).hasMatch(value!);
                              if (!emailValid) {
                                return 'email not valid'.tr;
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'password'.tr,
                            controller: _passwordController,
                            textInputType: TextInputType.text,
                            obscureText: true,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value!.length >= 6) {
                                return null;
                              } else {
                                return 'Password required at least 6 characters'.tr;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFieldThem.boxBuildTextField(
                            hintText: 'confirm_password'.tr,
                            controller: _confirmPasswordController,
                            textInputType: TextInputType.text,
                            obscureText: true,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (_passwordController.text != value) {
                                return 'Confirm password is invalid'.tr;
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50, bottom: 80),
                          child: ButtonThem.buildButton(
                            context,
                            title: 'Sign up'.tr,
                            btnHeight: 45,
                            btnColor: ConstantColors.primary,
                            txtColor: Colors.white,
                            onPress: onSignUpPressed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // child: SingleChildScrollView(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 22),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.only(top: 20),
              //           child: Text(
              //             'enter_information'.tr,
              //             style: const TextStyle(fontSize: 26, color: Colors.black, fontWeight: FontWeight.w600),
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.symmetric(vertical: 20),
              //           child: Form(
              //             key: _formKey,
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 TextFieldThem.buildTextField(
              //                   title: 'full_name'.tr,
              //                   labelText: 'full_name'.tr,
              //                   controller: _firstNameController,
              //                   textInputType: TextInputType.text,
              //                   icon: Icons.account_circle_outlined,
              //                   maxLength: 20,
              //                   contentPadding: EdgeInsets.zero,
              //                   validators: (String? value) {
              //                     if (value!.isNotEmpty) {
              //                       return null;
              //                     } else {
              //                       return 'required'.tr;
              //                     }
              //                   },
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(top: 10),
              //                   child: TextFieldThem.buildTextField(
              //                     title: 'phone'.tr,
              //                     labelText: 'phone'.tr,
              //                     controller: _phoneController,
              //                     textInputType: TextInputType.number,
              //                     icon: Icons.phone,
              //                     maxLength: 13,
              //                     enabled: false,
              //                     contentPadding: EdgeInsets.zero,
              //                     validators: (String? value) {
              //                       if (value!.isNotEmpty) {
              //                         return null;
              //                       } else {
              //                         return 'required'.tr;
              //                       }
              //                     },
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(top: 10),
              //                   child: TextFieldThem.buildTextField(
              //                     title: 'email'.tr,
              //                     labelText: 'email'.tr,
              //                     controller: _emailController,
              //                     textInputType: TextInputType.emailAddress,
              //                     icon: Icons.email_outlined,
              //                     maxLength: 20,
              //                     contentPadding: EdgeInsets.zero,
              //                     validators: (String? value) {
              //                       bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value!);
              //                       if (!emailValid) {
              //                         return 'email not valid'.tr;
              //                       } else {
              //                         return null;
              //                       }
              //                     },
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(top: 10),
              //                   child: TextFieldThem.buildTextField(
              //                     title: 'address'.tr,
              //                     labelText: 'address'.tr,
              //                     controller: _addressController,
              //                     textInputType: TextInputType.text,
              //                     icon: Icons.location_on,
              //                     maxLength: 40,
              //                     contentPadding: EdgeInsets.zero,
              //                     validators: (String? value) {
              //                       if (value!.isNotEmpty) {
              //                         return null;
              //                       } else {
              //                         return 'required'.tr;
              //                       }
              //                     },
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(top: 10),
              //                   child: TextFieldThem.buildTextField(
              //                     title: 'password'.tr,
              //                     labelText: 'password'.tr,
              //                     controller: _passwordController,
              //                     textInputType: TextInputType.text,
              //                     icon: Icons.lock_outline,
              //                     maxLength: 40,
              //                     obscureText: false,
              //                     contentPadding: EdgeInsets.zero,
              //                     validators: (String? value) {
              //                       if (value!.length >= 6) {
              //                         return null;
              //                       } else {
              //                         return 'Password required at least 6 characters'.tr;
              //                       }
              //                     },
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(top: 10),
              //                   child: TextFieldThem.buildTextField(
              //                     title: 'conform_password'.tr,
              //                     labelText: 'conform_password'.tr,
              //                     controller: _conformPasswordController,
              //                     textInputType: TextInputType.text,
              //                     icon: Icons.lock_outline,
              //                     maxLength: 40,
              //                     obscureText: false,
              //                     contentPadding: EdgeInsets.zero,
              //                     validators: (String? value) {
              //                       if (_passwordController.text != value) {
              //                         return 'Conform password is invalid'.tr;
              //                       } else {
              //                         return null;
              //                       }
              //                     },
              //                   ),
              //                 ),
              //                 Padding(
              //                     padding: const EdgeInsets.only(top: 50),
              //                     child: ButtonThem.buildButton(
              //                       context,
              //                       title: 'send'.tr,
              //                       btnHeight: 45,
              //                       btnColor: ConstantColors.blue,
              //                       txtColor: Colors.white,
              //                       onPress: () async {
              //                         if (_formKey.currentState!.validate()) {
              //                           Map<String, String> bodyParams = {
              //                             'firstname': _firstNameController.text.trim().toString(),
              //                             'phone': _phoneController.text.trim(),
              //                             'email': _emailController.text.trim(),
              //                             'password': _passwordController.text,
              //                             'address': _addressController.text,
              //                             'login_type': 'phone',
              //                             'tonotify': 'yes',
              //                             'account_type': 'driver',
              //                             'age': "25",
              //                           };
              //                           await controller.signUp(bodyParams).then((value) async {
              //                             if (value != null) {
              //                               if (value.success == "success") {
              //                                 Preferences.setInt(Preferences.userId, value.userData!.id!);
              //                                 Preferences.setString(Preferences.user, jsonEncode(value));
              //                                 await Preferences.setUserData(value);
              //                                 Get.to(VehicleInfoScreen());
              //                               } else {
              //                                 ShowToastDialog.showToast(value.error!);
              //                               }
              //                             }
              //                           });
              //                         }
              //                       },
              //                     )),
              //                 Padding(
              //                     padding: const EdgeInsets.only(top: 15),
              //                     child: ButtonThem.buildButton(
              //                       context,
              //                       title: 'already_register'.tr,
              //                       btnHeight: 45,
              //                       btnColor: ConstantColors.yellow,
              //                       txtColor: Colors.black,
              //                       onPress: () {
              //                         Get.back();
              //                       },
              //                     )),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
