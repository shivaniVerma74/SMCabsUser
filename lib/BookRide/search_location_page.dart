import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cabira/BookRide/choose_cab_page.dart';
import 'package:cabira/BookRide/finding_ride_page.dart';
import 'package:cabira/BookRide/map.dart';
import 'package:cabira/BookRide/ride_booked_page.dart';
import 'package:cabira/DrawerPages/Rides/my_rides_page.dart';
import 'package:cabira/DrawerPages/Rides/rental_rides.dart';
import 'package:cabira/DrawerPages/Rides/ride_info_page.dart';
import 'package:cabira/DrawerPages/notification_list.dart';
import 'package:cabira/Model/category_model.dart';
import 'package:cabira/Model/my_ride_model.dart';
import 'package:cabira/Model/rental_model.dart';
import 'package:cabira/Model/rides_model.dart';
import 'package:cabira/Model/wallet_model.dart';
import 'package:cabira/utils/ApiBaseHelper.dart';
import 'package:cabira/utils/Session.dart';
import 'package:cabira/utils/colors.dart';
import 'package:cabira/utils/common.dart';
import 'package:cabira/utils/constant.dart';
import 'package:cabira/utils/location_details.dart';
import 'package:cabira/utils/referCodeService.dart';
import 'package:cabira/utils/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cabira/Components/background_image.dart';
import 'package:cabira/Components/custom_button.dart';
import 'package:cabira/Components/entry_field.dart';
import 'package:cabira/DrawerPages/app_drawer.dart';
import 'package:cabira/Locale/locale.dart';
import 'package:cabira/Locale/strings_enum.dart';
import 'package:cabira/Routes/page_routes.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../utils/PushNotificationService.dart';

class SearchLocationPage extends StatefulWidget {
  @override
  _SearchLocationPageState createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  TextEditingController pickupCon = new TextEditingController();
  TextEditingController dropCon = new TextEditingController();
  List<CategoryModel> catList = [

    //   CategoryModel("5", "Pool Ride", "assets/pool_ride.png"),
  ];
  List<TimeModel> timeList = [
    TimeModel("1", "1 Hour", "₹200", "20Km", "₹200"),
    TimeModel("2", "2 Hour", "₹350", "40Km", "₹175"),
    TimeModel("3", "3 Hour", "₹450", "60Km", "₹150"),
  ];

