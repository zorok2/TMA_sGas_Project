import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sgas/core/config/http/http_override_config.dart';
import 'package:sgas/core/config/presentation/orientation_config.dart';
import 'package:sgas/core/di/dependency_config.dart';
import 'package:sgas/core/config/routes/route_path.dart';
import 'package:sgas/core/config/routes/route.dart';
import 'package:sgas/src/authentication/data/datasources/authentication_datasource.dart';
import 'package:sgas/src/authentication/presentation/bloc/forget_password/change_password_cubit.dart';
import 'package:sgas/src/authentication/presentation/bloc/forget_password/forget_pass_cubit.dart';
import 'package:sgas/src/authentication/presentation/bloc/login/login_cubit.dart';
import 'package:sgas/src/authentication/presentation/bloc/forget_password/otp_cubit.dart';
import 'package:sgas/src/common/utils/contant/global_key.dart';

void main() {
  setOrientations();

  HttpOverrides.global = CustomHttpOverrides();

  configDependencies();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'sGAS',
      onGenerateRoute: appRoute,
      initialRoute: RoutePath.login,
    );
  }
}
