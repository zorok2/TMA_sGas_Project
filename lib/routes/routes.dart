import 'package:flutter/material.dart';
import 'package:sgas/routes/route_path.dart';
import 'package:sgas/src/authentication/view/page/authentication_page.dart';
import 'package:sgas/src/authentication/view/page/change_new_password_page.dart';
import 'package:sgas/src/authentication/view/page/forgot_password_page.dart';
import 'package:sgas/src/authentication/view/page/home_page.dart';
import 'package:sgas/src/authentication/view/page/recieve_otp_page.dart';
import 'package:sgas/src/authentication/view/page/wrapper_page.dart';

Map<String, WidgetBuilder> routes = {
  RoutePath.wrapper: (context) => const Wrapper(),
  RoutePath.login: (context) => const AuthenticationPage(),
  RoutePath.forgotPassword: (context) => const ForgotPasswordPage(),
  RoutePath.recieveOtp: (context) => const RecieveOTPPage(),
  RoutePath.home: (context) => const HomePage(),
  RoutePath.changeNewPassword: (context) => const ChangeNewPasswordPage(),
};