  vehicleCardBike(BikeData rentList, int index){
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width - 40,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: rentList.hoursData!.length,
          itemBuilder: (context, i){
        return InkWell(
          onTap: () {
            setState(() {
              bikeIndex = i;
            });
            print("this is current cabid ======>>> ${timeIndex.toString()} ${bikeRentList[bikeIndex].cabId}");

          },
          child: Container(
            margin: EdgeInsets.only(right: getWidth(5)),
            height: getHeight(150),
            // width: getWidth(110),
            padding: EdgeInsets.all(getWidth(10)),
            decoration: boxDecoration(
                bgColor: bikeIndex == i
                    ? MyColorName.primaryLite
                    .withOpacity(0.1)
                    : Colors.transparent,
                radius: 5,
                color: MyColorName.colorTextPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                text(
                  rentList.carModel !=null?rentList.carModel.toString():"Bike",
                  fontSize: 8.sp,
                  fontFamily: fontMedium,
                  textColor: MyColorName.appbarBg,
                ),
                boxHeight(10),
                Image.asset(
                  rentList.carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                  height: getHeight(50),
                  width: getWidth(50),
                  fit: BoxFit.fill,
                ),
                boxHeight(10),
                text(
                  rentList.hoursData![i].hours.toString()+" Minutes",
                  fontSize: 10.sp,
                  fontFamily: fontMedium,
                  textColor: MyColorName.appbarBg,
                ),
                // boxHeight(5),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "₹"+rentList.hoursData![i].fixedAmount.toString(),
                      fontSize: 9.sp,
                      fontFamily: fontMedium,
                      textColor: MyColorName.appbarBg,
                    ),
                    boxWidth(5),
                    text(
                      "₹"+rentList.ratePerHour.toString() + "/mins",
                      fontSize: 7.sp,
                      fontFamily: fontRegular,
                      textColor: MyColorName.appbarBg,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "₹"+'${rentList.ratePerHour.toString()}/hrs after '+rentList.hoursData![i].fixedKm.toString() + "Kms",
                      fontSize: 7.sp,
                      fontFamily: fontRegular,
                      textColor: MyColorName.appbarBg,
                    ),
                    // text(
                    //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                    //   + "kms",
                    //   fontSize: 7.sp,
                    //   fontFamily: fontRegular,
                    //   textColor: MyColorName.appbarBg,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  vehicleCardCar(CarData rentList, int index){
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width/3 - 10,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
          itemCount: rentList.hoursData!.length,
          itemBuilder: (context, i){
            return InkWell(
              onTap: () {
                setState(() {
                  timeIndex = index;
                });
                print("this is current cabid ======>>> ${timeIndex.toString()} ${carRentList[index].cabId}");
              },
              child: Container(
                margin: EdgeInsets.only(right: getWidth(5)),
                height: getHeight(150),
                // width: getWidth(110),
                padding: EdgeInsets.all(getWidth(10)),
                decoration: boxDecoration(
                    bgColor: timeIndex == index
                        ? MyColorName.primaryLite
                        .withOpacity(0.1)
                        : Colors.transparent,
                    radius: 5,
                    color: MyColorName.colorTextPrimary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      rentList.carModel !=null?rentList.carModel.toString():"Bike",
                      fontSize: 8.sp,
                      fontFamily: fontMedium,
                      textColor: MyColorName.appbarBg,
                    ),
                    boxHeight(10),
                    Image.asset(
                      rentList.carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                      height: getHeight(50),
                      width: getWidth(50),
                      fit: BoxFit.fill,
                    ),
                    boxHeight(10),
                    text(
                      rentList.hoursData![i].hours.toString()+" Minutes",
                      fontSize: 10.sp,
                      fontFamily: fontMedium,
                      textColor: MyColorName.appbarBg,
                    ),
                    // boxHeight(5),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        text(
                          "₹"+rentList.hoursData![i].fixedAmount.toString(),
                          fontSize: 9.sp,
                          fontFamily: fontMedium,
                          textColor: MyColorName.appbarBg,
                        ),
                        boxWidth(5),
                        text(
                          "₹"+rentList.ratePerHour.toString() + "/mins",
                          fontSize: 7.sp,
                          fontFamily: fontRegular,
                          textColor: MyColorName.appbarBg,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        text(
                          "₹"+'${rentList.ratePerHour.toString()}/hrs after '+rentList.hoursData![i].fixedKm.toString() + "Kms",
                          fontSize: 7.sp,
                          fontFamily: fontRegular,
                          textColor: MyColorName.appbarBg,
                        ),
                        // text(
                        //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                        //   + "kms",
                        //   fontSize: 7.sp,
                        //   fontFamily: fontRegular,
                        //   textColor: MyColorName.appbarBg,
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  double dropLatitude = 0, dropLongitude = 0;
  bool sharing = false;
  @override
  void initState() {
    getLocation();
    super.initState();

    listenDeepLinkData(context);
     getCurrentInfo();
    registerToken();
    getProfile();
    getRental();
    // getWallet();
  }
  List<WalletModel> walletList = [];
  double totalBal = 0;

  getWallet() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response = await apiBase.getAPICall(
        Uri.parse(baseUrl1 + "users/getWallet/${curUserId}"),);
      setState(() {
        saveStatus = true;
        walletList.clear();
      });
      if (response['status']) {
        var data = response["transactions"];
        for(var v in data){
          print(v['Note']);
          setState(() {
            walletList.add(new WalletModel.fromJson(v));
          });

        }
        print(data);
        totalBal = double.parse(response['amount'].toString());

      } else {
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  List<BikeData> bikeRentList = [];
  List<CarData> carRentList = [];

  getRental() async {
    var response = await http.get(Uri.parse(baseUrl1 + "ride/rental"));
    Map data = jsonDecode(response.body);
    if(data['status']) {
      for (var v in data['bike_data']) {
        setState((){
          bikeRentList.add(BikeData.fromJson(v));
        });
        print("this is bike list ======>>>>> ${bikeRentList[0].hours.toString()}");
      }
      for (var v in data['car_data']) {
        setState((){
          carRentList.add(CarData.fromJson(v));
        });
        print("this is car list ======>>>>> ${carRentList[0].hours.toString()}");
      }
    }
  }

  getLocation() {
    GetLocation location = new GetLocation((result) {
      if (mounted) {
        setState(() {
          address = result.first.addressLine;
          latitude = result.first.coordinates.latitude;
          longitude = result.first.coordinates.longitude;
          pickupCon.text = address;
        });
      }
    });
    location.getLoc();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void listenDeepLinkData(BuildContext context) async {
    FlutterBranchSdk.initSession().listen((data) {
      print("data" + data.toString());
      if (data['codeId'] != null) {
        getBookingInfo(data['codeId']);
      }

      print("temp = ${data['codeId']}");
    });
  }

  bool loading = true;
  bool loadingRental = false;
  bool saveStatus = true;
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;

  showConfirm(MyRideModel model) {
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(getWidth(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text(getTranslated(context, "RIDE_INFO")!,
                      fontSize: 10.sp,
                      fontFamily: fontMedium,
                      textColor: Colors.black),
                  Divider(),
                  boxHeight(10),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration:
                            boxDecoration(radius: 100, bgColor: Colors.green),
                      ),
                      boxWidth(10),
                      Expanded(
                          child: text(model.pickupAddress!,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration:
                            boxDecoration(radius: 100, bgColor: Colors.red),
                      ),
                      boxWidth(10),
                      Expanded(
                          child: text(model.dropAddress!,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "PAYMENT_MODE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(model.transaction!,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "RIDE_TYPE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(model.bookingType!,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text("${getTranslated(context, "BOOKING_ON")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      Expanded(
                          child: text(getDate(model.createdDate!),
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context1);
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          decoration:
                              boxDecoration(radius: 5, bgColor: Colors.grey),
                          child: Center(
                              child: text(getTranslated(context, "CANCEL")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context1);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RideInfoPage(model)));
                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          decoration: boxDecoration(
                              radius: 5,
                              bgColor: Theme.of(context).primaryColor),
                          child: Center(
                              child: text(getTranslated(context, "VIEW")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  getBookingInfo(tempRefer) async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "booking_id": tempRefer.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "payment/get_booking_by_id"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var v = response["data"];
        showConfirm(MyRideModel.fromJson(v));

        //print(data);
      } else {
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  getProfile() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response =
          await apiBase.postAPICall(Uri.parse(baseUrl + "get_profile"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var data = response["data"];
        print(data['wallet_amount']);
        setState(() {
          name = data['username'];
          mobile = data['mobile'];
          email = data['email'];
          gender1 = data['gender'];
          dob = data['dob'];
          isFirstUser = data['first_order'];
          password = data['new_password'];
          walletAmount = data['wallet_amount']!=null&&data['wallet_amount']!=""?double.parse(data['wallet_amount']):0;
          image =
              response['image_path'].toString() + data['user_image'].toString();
          imagePath = response['image_path'].toString();
          refer = data['referral_code'];
        });

        print("IMAGE========" + imagePath.toString());
        final referCodeService = ReferCodeService(context);
        referCodeService.init(null);
      } else {
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  String count = "0";

  getCount() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "driver_id": curUserId.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "payment/count_noti_driver"), params);

      if (response['status']) {
        count = response["noti_count"].toString();
      } else {
        // setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  String paymentType = "Cash";
  DateTime? currentBackPressTime;

  Future<bool> onWill() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Common().toast("Press back again to exit");
      return Future.value(false);
    }
    exit(1);
    return Future.value();
  }

  int currentIndex = 0, timeIndex = 0, vehicleType = 0, bikeIndex = 0;
  @override
  Widget build(BuildContext context) {
    catList = [
      CategoryModel("1", getTranslated(context, "RIDE")!, "assets/ride.png"),
      CategoryModel("2", getTranslated(context, "SCHEDULE")!, "assets/schedule_ride.png"),
      CategoryModel("3", getTranslated(context, "RENTAL")!, "assets/rental.png"),
      CategoryModel("4", getTranslated(context, "INTERCITY")!, "assets/intercity.png"),
    ];
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: onWill,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color(0xff2CC8DE),
          title: Text(
            getTranslated(context,"BOOK_YOUR_RIDE")!.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          actions: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(onPressed: ()async{
                  var result = await Navigator.push(context, MaterialPageRoute(builder: (context)=> NotificationScreen()));
                  if(result!=null){
                    if(result=="yes"){
                      setState(() {
                        count = "0";
                      });
                      return;
                    }
                    getBookingInfo(result);
                  }
                }, icon: Icon(Icons.notifications_active,color: Colors.black,)),
                count!="0"?Container(
                  width: getWidth(18),
                  height: getWidth(18),
                  margin: EdgeInsets.only(right: getWidth(3),top: getHeight(3)),
                  decoration: boxDecoration(
                      radius: 100,
                      bgColor: Colors.red
                  ),
                  child: Center(child: text(count.toString(),fontFamily: fontMedium,fontSize: 6.sp,textColor: Colors.white)),
                ):SizedBox(),
              ],
            ),
          ],
        ),
        drawer: AppDrawer(),
        resizeToAvoidBottomInset: true,
        body: latitude != 0
            ? MapPage(
                false,
                driveList: [],
                live: false,
                SOURCE_LOCATION: LatLng(latitude, longitude),
              )
            : Center(child: CircularProgressIndicator()),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: getHeight(120),
                padding: EdgeInsets.all(getWidth(15)),
                child: ListView.builder(
                    itemCount: catList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            bookingDate = null;
                            currentIndex = index;
                          });
                        },
                        child: Container(
                          // margin: EdgeInsets.only(right: getWidth(15)),
                          height: getHeight(120),
                          width: getWidth(90),
                          decoration: boxDecoration(
                            bgColor: currentIndex == index
                                ? MyColorName.primaryLite.withOpacity(0.1)
                                : Colors.transparent,
                            radius: 5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                catList[index].image,
                                width: getHeight(60),
                                height: getHeight(60),
                              ),
                              text(
                                catList[index].name,
                                fontSize: 9.sp,
                                fontFamily: fontMedium,
                                textColor: MyColorName.appbarBg,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              // currentIndex == 2?Container(
              //   padding: EdgeInsets.all(getWidth(15)),
              //   child: Row(
              //     mainAxisAlignment:
              //     MainAxisAlignment.spaceBetween,
              //     children: [
              //       text(
              //         getTranslated(context, "START_NOW")!,
              //         fontSize: 9.sp,
              //         fontFamily: fontMedium,
              //         textColor: MyColorName.appbarBg,
              //       ),
              //       text("",
              //         // "${getTranslated(context, "END_TIME")} - ${DateFormat.jm().format(DateTime.now().add(Duration(hours: int.parse(rentList[0].hours.toString()))))}",
              //         fontSize: 9.sp,
              //         fontFamily: fontMedium,
              //         textColor: MyColorName.appbarBg,
              //       ),
              //     ],
              //   ),
              // ):SizedBox(),
              currentIndex == 2 ?
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          vehicleType = 0;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: getWidth(5)),
                        // height: getHeight(200),
                        // width: getWidth(110),
                        padding: EdgeInsets.all(getWidth(10)),
                        decoration: boxDecoration(
                            bgColor: vehicleType == 0
                                ? MyColorName.primaryLite
                                .withOpacity(0.1)
                                : Colors.transparent,
                            radius: 5,
                            color: MyColorName.colorTextPrimary),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center ,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            // text(
                            //   rentList[0].carModel!=null?rentList[0].carModel.toString():"Bike",
                            //   fontSize: 8.sp,
                            //   fontFamily: fontMedium,
                            //   textColor: MyColorName.appbarBg,
                            // ),
                            // boxHeight(10),
                            Image.asset(
                              "assets/cars/car1.png",
                              height: getHeight(30),
                              width: getWidth(30),
                              fit: BoxFit.fill,
                            ),
                            SizedBox(height: 5, width: 5,),
                            Center(
                              child: text("Bike",
                                // rentList[0].hours.toString()+" Hour",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: MyColorName.appbarBg,
                              ),
                            ),
                            // Row(
                            //   mainAxisAlignment:
                            //   MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     text(
                            //       "₹"+rentList[index].fixedRate.toString(),
                            //       fontSize: 9.sp,
                            //       fontFamily: fontMedium,
                            //       textColor: MyColorName.appbarBg,
                            //     ),
                            //     text(
                            //       "₹"+rentList[index].ratePerHour.toString() + "/hr",
                            //       fontSize: 7.sp,
                            //       fontFamily: fontRegular,
                            //       textColor: MyColorName.appbarBg,
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          vehicleType = 1;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: getWidth(5)),
                        // height: getHeight(200),
                        // width: getWidth(110),
                        padding: EdgeInsets.all(getWidth(10)),
                        decoration: boxDecoration(
                            bgColor: vehicleType == 1
                                ? MyColorName.primaryLite
                                .withOpacity(0.1)
                                : Colors.transparent,
                            radius: 5,
                            color: MyColorName.colorTextPrimary),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            // text(
                            //   rentList[0].carModel!=null?rentList[0].carModel.toString():"Bike",
                            //   fontSize: 8.sp,
                            //   fontFamily: fontMedium,
                            //   textColor: MyColorName.appbarBg,
                            // ),
                            // boxHeight(10),
                            Image.asset(
                              "assets/cars/car2.png",
                              height: getHeight(30),
                              width: getWidth(30),
                              fit: BoxFit.fill,
                            ),
                            SizedBox(height: 5, width: 5,),
                            Center(
                              child: text("Car",
                                // rentList[0].hours.toString()+" Hour",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: MyColorName.appbarBg,
                              ),
                            ),
                            boxHeight(5),
                            // Row(
                            //   mainAxisAlignment:
                            //   MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     text(
                            //       "₹"+rentList[index].fixedRate.toString(),
                            //       fontSize: 9.sp,
                            //       fontFamily: fontMedium,
                            //       textColor: MyColorName.appbarBg,
                            //     ),
                            //     text(
                            //       "₹"+rentList[index].ratePerHour.toString() + "/hr",
                            //       fontSize: 7.sp,
                            //       fontFamily: fontRegular,
                            //       textColor: MyColorName.appbarBg,
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ) : SizedBox(),
              currentIndex == 2
                  ? Container(
                      height: getHeight(220),
                      padding: EdgeInsets.all(getWidth(15)),
                      child:
                      // rentList.length>0?
                      ListView.builder(
                          itemCount:
                              vehicleType == 0 ? bikeRentList.length
                          : carRentList.length,
                          // rentList[0].carCategories == "1" ? rentList[0].hoursData!.length
                          // : rentList[1].hoursData!.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return vehicleType == 0 ?
                            vehicleCardBike(bikeRentList[index], index)
                            : vehicleCardCar(carRentList[index], index);
                            //   InkWell(
                            //   onTap: () {
                            //     setState(() {
                            //       timeIndex = index;
                            //     });
                            //   },
                            //   child: Container(
                            //     margin: EdgeInsets.only(right: getWidth(5)),
                            //     height: getHeight(150),
                            //     // width: getWidth(110),
                            //     padding: EdgeInsets.all(getWidth(10)),
                            //     decoration: boxDecoration(
                            //         bgColor: timeIndex == index
                            //             ? MyColorName.primaryLite
                            //                 .withOpacity(0.1)
                            //             : Colors.transparent,
                            //         radius: 5,
                            //         color: MyColorName.colorTextPrimary),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         text(
                            //           rentList[0].carModel!=null?rentList[0].carModel.toString():"Bike",
                            //           fontSize: 8.sp,
                            //           fontFamily: fontMedium,
                            //           textColor: MyColorName.appbarBg,
                            //         ),
                            //         boxHeight(10),
                            //         Image.asset(
                            //           rentList[index].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                            //           height: getHeight(50),
                            //           width: getWidth(50),
                            //           fit: BoxFit.fill,
                            //         ),
                            //         boxHeight(10),
                            //         text(
                            //           rentList[0].hoursData![0].hours.toString()+" Minutes",
                            //           fontSize: 10.sp,
                            //           fontFamily: fontMedium,
                            //           textColor: MyColorName.appbarBg,
                            //         ),
                            //         // boxHeight(5),
                            //         Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             text(
                            //              "₹"+rentList[0].hoursData![0].fixedAmount.toString(),
                            //               fontSize: 9.sp,
                            //               fontFamily: fontMedium,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //             boxWidth(5),
                            //             text(
                            //               "₹"+rentList[0].ratePerHour.toString() + "/mins",
                            //               fontSize: 7.sp,
                            //               fontFamily: fontRegular,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //           ],
                            //         ),
                            //         Row(
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             text(
                            //               "₹"+'${rentList[0].ratePerHour.toString()}/hrs after '+rentList[0].hoursData![index].fixedKm.toString() + "Kms",
                            //               fontSize: 7.sp,
                            //               fontFamily: fontRegular,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //             // text(
                            //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                            //             //   + "kms",
                            //             //   fontSize: 7.sp,
                            //             //   fontFamily: fontRegular,
                            //             //   textColor: MyColorName.appbarBg,
                            //             // ),
                            //           ],
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // )
                            //     :  InkWell(
                            //       onTap: () {
                            //         setState(() {
                            //           timeIndex = index;
                            //         });
                            //       },
                            //       child: Container(
                            //         margin: EdgeInsets.only(right: getWidth(5)),
                            //         height: getHeight(150),
                            //         // width: getWidth(110),
                            //         padding: EdgeInsets.all(getWidth(10)),
                            //         decoration: boxDecoration(
                            //             bgColor: timeIndex == index
                            //                 ? MyColorName.primaryLite
                            //                 .withOpacity(0.1)
                            //                 : Colors.transparent,
                            //             radius: 5,
                            //             color: MyColorName.colorTextPrimary),
                            //         child: Column(
                            //           crossAxisAlignment: CrossAxisAlignment.start,
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             text(
                            //               rentList[1].carModel!=null?rentList[1].carModel.toString():"Bike",
                            //               fontSize: 8.sp,
                            //               fontFamily: fontMedium,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //             boxHeight(10),
                            //             Image.asset(
                            //               rentList[1].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                            //               height: getHeight(50),
                            //               width: getWidth(50),
                            //               fit: BoxFit.fill,
                            //             ),
                            //             boxHeight(10),
                            //             text(
                            //               rentList[1].hoursData![index].hours.toString()+" Minutes",
                            //               fontSize: 10.sp,
                            //               fontFamily: fontMedium,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //             // boxHeight(5),
                            //             Row(
                            //               mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //               children: [
                            //                 text(
                            //                   "₹"+rentList[1].hoursData![index].fixedAmount.toString(),
                            //                   fontSize: 9.sp,
                            //                   fontFamily: fontMedium,
                            //                   textColor: MyColorName.appbarBg,
                            //                 ),
                            //                 boxWidth(5),
                            //                 text(
                            //                   "₹"+rentList[1].ratePerHour.toString() + "/mins",
                            //                   fontSize: 7.sp,
                            //                   fontFamily: fontRegular,
                            //                   textColor: MyColorName.appbarBg,
                            //                 ),
                            //               ],
                            //             ),
                            //             Row(
                            //               mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //               children: [
                            //                 text(
                            //                   "₹"+'${rentList[1].ratePerHour.toString()}/hrs after '+rentList[1].hoursData![index].fixedKm.toString() + "Kms",
                            //                   fontSize: 7.sp,
                            //                   fontFamily: fontRegular,
                            //                   textColor: MyColorName.appbarBg,
                            //                 ),
                            //                 // text(
                            //                 //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                            //                 //   + "kms",
                            //                 //   fontSize: 7.sp,
                            //                 //   fontFamily: fontRegular,
                            //                 //   textColor: MyColorName.appbarBg,
                            //                 // ),
                            //               ],
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     )
                            // : SizedBox.shrink();
                            // :  rentList[0].carCategories == "2" ?
                            // InkWell(
                            //   onTap: () {
                            //     setState(() {
                            //       timeIndex = index;
                            //     });
                            //   },
                            //   child: Container(
                            //     margin: EdgeInsets.only(right: getWidth(5)),
                            //     height: getHeight(150),
                            //     // width: getWidth(110),
                            //     padding: EdgeInsets.all(getWidth(10)),
                            //     decoration: boxDecoration(
                            //         bgColor: timeIndex == index
                            //             ? MyColorName.primaryLite
                            //             .withOpacity(0.1)
                            //             : Colors.transparent,
                            //         radius: 5,
                            //         color: MyColorName.colorTextPrimary),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       mainAxisAlignment:
                            //       MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         text(
                            //           rentList[0].carModel!=null?rentList[0].carModel.toString():"Bike",
                            //           fontSize: 8.sp,
                            //           fontFamily: fontMedium,
                            //           textColor: MyColorName.appbarBg,
                            //         ),
                            //         boxHeight(10),
                            //         Image.asset(
                            //           rentList[0].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                            //           height: getHeight(50),
                            //           width: getWidth(50),
                            //           fit: BoxFit.fill,
                            //         ),
                            //         boxHeight(10),
                            //         text(
                            //           rentList[0].hoursData![index].hours.toString()+" Minutes",
                            //           fontSize: 10.sp,
                            //           fontFamily: fontMedium,
                            //           textColor: MyColorName.appbarBg,
                            //         ),
                            //         // boxHeight(5),
                            //         Row(
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             text(
                            //               "₹"+rentList[0].hoursData![index].fixedAmount.toString(),
                            //               fontSize: 9.sp,
                            //               fontFamily: fontMedium,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //             boxWidth(5),
                            //             text(
                            //               "₹"+rentList[0].ratePerHour.toString() + "/mins",
                            //               fontSize: 7.sp,
                            //               fontFamily: fontRegular,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //           ],
                            //         ),
                            //         Row(
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             text(
                            //               "₹"+'${rentList[0].ratePerHour.toString()}/hrs after '+rentList[0].hoursData![index].fixedKm.toString() + "Kms",
                            //               fontSize: 7.sp,
                            //               fontFamily: fontRegular,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //             // text(
                            //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                            //             //   + "kms",
                            //             //   fontSize: 7.sp,
                            //             //   fontFamily: fontRegular,
                            //             //   textColor: MyColorName.appbarBg,
                            //             // ),
                            //           ],
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // )
                            //     :  InkWell(
                            //   onTap: () {
                            //     setState(() {
                            //       timeIndex = index;
                            //     });
                            //   },
                            //   child: Container(
                            //     margin: EdgeInsets.only(right: getWidth(5)),
                            //     height: getHeight(150),
                            //     // width: getWidth(110),
                            //     padding: EdgeInsets.all(getWidth(10)),
                            //     decoration: boxDecoration(
                            //         bgColor: timeIndex == index
                            //             ? MyColorName.primaryLite
                            //             .withOpacity(0.1)
                            //             : Colors.transparent,
                            //         radius: 5,
                            //         color: MyColorName.colorTextPrimary),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       mainAxisAlignment:
                            //       MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         text(
                            //           rentList[1].carModel!=null?rentList[1].carModel.toString():"Bike",
                            //           fontSize: 8.sp,
                            //           fontFamily: fontMedium,
                            //           textColor: MyColorName.appbarBg,
                            //         ),
                            //         boxHeight(10),
                            //         Image.asset(
                            //           rentList[1].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                            //           height: getHeight(50),
                            //           width: getWidth(50),
                            //           fit: BoxFit.fill,
                            //         ),
                            //         boxHeight(10),
                            //         text(
                            //           rentList[1].hoursData![index].hours.toString()+" Minutes",
                            //           fontSize: 10.sp,
                            //           fontFamily: fontMedium,
                            //           textColor: MyColorName.appbarBg,
                            //         ),
                            //         // boxHeight(5),
                            //         Row(
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             text(
                            //               "₹"+rentList[1].hoursData![index].fixedAmount.toString(),
                            //               fontSize: 9.sp,
                            //               fontFamily: fontMedium,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //             boxWidth(5),
                            //             text(
                            //               "₹"+rentList[1].ratePerHour.toString() + "/mins",
                            //               fontSize: 7.sp,
                            //               fontFamily: fontRegular,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //           ],
                            //         ),
                            //         Row(
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             text(
                            //               "₹"+'${rentList[1].ratePerHour.toString()}/hrs after '+rentList[1].hoursData![index].fixedKm.toString() + "Kms",
                            //               fontSize: 7.sp,
                            //               fontFamily: fontRegular,
                            //               textColor: MyColorName.appbarBg,
                            //             ),
                            //             // text(
                            //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                            //             //   + "kms",
                            //             //   fontSize: 7.sp,
                            //             //   fontFamily: fontRegular,
                            //             //   textColor: MyColorName.appbarBg,
                            //             // ),
                            //           ],
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // );
                          })
                          // :SizedBox(),
                    )
                  : SizedBox(),
              Container(
                height: 60,
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: pickupCon,
                  readOnly: true,
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
                              pickupCon.text =
                                  result.formattedAddress.toString();
                              latitude = result.geometry!.location.lat;
                              longitude = result.geometry!.location.lng;
                            });
                            Navigator.of(context).pop();
                          },
                          initialPosition: LatLng(latitude, longitude),
                          useCurrentLocation: true,
                        ),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: getTranslated(context,"PICKUP_LOCATION"),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
              ),
              currentIndex != 2
                  ? Container(
                      height: 60,
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        controller: dropCon,
                        readOnly: true,
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
                                    dropCon.text =
                                        result.formattedAddress.toString();
                                    dropLatitude =
                                        result.geometry!.location.lat;
                                    dropLongitude =
                                        result.geometry!.location.lng;
                                  });
                                  Navigator.of(context).pop();
                                },
                                initialPosition: dropLatitude != 0
                                    ? LatLng(dropLatitude, dropLongitude)
                                    : LatLng(latitude, longitude),
                                useCurrentLocation: true,
                              ),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          labelText: getTranslated(context,"DROP_LOCATION"),
                          enabledBorder: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(),
                        ),
                      ),
                    )
                  : SizedBox(),
              currentIndex != 2 ?
              Container(
                color: theme.backgroundColor,
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 52,
                child: Row(
                  children: [
                    Text(
                      getTranslated(context,"PAYMENT_MODE")!,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: 13.5,
                          ),
                    ),
                    Spacer(),
                    Container(
                      width: 1,
                      height: 28,
                      color: theme.hintColor,
                    ),
                    Spacer(),
                    PopupMenuButton(
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            paymentType != ""
                                ? paymentType
                                : getTranslated(context,'WALLET')!,
                            style: theme.textTheme.button!.copyWith(
                                color: theme.primaryColor, fontSize: 15),
                          ),
                        ],
                      ),
                      onSelected: (val) {
                        setState(() {
                          paymentType = val.toString();
                        });
                      },
                      offset: Offset(0, -144),
                      color: theme.backgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: getString(Strings.CASH)!,
                            child: Row(
                              children: [
                                Icon(Icons.credit_card_sharp),
                                SizedBox(width: 12),
                                Text(getTranslated(context,'CASH')!),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet),
                                SizedBox(width: 12),
                                Text(getTranslated(context,'WALLET')!),
                              ],
                            ),
                            value: getString(Strings.WALLET)!,
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              )
              : SizedBox.shrink(),
              currentIndex == 3?Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          setState((){
                            sharing =false;
                          });
                        },
                        child: Row(
                          children: [
                            boxWidth(10),
                            Icon(!sharing?Icons.radio_button_checked_sharp:Icons.radio_button_unchecked_sharp, color: Theme.of(context).colorScheme.primary),
                            boxWidth(5),
                            text(
                                "Personal",
                                fontFamily: fontMedium,
                                fontSize: 10.sp,
                                textColor: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          setState((){
                            sharing =true;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(sharing?Icons.radio_button_checked_sharp:Icons.radio_button_unchecked_sharp, color: Theme.of(context).colorScheme.primary),
                            boxWidth(5),
                            text(
                                "Sharing",
                                fontFamily: fontMedium,
                                fontSize: 10.sp,
                                textColor: Theme.of(context).colorScheme.primary),
                            boxWidth(10),
                          ],
                        ),
                      ),
                    ],
                  )):SizedBox(),
              currentIndex == 3&&sharing?Padding(
                  padding: EdgeInsets.all(8.0),
                  child: text(
                      getTranslated(context, "ONLY")!,
                      fontFamily: fontMedium,
                      fontSize: 10.sp,
                      isCentered: true,
                      textColor: Colors.redAccent))
                  : SizedBox(),
              bookingDate != null && bookingDate!.minute > DateTime.now().minute
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: text(
                          "${getTranslated(context, "BOOKING_DATE")} : " + getDate(bookingDate.toString()),
                          fontFamily: fontMedium,
                          fontSize: 10.sp,
                          textColor: Theme.of(context).colorScheme.primary))
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment:  currentIndex == 1||currentIndex==3 || currentIndex == 2
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        if(currentIndex==2 ) {
                          if (bookingDate == null) {
                            setSnackbar("Please Select Date and Time", context);
                          } else {
                            showRental();
                          }
                        }

