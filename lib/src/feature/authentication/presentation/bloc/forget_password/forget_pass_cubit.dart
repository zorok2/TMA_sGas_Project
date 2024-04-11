import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sgas/core/config/routes/route_path.dart';
import 'package:sgas/core/error/failure.dart';
import 'package:sgas/core/utils/helper/logger_helper.dart';
import 'package:sgas/core/utils/helper/pattern_regex_helper.dart';
import 'package:sgas/src/base/validation_layer/presentation/page/disconnect_page.dart';
import 'package:sgas/src/feature/authentication/data/models/forget_params.dart';
import 'package:sgas/src/feature/authentication/domain/failure/failure.dart';
import 'package:sgas/src/feature/authentication/domain/usecases/authenticaion_usecase.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/forget_pass_state.dart';
import 'package:sgas/src/common/utils/constant/global_key.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit() : super(InitialForgetState());
  final _useCase = AuthenticationUseCase();

  Future<void> forgetPassword(String username, String phoneNumber) async {
    if (username.isEmpty) {
      emit(InvalidForgetUsernameState(message: "bạn chưa nhập tên đăng nhập"));
    } else if (username.length < 6) {
      emit(InvalidForgetUsernameState(
          message: "Tên đăng nhập không nhỏ hơn 6 kí tự"));
    } else if (phoneNumber.isEmpty) {
      emit(InvalidForgetPhoneNumberState(
          message: "bạn chưa nhập số điện thoại"));
    } else if (phoneNumberRegex.hasMatch(phoneNumber) == false) {
      emit(InvalidForgetPhoneNumberState(
          message: "Số điện thoại phải có 10 kí tự"));
    } else {
      logger.d("forget");

      emit(InitialForgetState());
      ForgetParams params =
          ForgetParams(username: username, phone: phoneNumber);
      var result = await _useCase.forgetPassword(params);

      if (result.isLeft) {
        logger.d("forget 2 ${result.left} ");

        if (result.left is NotFoundFailure) {
          emit(InvalidForgetUsernameState(
              message: "Không tìm thấy tài khoản này"));
        } else if (result.left is OverRequestForgetPasswordFailure) {
          var overReqMessage = result.left as OverRequestForgetPasswordFailure;
          emit(
              InvalidForgetPhoneNumberState(message: "${overReqMessage.data}"));
        } else if (result.left is NotExistPhoneFailure) {
          emit(InvalidForgetPhoneNumberState(
              message: "Số điện thoại không chính xác"));
        } else {
          logger.d("disconnect forget");
          emit(InitialForgetState());
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => DisconnectPage(),
          ));

          return;
        }
      }
      if (result.isRight) {
        emit(ValidatedForgetState());
        navigatorKey.currentState?.pushNamed(RoutePath.receiveOTP,
            arguments: {"username": username, "phone": phoneNumber});
      }
    }
  }
}
