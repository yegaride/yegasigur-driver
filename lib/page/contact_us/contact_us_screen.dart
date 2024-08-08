// ignore_for_file: library_private_types_in_public_api
import 'package:cabme_driver/constant/constant.dart';
import 'package:cabme_driver/themes/constant_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'Contact Us',
        onPressed: () {
          String url = 'tel:${Constant.contactUsPhone}';
          launchUrl(Uri.parse(url));
        },
        backgroundColor: ConstantColors.primary,
        child: const Icon(
          CupertinoIcons.phone_solid,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: <Widget>[
          Material(
            elevation: 2,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/appIcon.png', width: 100),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16.0, left: 16, top: 24),
                  child: Text(
                    'YegaSigur.com',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    right: 16.0,
                    left: 8,
                    top: 8,
                    bottom: 16,
                  ),
                  child: Text(
                    'Rooi bosai 47 c,\nSta Cruz,\nAruba',
                    // Constant.contactUsAddress!.replaceAll(r'\n', '\n'),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Email Us'.tr,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    Constant.contactUsEmail.toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      String url = 'mailto: ${Constant.contactUsEmail}';
                      launchUrl(Uri.parse(url));
                    },
                    child: const Icon(
                      CupertinoIcons.chevron_forward,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