                       else if (currentIndex == 1&& bookingDate == null||currentIndex==3 &&bookingDate == null) {
                          setSnackbar("Please Select Date and Time", context);
                          return;
                        }
                       else if (latitude != 0 && dropLatitude != 0) {
                          var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChooseCabPage(
                                        LatLng(latitude, longitude),
                                        LatLng(dropLatitude, dropLongitude),
                                        pickupCon.text,
                                        dropCon.text,
                                        paymentType,
                                        bookingDate != null
                                            ? bookingDate
                                            : null,
                                        currentIndex==3?sharing?"Share":"Personal":"",
                                      )));
                          print(result);
                          if (result == "yes") {
                            setState(() {
                              bookingDate = null;
                              dropCon.text = "";
                              getLocation();
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyRidesPage()));
                          }
                        } else {
                          setSnackbar("Please Pick Both Location", context);
                        }
                      },
                      child: Container(
                        width: 75.w,
                        height: 6.h,
                        decoration: boxDecoration(
                            radius: 10,
                            bgColor: Theme.of(context).primaryColor),
                        child: Center(
                            child: currentIndex == 2 ?
                                loadingRental ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                            : text(getTranslated(context, "CONTINUE")!,
                                fontFamily: fontMedium,
                                fontSize: 12.sp,
                                textColor: Colors.white)
                        : text(getTranslated(context, "CONTINUE")!,
                                fontFamily: fontMedium,
                                fontSize: 12.sp,
                                textColor: Colors.white)),
                      ),
                    ),
                    currentIndex == 1||currentIndex==3 || currentIndex == 2
                        ? InkWell(
                            onTap: () {
                              DatePicker.showDateTimePicker(context,
                                  showTitleActions: true, onChanged: (date) {
                                print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                setState(() {
                                  bookingDate = date;
                                  bookngDat = bookingDate.toString();
                                });
                                bookingTime = DateFormat('HH:mm:ss').format(date);
                                print('confirm $date -----$bookingTime -----$bookngDat');
                              },
                                  currentTime: DateTime.now(),
                                  minTime: DateTime.now().subtract(Duration(hours: 1)),
                                  maxTime:
                                      DateTime.now().add(Duration(days: 3)));
                            },
                            child: Container(
                              decoration: boxDecoration(
                                  radius: 10,
                                  color: Theme.of(context).primaryColor),
                              height: 6.h,
                              width: 6.h,
                              child: Icon(
                                Icons.calendar_today_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 20.sp,
                              ),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? bookingDate;
  String? bookngDat;
  String? bookingTime;
  MyRideModel? model1;
  getCurrentInfo() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId,
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/get_current_boooking"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var v = response["data"];
        setState(() {
          model1 = MyRideModel.fromJson(v);
        });
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => RideBookedPage(model1!)));
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
        saveStatus = true;
      });
    }
  }

  showRental() {

   /* surge = 0;
    gst = 0;
    gst = ((double.parse(rideList[_currentCar].gst)*double.parse(rideList[_currentCar].intailrate))/100).roundToDouble();
    if(!rideList[_currentCar].serge.contains("Not")&&rideList[_currentCar].surge_charge.length>0){
      if(rideList[_currentCar].surge_charge[0]['time_on_off'].toString()!="CLOSED"){
        surge = (double.parse(rideList[_currentCar].surge_charge[0]['amount'].toString())).roundToDouble();
      }else{
        surge = 0;
      }
    }*/
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(getWidth(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text(getTranslated(context, "CONFIRM_RIDE")!,
                      fontSize: 10.sp,
                      fontFamily: fontMedium,
                      textColor: Colors.black),
                  Divider(),
                  boxHeight(10),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration:
                        boxDecoration(radius: 100, bgColor: Colors.green),
                      ),
                      boxWidth(10),
                      Expanded(
                          child: text(pickupCon.text,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        child: Image.asset(
                          vehicleType == 0 ?
                          "assets/cars/car1.png"
                          :"assets/cars/car2.png",
                          height: 30,
                          width: 30,
                        ),
                      ),
                      text(vehicleType == 0 ?
                          "Bike"
                      : carRentList[timeIndex].carModel != null ?
                      carRentList[timeIndex].carModel.toString()
                      : "",
                          fontSize: 10.sp,
                          fontFamily: fontRegular,
                          textColor: Colors.black),
                      // text(
                      //     "₹" + rentList[0].hoursData![timeIndex].fixedAmount!,
                      //     fontSize: 10.sp,
                      //     fontFamily: fontMedium,
                      //     textColor: Colors.black),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  // boxHeight(10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     text("${getTranslated(context, "PAYMENT_MODE")} : ",
                  //         fontSize: 10.sp,
                  //         fontFamily: fontMedium,
                  //         textColor: Colors.black),
                  //     text(paymentType,
                  //         fontSize: 10.sp,
                  //         fontFamily: fontMedium,
                  //         textColor: Colors.black),
                  //   ],
                  // ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      text(
                      'Start Time - ${DateFormat.jm().format(bookingDate!)}',
                        // getTranslated(context, "START_NOW")!,
                        fontSize: 9.sp,
                        fontFamily: fontMedium,
                        textColor: MyColorName.appbarBg,
                      ),
                      vehicleType == 0 ?
                      text(
                        "${getTranslated(context, "END_TIME")} - ${DateFormat.jm().format(bookingDate!.add(Duration(minutes: int.parse(bikeRentList[0].hoursData![bikeIndex].hours.toString()))))}",
                        fontSize: 9.sp,
                        fontFamily: fontMedium,
                        textColor: MyColorName.appbarBg,
                      )
                     : text(
                        "${getTranslated(context, "END_TIME")} - ${DateFormat.jm().format(bookingDate!.add(Duration(minutes: int.parse(carRentList[timeIndex].hoursData![0].hours.toString()))))}",
                        fontSize: 9.sp,
                        fontFamily: fontMedium,
                        textColor: MyColorName.appbarBg,
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "TOTAL")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(
                          vehicleType == 0 ?
                          "₹" + double.parse(bikeRentList[0].hoursData![bikeIndex].fixedAmount.toString()).toStringAsFixed(2)
                          : "₹" + double.parse(carRentList[timeIndex].hoursData![0].fixedAmount.toString()).toStringAsFixed(2),
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "CANCEL_CHARGE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(
                          vehicleType == 0 ?
                          "₹" + bikeRentList[0].cancellationCharges.toString()
                          :  "₹" + carRentList[timeIndex].cancellationCharges.toString(),
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black)

                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context1);
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          decoration:
                          boxDecoration(radius: 5, bgColor: Colors.grey),
                          child: Center(
                              child: text(getTranslated(context, "CANCEL")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            loadingRental = true;
                          });
                          Navigator.pop(context1);
                          // if(totalBal > 0){
                            addRides();
                          // }else{

                          //   setSnackbar("User not allowed! wallet balance is low", context);
                          // }

                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          decoration: boxDecoration(
                              radius: 5,
                              bgColor: Theme.of(context).primaryColor),
                          child:
                          Center(
                              child:
                              text(getTranslated(context, "CONFIRM")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
  double gst = 0.0;
  double surge = 0.0;

  addRides() async {
    try {
      setState(() {
        saveStatus = false;
        loadingRental = true;
      });
      Map params = {
        "user_id": curUserId,
        "username": name,
        "pickup_address": pickupCon.text,
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "taxi_type": vehicleType == 0 ? "Bike"
        : carRentList[timeIndex].cartype,
        "cancel_charge":  vehicleType == 0 ?
            bikeRentList[0].cancellationCharges.toString()
        : carRentList[timeIndex].cancellationCharges.toString(),
        "hours": vehicleType == 0?
        bikeRentList[0].hoursData![bikeIndex].hours.toString()
        : carRentList[timeIndex].hours.toString(),
        "start_time":
        //bookingTime.toString(),
        DateFormat.jm().format(bookingDate!),
        "end_time": vehicleType == 0 ?
        DateFormat.jm().format(bookingDate!.add(Duration(minutes: int.parse(bikeRentList[0].hoursData![bikeIndex].hours.toString()))))
        :  DateFormat.jm().format(bookingDate!.add(Duration(minutes: int.parse(bikeRentList[timeIndex].hoursData![0].hours.toString())))),
        "delivery_type": vehicleType == 0 ? "1" : "2",
        //rentList[timeIndex].cartype!=""&&rentList[timeIndex].cartype!="Bike"?"2":"1",
        "taxi_id": vehicleType == 0 ?
        bikeRentList[0].cabId : carRentList[timeIndex].cabId,
        "amount": vehicleType == 0 ?
        bikeRentList[0].hoursData![bikeIndex].fixedAmount.toString() : carRentList[0].hoursData![timeIndex].fixedAmount.toString(),
        "paid_amount": vehicleType == 0 ?
        bikeRentList[0].hoursData![bikeIndex].fixedAmount.toString() : carRentList[0].hoursData![timeIndex].fixedAmount.toString()
      };
      print(params);
      //  return;
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/rental_booking_trip"), params);
      setState(() {
        saveStatus = true;
        loadingRental = false;
      });
      if (response['status']) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RentalRides(selected: false,)));
        setSnackbar("Booking Confirmed", context);
      } else {
        setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
        loadingRental = false;
      });
    }
  }
}
