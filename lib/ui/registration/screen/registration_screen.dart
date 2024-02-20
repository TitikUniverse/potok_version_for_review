import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:potok/navigation/routes.dart';
import 'package:potok/resources/resource_string.dart';
import 'package:potok/ui/registration/state/registration_controller.dart';

import '../../../theme/potok_theme.dart';
import '../../../utils/validator.dart';
import '../../authentication/component/eula_text.dart';
import '../../widgets/shackbar/snackbar.dart';

class RegistrationScreenStepOne extends StatefulWidget {
  const RegistrationScreenStepOne({Key? key}) : super(key: key);

  @override
  State<RegistrationScreenStepOne> createState() => _RegistrationScreenStepOneState();
}

class _RegistrationScreenStepOneState extends State<RegistrationScreenStepOne> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;

  Future _next() async {
    if (_formKey.currentState?.validate() == false) return;
    var nickname = _nicknameController.text.trim();
    var doesUserExist = await Get.find<RegistrationController>().doesUserExist(context, nickname);
    if (doesUserExist == false) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreenStepTwo(nickname: nickname)));
    }
  }

  @override
  void initState() {
    _nicknameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var theme = PotokTheme.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25.0),
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                width: double.infinity,
                height: 400.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ResourceString.comeUpWithUsername,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        color: theme.textColor
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          // keyboardAppearance: Brightness.dark,
                          showCursor: true,
                          cursorColor: theme.textColor,
                          controller: _nicknameController,
                          autofocus: false,
                          style: TextStyle(
                            color: theme.textColor
                          ),
                          maxLength: 30,
                          validator: usernameValidator,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.frontColor,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(
                                width: 0,
                                color: Colors.transparent
                              )
                            ),
                            counterStyle: TextStyle(
                              color: theme.textColor
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(
                                width: 0,
                                color: Colors.transparent
                              )
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(
                                width: 0,
                                color: Colors.transparent
                              )
                            ),
                            labelStyle: TextStyle(
                              color: theme.textColor.withOpacity(.5)
                            ),
                            hintStyle: TextStyle(
                              color: theme.textColor.withOpacity(.5)
                            ),
                            labelText: ResourceString.username,
                            hintText: ResourceString.username,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    GetBuilder<RegistrationController>(
                      builder: (controller) {
                        return SizedBox(
                          width: 200,
                          child: TextButton(
                            onPressed: _next,
                            child: controller.isLoading == false ? Text(
                              ResourceString.next,
                              style: const TextStyle(color: Colors.white, fontSize: 15.0),
                            )
                            : SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: theme.backgroundColor,
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.frontColor),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ), 
                              padding: const EdgeInsets.all(16),
                              backgroundColor: theme.brandColor,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 16.0,),
                    TextButton(
                      onPressed: () {
                        context.push(NavigationRoutesString.login);
                      }, 
                      child: Text(
                        ResourceString.alreadyHaveAccount,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: theme.textColor
                        ),
                      )
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: size.width*0.8,
                margin: EdgeInsets.symmetric(horizontal: size.width*0.1, vertical: 16.0),
                child: const EulaText()
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationScreenStepTwo extends StatefulWidget {
  const RegistrationScreenStepTwo({Key? key, required this.nickname}) : super(key: key);

  final String nickname;

  @override
  State<RegistrationScreenStepTwo> createState() => _RegistrationScreenStepTwoState();
}

class _RegistrationScreenStepTwoState extends State<RegistrationScreenStepTwo> {
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;

  final _formKey = GlobalKey<FormState>();

  Future _registerUser() async {
    if (_formKey.currentState?.validate() == false) return;
    Get.find<RegistrationController>().register(context, widget.nickname, _passwordController.text);
  }

  @override
  void initState() {
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var theme = PotokTheme.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25.0),
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                width: double.infinity,
                height: 400.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: GetBuilder<RegistrationController>(
                  builder: (controller) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ResourceString.comeUpWithPassword,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.0,
                              color: theme.textColor
                            ),
                          ),
                          const SizedBox(height: 25.0),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: TextFormField(
                                  // keyboardAppearance: Brightness.dark,
                                  showCursor: true,
                                  cursorColor: theme.textColor,
                                  controller: _passwordController,
                                  autofocus: false,
                                  obscureText: controller.passIsHidden,
                                  style: TextStyle(
                                    color: theme.textColor
                                  ),
                                  validator: passwordValidator,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: theme.frontColor,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        color: Colors.transparent
                                      )
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        color: Colors.transparent
                                      )
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        color: Colors.transparent
                                      )
                                    ),
                                    labelStyle: TextStyle(
                                      color: theme.textColor.withOpacity(.5)
                                    ),
                                    hintStyle: TextStyle(
                                      color: theme.textColor.withOpacity(.5)
                                    ),
                                    labelText: ResourceString.password,
                                    hintText: ResourceString.password,
                                    suffixIcon: IconButton(
                                      padding: const EdgeInsetsDirectional.only(end: 12.0),
                                      onPressed: () => controller.changePassVisible(),
                                      splashColor: Colors.transparent,
                                      icon: Icon(
                                        controller.passIsHidden
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        size: 25,
                                        color: theme.textColor.withOpacity(.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10.0,),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: TextFormField(
                                  // keyboardAppearance: Brightness.dark,
                                  showCursor: true,
                                  cursorColor: theme.textColor,
                                  controller: _passwordConfirmController,
                                  autofocus: false,
                                  obscureText: controller.passIsHidden,
                                  style: TextStyle(
                                    color: theme.textColor
                                  ),
                                  validator: passwordValidator,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: theme.frontColor,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        color: Colors.transparent
                                      )
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        color: Colors.transparent
                                      )
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        color: Colors.transparent
                                      )
                                    ),
                                    labelStyle: TextStyle(
                                      color: theme.textColor.withOpacity(.5)
                                    ),
                                    hintStyle: TextStyle(
                                      color: theme.textColor.withOpacity(.5)
                                    ),
                                    labelText: ResourceString.confirmPassword,
                                    hintText: ResourceString.confirmPassword,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  ResourceString.back,
                                  style: const TextStyle(color: Colors.white, fontSize: 15.0),
                                ),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ), 
                                  padding: const EdgeInsets.all(14),
                                  backgroundColor: theme.textColor.withOpacity(.4),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (_passwordController.text != _passwordConfirmController.text) {
                                    PotokSnackbar.failure(context, title: ResourceString.error, message: ResourceString.passwordsDontMatch);
                                  }
                                  else {
                                    if (!controller.isLoading) _registerUser();
                                  }
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreenStepThree()));
                                },
                                child: !controller.isLoading ? Text(
                                  ResourceString.next,
                                  style: const TextStyle(color: Colors.white, fontSize: 15.0),
                                )
                                : SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator.adaptive(
                                    backgroundColor: theme.backgroundColor,
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(theme.frontColor),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ), 
                                  padding: const EdgeInsets.all(14),
                                  backgroundColor: theme.brandColor,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    );
                  }
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: size.width*0.8,
                margin: EdgeInsets.symmetric(horizontal: size.width*0.1, vertical: 16.0),
                child: const EulaText()
              )
            ],
          ),
        ),
      ),
    );
  }
}

