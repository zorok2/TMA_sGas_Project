import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sgas/core/config/dependency/dependency_config.dart';
import 'package:sgas/core/ui/style/base_text_style.dart';
import 'package:sgas/generated/l10n.dart';
import 'package:sgas/src/common/util/constant/screen_size_constaint.dart';
import 'package:sgas/src/common/util/controller/loading_controller.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/forget_password_cubit.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/forget_password_state.dart';
import 'package:sgas/src/feature/authentication/presentation/widget/alert_message_otp.dart';
import 'package:sgas/src/feature/authentication/presentation/widget/notification_header.dart';
import 'package:sgas/core/ui/style/base_color.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/otp_cubit.dart';
import 'package:sgas/src/feature/authentication/presentation/bloc/forget_password/otp_state.dart';
import 'package:sgas/src/common/util/helper/hide_phone_number.dart';
import 'package:sgas/src/common/presentation/widget/button/common_button.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({
    super.key,
  });

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  String otp = '';

  @override
  void initState() {
    getIt.get<OtpCubit>().changeState(InitialOtp());
    focusNodes[0].requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void clearOtp() {
    for (var element in controllers) {
      element.clear();
    }
    focusNodes[0].requestFocus();
    otp = "";
  }

  void updateOtp() {
    otp = "";
    for (var i = 0; i < controllers.length; i++) {
      otp += controllers[i].text;
    }
  }

  Future<void> _sendOTP(BuildContext context) async {
    getIt<LoadingController>().start(context);
    await getIt
        .get<ForgetPasswordCubit>()
        .sentOTP(otp)
        .whenComplete(() => getIt<LoadingController>().close(context));
    clearOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            getIt.get<ForgetPasswordCubit>().changeState(ForgetScreenState());
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(S.current.txt_enter_otp),
      ),
      body: SizedBox.expand(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > ScreenSizeConstant.minTabletWidth) {
            return Column(
              children: [
                const Spacer(flex: 2),
                Text(
                    "${S.current.txt_otp_sent_to_phone} ${hidePhoneNumber(getIt.get<ForgetPasswordCubit>().phone!)}",
                    style: BaseTextStyle.body1()),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _otpFormField(context),
                      const SizedBox(height: 16),
                      const AlertMessageOTP(),
                      const SizedBox(height: 24),
                      BlocBuilder<OtpCubit, OtpState>(
                        bloc: getIt.get<OtpCubit>(),
                        builder: (context, state) {
                          if (state is TimeOutOtp) {
                            return CommonButton(
                              text: S.current.btn_re_send_otp,
                              onPress: () async {
                                getIt<LoadingController>().start(context);
                                await getIt.get<OtpCubit>().reSendOtp(
                                    username: getIt
                                        .get<ForgetPasswordCubit>()
                                        .username!,
                                    phone: getIt
                                        .get<ForgetPasswordCubit>()
                                        .phone!);
                                // ignore: use_build_context_synchronously
                                getIt<LoadingController>().close(context);
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(
                  flex: 7,
                )
              ],
            );
          }
          return Column(
            children: [
              NotificationHeader(
                title:
                    // ignore: use_build_context_synchronously
                    "${S.current.txt_otp_sent_to_phone} ${hidePhoneNumber(getIt.get<ForgetPasswordCubit>().phone!)}",
              ),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _otpFormField(context),
                    const SizedBox(height: 16),
                    const AlertMessageOTP(),
                    const SizedBox(height: 24),
                    BlocBuilder<OtpCubit, OtpState>(
                      bloc: getIt.get<OtpCubit>(),
                      builder: (context, state) {
                        if (state is TimeOutOtp) {
                          return CommonButton(
                            text: S.current.btn_re_send_otp,
                            onPress: () async {
                              getIt<LoadingController>().start(context);
                              await getIt.get<OtpCubit>().reSendOtp(
                                  username: getIt
                                      .get<ForgetPasswordCubit>()
                                      .username!,
                                  phone:
                                      getIt.get<ForgetPasswordCubit>().phone!);
                              // ignore: use_build_context_synchronously
                              getIt<LoadingController>().close(context);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _otpFormField(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        height: 56,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.4),
              child: SizedBox(
                height: 56,
                width: 48,
                child: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  onChanged: (value) {
                    updateOtp();
                    if (value.isNotEmpty) {
                      if (index < controllers.length - 1) {
                        FocusScope.of(context)
                            .requestFocus(focusNodes[index + 1]);
                      } else {
                        _sendOTP(context);
                      }
                    } else if (value.isEmpty) {
                      controllers[index].clear();
                      if (index > 0) {
                        FocusScope.of(context)
                            .requestFocus(focusNodes[index - 1]);
                      }
                    }
                  },
                  decoration: InputDecoration(
                      counterText: '',
                      border: _outLineBorderCustom(),
                      focusedBorder: _outLineBorderCustom(),
                      enabledBorder: _outLineBorderCustom()),
                  cursorColor: BaseColor.textPrimaryColor,
                  cursorRadius: const Radius.circular(4),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  OutlineInputBorder _outLineBorderCustom() {
    return const OutlineInputBorder(
        borderSide: BorderSide(color: BaseColor.borderColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(8)));
  }
}
