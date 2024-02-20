import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/routes.dart';
import '../../../../resources/resource_string.dart';
import '../../../../theme/potok_theme.dart';
import '../../../../utils/validator.dart';
import '../component/eula_text.dart';
import '../state/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var theme = PotokTheme.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SizedBox.expand(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 400.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ResourceString.authSignIn,
                        style: TextStyle(
                          fontFamily: 'Leto Text Sans Defect',
                          fontSize: 32.0,
                          color: theme.textColor
                        ),
                      ),
                      const SizedBox(height: 32.0,),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                showCursor: true,
                                enableIMEPersonalizedLearning: false,
                                cursorColor: theme.brandColor,
                                controller: _usernameController,
                                autofocus: false,
                                style: TextStyle(
                                  color: theme.textColor
                                ),
                                validator: (value) => usernameValidator(value),
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
                                  labelText: ResourceString.username,
                                  hintText: ResourceString.username,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                              child: TextFormField(
                                // keyboardAppearance: Brightness.dark,
                                showCursor: true,
                                cursorColor: theme.textColor.withOpacity(.2),
                                controller: _passwordController,
                                autofocus: false,
                                obscureText: true,
                                style: TextStyle(
                                  color: theme.textColor
                                ),
                                validator: (value) => lightPasswordValidator(value, 6),
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
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            SizedBox(
                              width: 250,
                              child: GetBuilder<AuthController>(
                                builder: (controller) {
                                  return TextButton(
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() == false) return;
                                      if (controller.isLoading == false) controller.authenticate(context, nickname: _usernameController.text.trim(), password: _passwordController.text.trim());
                                    },
                                    child: controller.isLoading ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator.adaptive(),
                                    ) : Text(
                                      ResourceString.authSignIn,
                                      style: const TextStyle(color: Color(0xffffffff), fontSize: 15.0),
                                    ), 
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      backgroundColor: theme.textColor.withOpacity(.4),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                  );
                                }
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        width: 250,
                        child: TextButton(
                            onPressed: () {
                              GoRouter.of(context).push(NavigationRoutesString.registration);
                            },
                            child: Text(
                              ResourceString.authCreateNewAccount,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: const TextStyle(color: Color(0xffffffff), fontSize: 15.0),
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
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: size.width * 0.8,
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 16.0),
                  child: const EulaText()
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}