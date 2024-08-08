// ignore_for_file: must_be_immutable

import 'package:cabme_driver/constant/constant.dart';
import 'package:cabme_driver/constant/show_toast_dialog.dart';
import 'package:cabme_driver/controller/bank_details_controller.dart';
import 'package:cabme_driver/themes/button_them.dart';
import 'package:cabme_driver/themes/constant_colors.dart';
import 'package:cabme_driver/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBankAccount extends StatefulWidget {
  const AddBankAccount({super.key, required this.isEdit});

  final bool isEdit;

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  State<AddBankAccount> createState() => _AddBankAccountState();
}

class _AddBankAccountState extends State<AddBankAccount> {
  var bankNameController = TextEditingController();

  String? _bankName;

  var branchNameController = TextEditingController();
  var holderNameController = TextEditingController();
  var accountNumberController = TextEditingController();
  var otherInformationController = TextEditingController();
  var ifscCodeController = TextEditingController();

  List<DropdownMenuItem> get _items {
    final List<String> arubaBanks = [
      'ARUBA BANK',
      'CARIBBEAN MERCANTILE BANK',
      'BANCO DI CARIBE',
      'RBC ROYAL BANK',
    ];

    return arubaBanks.map((bank) {
      return DropdownMenuItem(
        value: bank,
        child: Text(
          bank,
          style: const TextStyle(height: 1.8),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<BankDetailsController>(
      init: BankDetailsController(),
      initState: (state) {
        _bankName = state.controller!.bankDetails.value.bankName;
        bankNameController = TextEditingController(
          text: state.controller!.bankDetails.value.bankName,
        );
        branchNameController = TextEditingController(
          text: state.controller!.bankDetails.value.branchName,
        );
        holderNameController = TextEditingController(
          text: state.controller!.bankDetails.value.holderName,
        );
        accountNumberController = TextEditingController(
          text: state.controller!.bankDetails.value.accountNo,
        );
        otherInformationController = TextEditingController(
          text: state.controller!.bankDetails.value.otherInfo,
        );
        ifscCodeController = TextEditingController(
          text: state.controller!.bankDetails.value.ifscCode,
        );
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.background,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
            title: Text(
              widget.isEdit ? 'Edit bank'.tr : 'Add Bank'.tr,
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: ConstantColors.background,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Form(
                      key: AddBankAccount._formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank Name'.tr,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: DropdownButtonFormField(
                              key: const Key('bankName'),
                              items: _items,
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.only(left: 8),
                              ),
                              onChanged: (value) {
                                _bankName = value;
                              },
                              value: _bankName,
                              hint: Text(
                                // TODO i18n
                                '-- Select a bank name --'.tr,
                                style: const TextStyle(height: 1.8),
                              ),
                              validator: (_) {
                                if (_bankName == null) {
                                  return 'required'.tr;
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Text(
                              'Holder Name'.tr,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: holderNameController,
                              keyboardType: TextInputType.text,
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Text(
                              'Account Number'.tr,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: accountNumberController,
                              keyboardType: TextInputType.text,
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Text(
                              'IFSC Code'.tr,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: ifscCodeController,
                              keyboardType: TextInputType.text,
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Text(
                              // TODO i18n
                              'Other information  (optional)'.tr,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: otherInformationController,
                              keyboardType: TextInputType.text,
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 45),
                              child: ButtonThem.buildButton(
                                context,
                                btnHeight: 44,
                                title: widget.isEdit ? "Edit bank".tr : "Add bank".tr,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.black,
                                onPress: () {
                                  if (AddBankAccount._formKey.currentState!.validate()) {
                                    Map<String, String> bodyParams = {
                                      'driver_id': Preferences.getInt(Preferences.userId).toString(),
                                      'bank_name': _bankName!,
                                      'branch_name': branchNameController.text,
                                      'holder_name': holderNameController.text,
                                      'account_no': accountNumberController.text,
                                      'information': otherInformationController.text,
                                      'ifsc_code': ifscCodeController.text,
                                    };

                                    controller.setBankDetails(bodyParams).then((value) {
                                      if (value != null) {
                                        Get.back(result: true);
                                      } else {
                                        ShowToastDialog.showToast(
                                          "Something want wrong.".tr,
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
