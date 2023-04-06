import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cabira/BookRide/finding_ride_page.dart';
import 'package:cabira/BookRide/map.dart';
import 'package:cabira/BookRide/search_location_page.dart';
import 'package:cabira/Model/my_ride_model.dart';
import 'package:cabira/Model/reason_model.dart';
import 'package:cabira/utils/ApiBaseHelper.dart';
import 'package:cabira/utils/PushNotificationService.dart';
import 'package:cabira/utils/Session.dart';
import 'package:cabira/utils/colors.dart';
import 'package:cabira/utils/common.dart';
import 'package:cabira/utils/constant.dart';
import 'package:cabira/utils/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cabira/Theme/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'rate_ride_dialog.dart';
import 'package:http/http.dart' as http;
class RideBookedPage extends StatefulWidget {
  MyRideModel model;

  RideBookedPage(this.model);

  @override
  _RideBookedPageState createState() => _RideBookedPageState();
}

class _RideBookedPageState extends State<RideBookedPage> {
  bool isOpened = false;
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool acceptStatus = false;
  List<ReasonModel> reasonList = [];
  bool change = false;
  getReason() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "type": "User",
        };
        Map response = await apiBase.postAPICall(
            Uri.parse(
                baseUrl1+"payment/cancel_ride_reason"),
            data);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        setSnackbar(msg, context);
        if (response['status']) {
          for(var v in response['data']){
            setState(() {
              reasonList.add(new ReasonModel.fromJson(v));
            });
          }
          //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> OfflinePage("")), (route) => false);
        } else {}
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      setSnackbar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }
  String totalTime = "0".toString();
  String distance = "0".toString();
  getTime1(lat1, lon1, lat2, lon2)async{
    if(lat1!=""&&lat1!=null&&lon1!=""&&lon1!=null&&lat2!=""&&lat2!=null&&lon2!=""&&lon2!=null) {
      print("check1");
      http.Response response = await http.get(Uri.parse(
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${lat1},${lon1}&destinations=${lat2},${lon2}&key=AIzaSyBmUCtQ_DlYKSU_BV7JdiyoOu1i4ybe-z0"));
      print(response.body);
      Map res = jsonDecode(response.body);
      List<dynamic> data = res['rows'][0]['elements'];
      //  String totalTime = "0 Mins".toString();
      if(response.body.contains("text")){
        totalTime =(int.parse(data[0]['duration']['value'].toString())/60).round().toString();
        distance = (double.parse(data[0]['distance']['value'].toString())/1000).toStringAsFixed(2);
      }
      print(totalTime);
      updateLocation(widget.model.bookingId.toString());
    }else{

    }

  }
  double calculateDistance(lat1, lon1, lat2, lon2) {
    try {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    } on Exception catch (exception) {
      return 0; // only executed if error is of type Exception
    } catch (error) {
      return 0; // executed for errors of all types other than Exception
    }
  }
  updateLocation(String bookingId,) async {
    await App.init();

    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_id": curUserId,
          "drop_address": widget.model.dropAddress,
          "booking_id": bookingId,
          "update_kilometer":widget.model.acceptReject=="6"?calculateDistance(double.parse(widget.model.latitude.toString()), double.parse(widget.model.longitude.toString()), driveLat, driveLng).toStringAsFixed(2):"0",
          "distance": distance,
          "drop_latitude": widget.model.dropLatitude,
          "drop_longitude": widget.model.dropLongitude,
          "taxi_id": widget.model.taxiId,
          "time": totalTime,
          "surge_amount": widget.model.surgeAmount,
        };
        print("this is our updated request **** ${data.toString()}");
        Map response = await apiBase.postAPICall(
            Uri.parse(
                baseUrl1+"Payment/update_change_location"),
            data);
        print("this is new updated response &&&&& ^^^^^^ ${response.toString()}");
        print(response);
        setState(() {
          acceptStatus = false;
        });
        bool status = true;
        String msg = response['message'];
        setSnackbar(msg, context);
        if (response['status']) {
          getCurrentInfo();
        } else {}
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      setSnackbar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }
  cancelStatus(String bookingId,status1) async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_id": curUserId,
          "accept_reject": "4",
          "booking_id": bookingId,
          "reason": reasonList[indexReason].reason,
        };
        print("this is our request @@ ${data.toString()} aand @@ ${baseUrl1}Payment/cancel_ride_point_to_point}");
        Map response = await apiBase.postAPICall(
            Uri.parse(
                baseUrl1+"Payment/cancel_ride_point_to_point"),
            data);
        print(response);
        print(response);
        setState(() {
          acceptStatus = false;
        });
        // bool status = true;
        String msg = response['message'];
        bool status = response['status'];
        setSnackbar(msg, context);
        if (status) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> SearchLocationPage()), (route) => false);
        } else {}
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      setSnackbar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  getCurrentInfo() async {
    try {
      setState(() {
        loading = true;
      });
      Map params = {
        "user_id": curUserId,
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/get_current_boooking"), params);
      setState(() {
        loading = false;
      });
      if (response['status']) {
        var v = response["data"];
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => RideBookedPage(MyRideModel.fromJson(v))));
        /* showConfirm(RidesModel(v['id'], v['user_id'], v['username'], v['uneaque_id'], v['purpose'], v['pickup_area'],
            v['pickup_date'], v['drop_area'], v['pickup_time'], v['area'], v['landmark'], v['pickup_address'], v['drop_address'],
            v['taxi_type'], v['departure_time'], v['departure_date'], v['return_date'], v['flight_number'], v['package'],
            v['promo_code'], v['distance'], v['amount'], v['paid_amount'], v['address'], v['transfer'], v['item_status'],
            v['transaction'], v['payment_media'], v['km'], v['timetype'], v['assigned_for'], v['is_paid_advance'], v['status'], v['latitude'], v['longitude'], v['date_added'],
            v['drop_latitude'], v['drop_longitude'], v['booking_type'], v['accept_reject'], v['created_date']));*/

        //print(data);
      } else {
        // setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, "WRONG")!, context);
      setState(() {
        change = true;
      });
    }
  }

  double lat= 0;
  double long = 0;
  @override
  void initState() {
    super.initState();
    PushNotificationService pushNotificationService = new PushNotificationService(context: context, onResult: (result){
      //if(mounted&&result=="yes")
      print("result" + result);
      if(result == "com"||result == "cancel"){

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>FindingRidePage( LatLng(latitude, longitude),
            LatLng(double.parse(widget.model.dropLatitude.toString()), double.parse(widget.model.dropLongitude.toString())),
            widget.model.pickupAddress.toString(), widget.model.dropAddress.toString(),
            widget.model.paymentMedia.toString(), widget.model.bookingId.toString(),  widget.model.amount.toString(),  widget.model.km.toString())), (route) => false);

        if(result == "com")
        showDialog(context: context, builder: (context) => RateRideDialog(widget.model));
      }else{
        getCurrentInfo();
      }
    });
    pushNotificationService.initialise();

    getReason();
  /*  Future.delayed(Duration(seconds: 2), () {
        showDialog(context: context, builder: (context) => RateRideDialog(widget.model));
    });*/
  }
  int indexReason = 0;
  PersistentBottomSheetController? persistentBottomSheetController1;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  showBottom1()async{
    persistentBottomSheetController1 = await scaffoldKey.currentState!.showBottomSheet((context) {
      return Container(
        decoration: boxDecoration(radius: 0,showShadow: true,color: Colors.white),
        padding: EdgeInsets.all(getWidth(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            boxHeight(20),
            text("${getTranslated(context, "SELECT_REASON")}",textColor: MyColorName.colorTextPrimary,fontSize: 12.sp,fontFamily: fontBold),
            boxHeight(20),
            reasonList.length>0?Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reasonList.length,
                  itemBuilder:(context, index) {
                    return  InkWell(
                      onTap: (){
                        persistentBottomSheetController1!.setState!((){
                          indexReason = index;
                        });
                        // Navigator.pop(context);
                      },
                      child: Container(
                        color: indexReason==index?MyColorName.primaryLite.withOpacity(0.2):Colors.white,
                        padding: EdgeInsets.all(getWidth(10)),
                        child: text(reasonList[index].reason.toString(),textColor: MyColorName.colorTextPrimary,fontSize: 10.sp,fontFamily: fontMedium,isLongText: true),
                      ),
                    );
                  }),
            ):SizedBox(),
            boxHeight(20),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: !acceptStatus?Container(
                    width: 35.w,
                    height: 5.h,
                    margin: EdgeInsets.all(getWidth(14)),
                    decoration: boxDecoration(
                        radius: 5,
                        bgColor: Theme.of(context)
                            .primaryColor),
                    child: Center(
                        child: text(getTranslated(context, "BACK")!,
                            fontFamily: fontMedium,
                            fontSize: 10.sp,
                            isCentered: true,
                            textColor: Colors.white)),
                  ):CircularProgressIndicator(),
                ),
                boxWidth(10),
                InkWell(
                  onTap: () {
                    persistentBottomSheetController1!.setState!(() {
                      acceptStatus = true;
                    });
                    cancelStatus(widget.model.bookingId!, "5");
                  },
                  child: !acceptStatus?Container(
                    width: 35.w,
                    height: 5.h,
                    margin: EdgeInsets.all(getWidth(14)),
                    decoration: boxDecoration(
                        radius: 5,
                        bgColor: Theme.of(context)
                            .primaryColor),
                    child: Center(
                        child: text(getTranslated(context, "CONTINUE")!,
                            fontFamily: fontMedium,
                            fontSize: 10.sp,
                            isCentered: true,
                            textColor: Colors.white)),
                  ):CircularProgressIndicator(),
                ),
              ],
            ),
            boxHeight(40),
          ],
        ),

      );
    });
  }
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return FadedSlideAnimation(
      Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
      //  appBar: AppBar(),
        body: SafeArea(
          child:   widget.model.latitude!=null&&widget.model.latitude!=""?Stack(
            alignment: Alignment.bottomCenter,
            children: [
              !loading?MapPage(
                true,
                driveList: [],
                live: true,
                pick: widget.model.pickupAddress.toString(),
                dest: widget.model.dropAddress.toString(),
                id: widget.model.driverId,
                carType: widget.model.taxiType=="Bike"?"1":"2",
                status1 :widget.model.acceptReject,
                SOURCE_LOCATION: LatLng(double.parse(widget.model.latitude!),double.parse(widget.model.longitude!)),
                // DEST_LOCATION: LatLng(double.parse(widget.model.dropLatitude.toString()),double.parse(widget.model.dropLongitude.toString())),
              ):Center(child: CircularProgressIndicator(),),
              Positioned(
                top: 0,
                left: 0,
                child: widget.model.acceptReject=="1"?Container(
                  padding: EdgeInsets.all(getWidth(10)),
                  color: Colors.white,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        "${getTranslated(context, "PICKUP_TIME")} - ${((double.parse(widget.model.km!)/25)*60).round()} min",
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                    ],
                    pause: Duration(milliseconds: 100),
                    isRepeatingAnimation: true,
                    totalRepeatCount: 100,
                    onTap: () {
                      print("Tap Event");
                    },
                  ),
                ):SizedBox(),
              ),
              widget.model.taxiId!=null?Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacePicker(
                          apiKey: Platform.isAndroid
                              ? "AIzaSyBmUCtQ_DlYKSU_BV7JdiyoOu1i4ybe-z0"
                              : "AIzaSyBmUCtQ_DlYKSU_BV7JdiyoOu1i4ybe-z0",
                          onPlacePicked: (result) {
                            print(result.formattedAddress);
                            setState(() {
                              widget.model.dropAddress =
                                  result.formattedAddress.toString();
                              widget.model.dropLatitude =
                                  result.geometry!.location.lat.toString();
                              widget.model.dropLongitude =
                                  result.geometry!.location.lng.toString();
                              change = true;
                            });
                            Navigator.of(context).pop();
                            getTime1(widget.model.latitude, widget.model.longitude, widget.model.dropLatitude, widget.model.dropLongitude);
                          },
                          initialPosition: LatLng(double.parse(widget.model.dropLatitude.toString()), double.parse( widget.model.dropLongitude.toString())),
                       //   useCurrentLocation: true,
                        ),
                      ),
                    );
                  },
                  child:Container(
                    width: 40.w,
                    height: 5.h,
                    margin: EdgeInsets.all(getWidth(5)),
                    decoration: boxDecoration(
                        radius: 5,
                        bgColor: Theme.of(context)
                            .primaryColor),
                    child: Center(
                        child: !change?text(getTranslated(context, "CHANGE_DROP")!,
                            fontFamily: fontMedium,
                            fontSize: 8.sp,
                            isCentered: true,
                            textColor: Colors.white):
                      CircularProgressIndicator(color: Colors.white,)
                    ),
                  ),
                ),
              ):SizedBox(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      buildFlatButton(Icons.call, 'CALL_NOW',(){
                        launch("tel://${widget.model.driverContact}");
                      }),
                      SizedBox(width: 10),
                      buildFlatButton(Icons.close, 'CANCEL',(){
                        showBottom1();
                      }),
                      SizedBox(width: 10),
                      buildFlatButton(
                          isOpened
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          isOpened ? 'LESS' : 'MORE', () {
                        setState(() {
                          isOpened = !isOpened;
                        });
                      }),
                    ],
                  ),
                ),
              )
            ],
          ):Center(child: CircularProgressIndicator()),
        ),
        bottomNavigationBar:  SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(getWidth(10)),
                color: Colors.white,
                child: AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      "Cancellation Charges ₹${widget.model.cancel_charge} is deducted from wallet.",
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                    ),
                  ],
                  pause: Duration(milliseconds: 100),
                  isRepeatingAnimation: true,
                  totalRepeatCount: 100,
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),

              // Text("OTP : ${widget.model.otp.toString()}"),
              ///
              // Container(
              //   padding: EdgeInsets.all(getWidth(10)),
              //   color: Colors.white,
              //   child: AnimatedTextKit(
              //     animatedTexts: [
              //       ColorizeAnimatedText(
              //         "OTP : ${widget.model.otp}",
              //         textStyle: colorizeTextStyle,
              //         colors: colorizeColors,
              //       ),
              //     ],
              //     pause: Duration(milliseconds: 100),
              //     isRepeatingAnimation: true,
              //     totalRepeatCount: 100,
              //     onTap: () {
              //       print("Tap Event");
              //     },
              //   ),
              // ),
              Text( "OTP : ${widget.model.bookingOtp}",),

              GestureDetector(
                onVerticalDragDown: (details) {
                  setState(() {
                    isOpened = !isOpened;
                  });
                },
                child: Container(
                  height: 100,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: isOpened
                        ? BorderRadius.circular(16)
                        : BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imagePath+ widget.model.driverImage.toString(),
                            height: 72,
                            width: 72,
                          ),
                        ),
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.model.driverName}',
                            style: theme.textTheme.headline6!.copyWith(
                                fontSize: 18, letterSpacing: 1.2),
                          ),
                          Text(
                            '${getTranslated(context, "TRIP_ID")} - ${widget.model.uneaqueId.toString()}',
                            style: theme.textTheme.bodyText1,
                          ),
                          Spacer(flex: 2),
                          Text(
                            '${widget.model.taxiType}(${widget.model.car_no})',
                            style: theme.textTheme.caption!
                                .copyWith(fontSize: 12),
                          ),
                         /* Spacer(),
                          Text(
                            '${widget.model.car_no}',
                            style: theme.textTheme.bodyText1!
                                .copyWith(fontSize: 13.5),
                          ),*/
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          widget.model.rating.toString()!="null"?Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppTheme.ratingsColor,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  widget.model.rating.toString(),
                                  style: theme.textTheme.bodyText1!
                                      .copyWith(fontSize: 12),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.star,
                                  color: AppTheme.starColor,
                                  size: 10,
                                )
                              ],
                            ),
                          ):SizedBox(),
                          Spacer(flex: 2),
                          Text(
                            getTranslated(context,'CURRENT_STATUS')!,
                            style: theme.textTheme.caption,
                          ),
                          Spacer(),
                          Text(
                            widget.model.acceptReject=="1"?"Arriving":widget.model.acceptReject=="6"?"Started":"Completed",
                            style: theme.textTheme.bodyText1!
                                .copyWith(
                              fontSize: 13.5,
                              color: widget.model.acceptReject=="1"?Colors.orange:widget.model.acceptReject=="6"?Colors.brown:Colors.green
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              isOpened?Details(widget.model):SizedBox(),
             /* AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 72,
                color:
                isOpened ? Colors.transparent : theme.backgroundColor,
              ),*/
            ],
          ),
        ),
      ),
      beginOffset: Offset(0, 0.3),
      endOffset: Offset(0, 0),
      slideCurve: Curves.linearToEaseOut,
    );
  }
  final colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  final colorizeTextStyle = TextStyle(
    fontSize: 14.0,
    fontFamily: 'Horizon',
  );
  Widget buildFlatButton(IconData icon, String text, [Function? onTap]) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap as void Function()? ?? () {},
        style: TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        icon: Icon(
          icon,
          size: 17,
          color:Colors.black,
        ),
        label: Text(
          getTranslated(context,text)!,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(fontSize: 13.5, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class Details extends StatefulWidget {

  MyRideModel model;
  Details(this.model);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    getTranslated(context,'RIDE_INFO')!,
                    style: theme.textTheme.headline6!
                        .copyWith(color: theme.hintColor, fontSize: 16.5),
                  ),
                  trailing: Text('${widget.model.km} km',
                      style:
                          theme.textTheme.headline6!.copyWith(fontSize: 16.5)),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(
                    Icons.location_on,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    '${widget.model.pickupAddress}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(
                    Icons.navigation,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    '${widget.model.dropAddress}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                buildRowItem(theme, 'PAYMENT_VIA',
                    '${widget.model.transaction}', Icons.account_balance_wallet),
                Spacer(),
                buildRowItem(theme, 'RIDE_FARE', '\u{20B9} ${widget.model.amount}',
                    Icons.account_balance_wallet),
                Spacer(),
                buildRowItem(theme, 'RIDE_TYPE',
                    '${widget.model.bookingType }', Icons.drive_eta),
              ],
            ),
          ),
          widget.model.acceptReject=="3"?Container(
            padding: EdgeInsets.all(getWidth(15)),
            child: Column(
              children: [
                double.parse(widget.model.gstAmount.toString())>0?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("${getTranslated(context, "SUB_TOTAL")} : ",
                        fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.black),
                    text(
                        "₹" + (double.parse(widget.model.amount.toString())-double.parse(widget.model.gstAmount.toString())-double.parse(widget.model.surgeAmount.toString())).toStringAsFixed(2),
                        fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.black),
                  ],
                ):SizedBox(),
                double.parse(widget.model.baseFare.toString())>0?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("${getTranslated(context, "BASE_FARE")} : ",
                        fontSize: 10.sp,
                        fontFamily: fontRegular,
                        textColor: Colors.black),
                    text(
                        "₹" + widget.model.baseFare.toString(),
                        fontSize: 10.sp,
                        fontFamily: fontRegular,
                        textColor: Colors.black),
                  ],
                ):SizedBox(),
                double.parse(widget.model.km.toString())>=2&&double.parse(widget.model.ratePerKm.toString())>0?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("${widget.model.km.toString()} ${getTranslated(context, "KILOMETERS")} : ",
                        fontSize: 10.sp,
                        fontFamily: fontRegular,
                        textColor: Colors.black),
                    text(
                        "₹" + widget.model.ratePerKm.toString(),
                        fontSize: 10.sp,
                        fontFamily: fontRegular,
                        textColor: Colors.black),
                  ],
                ):SizedBox(),
                double.parse(widget.model.timeAmount.toString())>0?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("${widget.model.totalTime.toString()} ${getTranslated(context, "MINUTES")} : ",
                        fontSize: 10.sp,
                        fontFamily: fontRegular,
                        textColor: Colors.black),
                    text(
                        "₹" + widget.model.timeAmount.toString(),
                        fontSize: 10.sp,
                        fontFamily: fontRegular,
                        textColor: Colors.black),
                  ],
                ):SizedBox(),
                double.parse(widget.model.gstAmount.toString())>0?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("${getTranslated(context, "TAXES")} : ",
                        fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.black),
                    text(
                        "₹" + widget.model.gstAmount.toString(),
                        fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.black),
                  ],
                ):SizedBox(),

                double.parse(widget.model.surgeAmount.toString())>0?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("${getTranslated(context, "SURGE")} : ",
                        fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.black),
                    text(
                        "₹" + widget.model.surgeAmount.toString(),
                        fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.black),
                  ],
                ):SizedBox(),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("${getTranslated(context, "TOTAL")} : ",
                        fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.black),
                    text(
                        "₹" + "${widget.model.amount}",
                        fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.black),
                  ],
                ),
                boxHeight(10),
              ],
            ),
          ):SizedBox(),
        ],
      ),
    );
  }

  Expanded buildRowItem(
      ThemeData theme, String title, String subtitle, IconData icon) {
    return Expanded(
      flex: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslated(context,title)!,
            style: theme.textTheme.headline6!
                .copyWith(color: theme.hintColor, fontSize: 16),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                icon,
                color: theme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                subtitle,
                style: theme.textTheme.headline6!.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