// class RegistrationScreenStepThree extends StatefulWidget {
//   const RegistrationScreenStepThree({Key? key}) : super(key: key);

//   @override
//   State<RegistrationScreenStepThree> createState() => _RegistrationScreenStepThreeState();
// }

// class _RegistrationScreenStepThreeState extends State<RegistrationScreenStepThree> {
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     var theme = PotokTheme.of(context);
    
//     return Scaffold(
//       backgroundColor: Constant.backgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const Spacer(),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 25.0),
//               padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
//               width: double.infinity,
//               height: 400.0,
//               decoration: BoxDecoration(
//                 color: Constant.frontColor,
//                 borderRadius: BorderRadius.circular(25.0),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     offset: Offset(0, 3),
//                     blurRadius: 8.0,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Номер телефона",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 24.0
//                     ),
//                   ),
//                   const SizedBox(height: 25.0),
//                   SizedBox(
//                     // padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     width: 240,
//                     child: InternationalPhoneNumberInput(
//                       selectorConfig: const SelectorConfig(
//                         selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
//                         leadingPadding: 8.0,
//                         setSelectorButtonAsPrefixIcon: true,
//                         trailingSpace: true,
//                         useEmoji: true
//                       ),
//                       initialValue: PhoneNumber(
//                         isoCode: 'RU'
//                       ),
//                       maxLength: 11,
//                       countries: const ['RU'],
//                       autoValidateMode: AutovalidateMode.always,
//                       hintText: 'Номер телефона',
//                       errorMessage: 'Неправильный номер телефона',
//                       inputBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25.0)
//                       ), 
//                       onInputChanged: (PhoneNumber value) { },
//                     ),
//                   ),
//                   const SizedBox(height: 10.0),
//                   OutlinedButton(
//                     onPressed: () {
//                       // Navigator.pushNamed(context, '/feed');
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(
//                         width: 0.5
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15.0)
//                       )
//                     ),
//                     child: const Text(
//                       "Далее",
//                       style: TextStyle(
//                         fontSize: 16.0,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Spacer(),
//             Container(
//               alignment: Alignment.center,
//               width: size.width*0.8,
//               margin: EdgeInsets.symmetric(horizontal: size.width*0.1, vertical: 16.0),
//               child: Wrap(
//                 crossAxisAlignment: WrapCrossAlignment.center,
//                 alignment: WrapAlignment.center,
//                 children: [
//                   Text('Нажимая «Войти», вы принимаете',
//                   textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Constant.secondaryColor,
//                       fontSize: 14,
//                     ),
//                     softWrap: true,
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       String url = 'https://potok.online/ru/termsofuse.html';
//                       if (await canLaunchUrl(Uri.parse(url))) {
//                         await launchUrl(
//                           Uri.parse(url)
//                         ); // Android
//                       } else {
//                         showTopSnackBar(
//                           Overlay.of(context),
//                           const CustomSnackBar.error(message: "Не удаётся открыть"),
//                           dismissType: DismissType.onSwipe
//                         );
//                       }
//                     },
//                     child: const Text(
//                       'пользовательское соглашение',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white60,
//                         fontSize: 14,
//                         decoration: TextDecoration.underline
//                       ),
//                     ),
//                   ),
//                   Text(' и ',
//                   textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Constant.secondaryColor,
//                       fontSize: 14,
//                     ),
//                     softWrap: true,
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       String url = 'https://potok.online/ru/privacy.html';
//                       if (await canLaunchUrl(Uri.parse(url))) {
//                         await launchUrl(
//                           Uri.parse(url)
//                         ); // Android
//                       } else {
//                         showTopSnackBar(
//                           Overlay.of(context),
//                           const CustomSnackBar.error(message: "Не удаётся открыть"),
//                           dismissType: DismissType.onSwipe
//                         );
//                       }
//                     },
//                     child: const Text(
//                       'политику конфиденциальности',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white60,
//                         fontSize: 14,
//                         decoration: TextDecoration.underline
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }