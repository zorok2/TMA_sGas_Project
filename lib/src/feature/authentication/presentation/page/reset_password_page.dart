import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sgas/core/config/dependency/dependency_config.dart';
import 'package:sgas/core/config/route/route_path.dart';
import 'package:sgas/core/ui/resource/icon_path.dart';
import 'package:sgas/generated/l10n.dart';
import 'package:sgas/src/common/presentation/widget/button/common_button.dart';
import 'package:sgas/src/common/presentation/widget/validation/validate_password.dart';
import 'package:sgas/src/common/utils/controller/loading_controller.dart';
import 'package:sgas/src/common/utils/helper/logger_helper.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/otp_cubit.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/otp_state.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/reset_password_cubit.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/reset_password_state.dart';
import 'package:sgas/src/common/presentation/widget/text_field/common_textfield.dart';
import 'package:sgas/src/feature/authentication/presentation/page/login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  bool isValidPassword = false;
  bool isHiddenPassword = true;
  bool isHiddenRePassword = true;
  late CorrectOtp data;

  @override
  void initState() {
    super.initState();
    data = getIt<OtpCubit>().state as CorrectOtp;
    logger.d("reset $data");
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              ModalRoute.withName(RoutePath.login),
            );
          },
        ),
        title: Text(S.current.txt_change_password),
      ),
      body: BlocBuilder<SetPasswordCubit, ResetPasswordState>(
        bloc: getIt.get<SetPasswordCubit>(),
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox.expand(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    TextFieldCommon(
                      label: S.current.txt_password,
                      controller: _passwordController,
                      hintText: S.current.txt_enter_password,
                      isHidden: isHiddenPassword,
                      onChange: (value) {
                        _handleOnChange(value);
                      },
                      suffixIcon: IconButton(
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            isHiddenPassword = !isHiddenPassword;
                          });
                        },
                        icon: SvgPicture.asset(
                          (isHiddenPassword)
                              ? IconPath.showPassword
                              : IconPath.hidePassword,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFieldCommon(
                      label: S.current.txt_confirm_password,
                      onChange: (value) {
                        getIt
                            .get<SetPasswordCubit>()
                            .changeState(InitialResetPassWord());
                      },
                      controller: _rePasswordController,
                      hintText: S.current.txt_re_enter_password,
                      messageError: (state is InValidReEnterPassword)
                          ? state.message
                          : null,
                      isHidden: isHiddenRePassword,
                      suffixIcon: IconButton(
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            isHiddenRePassword = !isHiddenRePassword;
                          });
                        },
                        icon: SvgPicture.asset(
                          (isHiddenRePassword)
                              ? IconPath.showPassword
                              : IconPath.hidePassword,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ValidatePassword(isValidPassword: isValidPassword),
                    const SizedBox(
                      height: 24,
                    ),
                    CommonButton(
                      buttonTitle: S.current.btn_confirm,
                      onPress: (isValidPassword)
                          ? () async {
                              getIt<LoadingController>().start(context);
                              getIt.get<SetPasswordCubit>().updatePass(
                                  context: context,
                                  token: data.data,
                                  password: _passwordController.text,
                                  rePassword: _rePasswordController.text,
                                  username: data.username);
                              getIt<LoadingController>().close(context);
                            }
                          : null,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleOnChange(String value) {
    if (value.length < 8) {
      setState(() {
        isValidPassword = false;
      });
    } else {
      setState(() {
        isValidPassword = true;
      });
    }
  }
}
