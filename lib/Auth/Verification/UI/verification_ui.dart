import 'dart:async';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cabira/Auth/AddMoney/UI/add_money_page.dart';
import 'package:cabira/Auth/login_navigator.dart';
import 'package:cabira/BookRide/search_location_page.dart';
import 'package:cabira/utils/ApiBaseHelper.dart';
import 'package:cabira/utils/Session.dart';
import 'package:cabira/utils/common.dart';
import 'package:cabira/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:cabira/Components/custom_button.dart';
import 'package:cabira/Components/entry_field.dart';
import 'package:cabira/Locale/strings_enum.dart';
import 'verification_interactor.dart';
import 'package:cabira/Locale/locale.dart';

class VerificationUI extends StatefulWidget {
  final VerificationInteractor verificationInteractor;
  String mobile,otp;


  VerificationUI(this.verificationInteractor, this.mobile, this.otp);

  @override
  _VerificationUIState createState() => _VerificationUIState();
}

class _VerificationUIState extends State<VerificationUI> {
  final TextEditingController _otpController =
      TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: FadedSlideAnimation(
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Container(
                color: Color(0xff2CC8DE),
                height: MediaQuery.of(context).size.height + 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppBar(),
                    SizedBox(height: 12,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        getTranslated(context,'ENTER')! +
                            '\n' +
                            getTranslated(context,'VER_CODE')!,
                        style: theme.textTheme.headline4,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        getTranslated(context,'ENTER_CODE_WE')!,
                        style: theme.textTheme.bodyText2!
                            .copyWith(color: theme.hintColor, fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 12,),
                    Expanded(
                      child: Container(
                        height: 500,
                        color: theme.backgroundColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Spacer(),
                            EntryField(
                              keyboardType: TextInputType.phone,
                              maxLength: 4,
                              controller: _otpController,
                              label: getTranslated(context,'ENTER_6_DIGIT').toString()+" ${widget.otp}",
                            ),
                            Spacer(flex: 5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            !loading?Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: getTranslated(context,'NOT_RECEIVED'),
                    onTap: () => widget.verificationInteractor.notReceived(),
                    color: theme.scaffoldBackgroundColor,
                    textColor: theme.primaryColor,
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    onTap: (){
                      if(_otpController.text==""||_otpController.text.length!=4){
                        setSnackbar("Please Enter Valid Otp", context);
                        return ;
                      }
                      if(_otpController.text!=widget.otp){
                        setSnackbar("Wrong Otp", context);
                        return ;
                      }
                      setState(() {
                        loading =true;
                      });
                      loginUser();
                    },
                  ),
                ),
              ],
            ):Container(
                width: 50,
                child: Center(child: CircularProgressIndicator())),
          ],
        ),
        beginOffset: Offset(0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
      ),
    );
  }
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;
  loginUser() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_phone": widget.mobile.trim().toString(),
          "otp": widget.otp.toString(),
        };
        Map response =
        await apiBase.postAPICall(Uri.parse(baseUrl + "login"), data);
        print(response);
        bool status = true;
        String msg = response['message'];
        setState(() {
          loading = false;
        });
        setSnackbar(msg, context);
        if(response['status']){
          App.localStorage.setString("userId", response['data']['id'].toString());
          curUserId = response['data']['id'].toString();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> SearchLocationPage()), (route) => false);
        }else{
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, "WRONG")!, context);
        setState(() {
          loading = false;
        });
      }
    } else {
      setSnackbar(getTranslated(context, "NO_INTERNET")!, context);
      setState(() {
        loading = false;
      });
    }
  }
}
