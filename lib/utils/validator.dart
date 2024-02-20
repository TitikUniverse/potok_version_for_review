import 'package:email_validator/email_validator.dart';

import '../resources/resource_string.dart';

RegExp phone = RegExp(r'^((\+7|8)+(\d){10})$');
RegExp _number = RegExp(r'^\d+$');
RegExp cyrillic = RegExp(r'[а-яА-ЯёЁ]');
RegExp filterDate =
    RegExp(r'^(0[1-9]|[12]\d|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$');
RegExp fullName = RegExp(r'^[\p{L} -]*$',
    caseSensitive: false, unicode: true, dotAll: true);

// MaskTextInputFormatter get maskFormatter => MaskTextInputFormatter(
//     mask: defaultCountryPhone.mask, filter: {'#': RegExp(r'\d')});

// CountryPhone defaultCountryPhone = const CountryPhone(
//     code: '+7', mask: '+7 ### ###-##-##', country: 'Российская Федерация');

String? emailAndPhoneValidator(String? userInput) {
  if ((userInput ?? '').isEmpty) {
    return ResourceString.errorInvalidUsername;
  } else {
    var hasCyrillic = userInput!.contains(cyrillic);
    var isValidEmail = EmailValidator.validate(userInput);
    if (!isValidEmail || hasCyrillic) {
      if (!phone.hasMatch(userInput)) {
        return ResourceString.errorInvalidUsername;
      }
      return null;
    } else {
      return null;
    }
  }
}

String? emailValidator(String? email) {
  if ((email ?? '').isEmpty) {
    return ResourceString.errorEnterCorrectEmail;
  } else {
    var hasCyrillic = email!.contains(cyrillic);
    var isValidEmail = EmailValidator.validate(email);
    if (!isValidEmail || hasCyrillic) {
      return ResourceString.errorEnterCorrectEmail;
    } else {
      return null;
    }
  }
}

String? usernameValidator(String? username) {
  if ((username ?? '').isEmpty) {
    return ResourceString.errorEmptyField;
  } else {
    var valid = RegExp(r'^[A-Za-z0-9_.]*$').hasMatch(username!);
    var hasCyrillic = username.contains(cyrillic);
    if (hasCyrillic) {
      return ResourceString.errorInvalidUsername;
    } else if (valid) {
      return null;
    } else {
      return ResourceString.errorEnterCorrectUsername;
    }
  }
}

String? passwordValidator(String? password, [int minLength = 8]) {
  if ((password ?? '').isNotEmpty == true && password!.length >= minLength) {
    var hasCyrillic = password.contains(cyrillic);
    var hasUppercase = password.contains(RegExp(r'[A-Z]'));
    if (hasUppercase && !hasCyrillic) {
      var hasDigits = password.contains(RegExp(r'[0-9]'));
      var hasSpecialCharacters =
          password.contains(RegExp(r'[!@±§\/№%;#$%^&*(),.?":{}|<>]'));
      if (hasDigits || hasSpecialCharacters) {
        var hasLowercase = password.contains(RegExp(r'[a-z]'));
        if (hasLowercase) {
          return null;
        }
      }
    }
    return ResourceString.errorInvalidPassword;
  }
  return ResourceString.errorInvalidPassword;
}

String? lightPasswordValidator(String? password, [int minLength = 6]) {
  if (password != null) {
    var hasCyrillic = password.contains(cyrillic);
    if (password.isEmpty) {
      return ResourceString.errorEmptyField;
    } else if (password.length < minLength) {
      return ResourceString.errorInvalidPassword;
    } else if (hasCyrillic) {
      return ResourceString.errorInvalidPassword;
    } else {
      return null;
    }
  } else {
    return ResourceString.errorInvalidPassword;
  }
}

// String? codeValidator(String? code) {
//   if ((code ?? '').isEmpty) {
//     return ResourceString.errorCode;
//   } else {
//     if (!_number.hasMatch(code!)) {
//       return ResourceString.errorCode;
//     } else {
//       return null;
//     }
//   }
// }
