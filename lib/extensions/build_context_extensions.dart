part of 'extensions.dart';

extension BuildContextExtensions on BuildContext {
  String? requiredValidator(String? value) {
    if (value!.isNotEmpty) {
      return null;
    } else {
      return "required".tr;
    }
  }

  ThemeData get theme => Theme.of(this);
}
