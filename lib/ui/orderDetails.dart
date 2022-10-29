import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/activity_model.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user_data.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/ui/comments_screen.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/listing_details.dart';
import 'package:instagram_clone/ui/listing_details_temp.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderDetails extends StatefulWidget {
  final String currentUserId;
  final UserVariables variables;
  DocumentSnapshot order;

  OrderDetails({this.currentUserId, this.variables, this.order});

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  User _currentUser = User();
  bool loading = true;
  bool ordering = false;
  Map<String, bool> followStatus = Map();
  TabController _tabController;
  List<DocumentSnapshot> notificationItems = [];
  ScrollController _scrollController = ScrollController();
  bool telebirr = true;
  List<dynamic> item_list = [];
  
  List<String> names = [
    'Daniel',
    'Solomon',
    'Abraham',
    'Mikias',
    'Mahlet',
    'Birhanu',
    'Zelalem'
  ];
 

  @override
  bool get wantKeepAlive => true;

  List<Activity> _activities = [];
  var _repository = Repository();
  String remark;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    item_list = widget.order.data()['order'];
    getNotifications();
    remark =  DateTime.now().millisecondsSinceEpoch.toString() + widget.variables.currentUser.uid.substring(0, 4);
  }

  getNotifications() {
    _repository.getCurrentUser().then((user) {
      _repository.getNotifications(user.uid).then((notifications) {
        setState(() {
          notificationItems = notifications;
          loading = false;
        });
      });
    });
  }

  Widget telebirrWidget(var width, var height, UserVariables variables){
    return Container(
      width: width*0.9,
      height: height*0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(height: 20,),
          Container(
            width: width*0.8,
            child: Text('Complete your payment by going to Telebirr app and sending the following amount along with the remark given below to the mobile number indicated'
          ,style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal, fontFamily: 'Muli'),
          ),
          ),
          SizedBox(height: 10,),
          Text('Mobile Number: 0945710635'
          ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          ),
          SizedBox(height: 5,),
          SelectableText('Amount: ' + (widget.order.data()['price']).toString() + ' ETB'
          ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          ),
           SizedBox(height: 5,),
          SelectableText('Remark: ' + remark ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          )
        ],
      ),
    );
  }

  Widget paidWidget(var width, var height, UserVariables variables){
    return Container(
      width: width*0.9,
      height: height*0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(height: 20,),
          Container(
            width: width*0.8,
            child: Text('You have completed your payment. You will receive the keys you purchased in your wallet soon. If you want to check with us, feel free to call us in the phone number below.'
          ,style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal, fontFamily: 'Muli'),
          ),
          ),
          SizedBox(height: 10,),
          Text('Mobile Number: 0945710635'
          ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          ),
         
        ],
      ),
    );
  }

  void showFloatingFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 0,
      //flushbarPosition: FlushbarPosition.,
      backgroundGradient: LinearGradient(
        colors: [Color(0xfff2029e), Color(0xfff2029e)],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      messageText: Center(
          child: Text(
        'This item has been removed from your cart.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.white),
      )),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    var variables = widget.variables;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Color(0xfff1f1f1),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          toolbarHeight: 40,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 20, color: Colors.white,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text('Order Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Muli'),),
        ),
        body: Container(
          height: height * 0.9,
          color: Color(0xfff1f1f1),
          child: Column(
            children: [
             
              Container(
                height: height * 0.88,
                child:
              Container(
                height: height * 0.88,
                color: Color(0xfff1f1f1),
                child: ListView.builder(
                                  cacheExtent: 50000000,
                                  itemCount: 3,
                                  controller: _scrollController,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    
                                    return shoppingItem(width, height, variables, index);
                                    //return CircularProgressIndicator();
                                  },
                                )
                
              ),
          )],
          ),
        ));
  }


  Widget checkOut(var variables, var height, var width){
    return Container(
                child: Column(
                  children: [
                    Container(
                      width: width*0.9,
                      height: height*0.25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          
                          Center(
                  child: Column(
                    children: [
                      Text('Your Total Checkout Price is ', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.normal), textAlign: TextAlign.center,),
                      SizedBox(height: 5,),
                      Text((widget.order.data()['price']).toString() +' ETB', style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900), textAlign: TextAlign.center,)
                    ],
                  ),
                ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30,),

                  (widget.order.data()['isTelebirr'] && !(widget.order.data()['payment'] || widget.order.data()['deposited'] ))
                    ? telebirrWidget(width, height, variables)
                    :widget.order.data()['payment'] && !widget.order.data()['deposited']
                    ?paidWidget(width, height, variables)
                    :Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                        width: width*0.5,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xff12a458),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Center(
                          child: Text('Delivered', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w700),),
                        ),
                      ),
                      Container(
                        width: width*0.5,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Center(
                          child: Text('Delivered on '+  DateFormat('MM/dd/yyyy').format(DateTime.fromMicrosecondsSinceEpoch(widget.order.data()['deliveryTime'])), style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Muli', fontWeight: FontWeight.w600),),
                        ),
                      ),
                        ],
                      )
                    ),

                    SizedBox(height: 30,),

                    SizedBox(height: 30,)
                  ],
                )
              );
  }

  Widget titleWidget(var variables, var width, var height){
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 20),
      child:  Column(
        children: [
          SizedBox(height: 20,),
         
          Text('Ordered items', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Muli'),),
         
        ],
      ));
  }

  Widget shoppingItem(
      var width, var height, UserVariables variables, int index) {
    if (index == 2){
      print('kabooooom');
      return Padding(
        padding: EdgeInsets.only(top: 20),
        child: checkOut(variables, height, width),
      );
      // return Center();
    }
    else if(index==0){
      return titleWidget(variables, width, height);
    }
    else{
      print('kablaam');
      return GestureDetector(
        onTap: () async {
          
        },
        child:
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child:  
         Container(
          
          width: width*0.9,
          height: height*0.1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width*0.6,
                    child: Text(widget.order.data()['amount'].toString() + ' Keys', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Muli'), overflow: TextOverflow.clip, textAlign: TextAlign.start,),
                  
                  ),
                  ],
              ),
             
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.order.data()['price'].toString() + ' ETB', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli', fontWeight: FontWeight.w900),),
              
                ],
              ),
              SizedBox(width: 10,),
              ],
          ),
        )
        )
        
        );
    }
    
  }

  Widget notifications(String text, var icon, var width, var height,
      var visible, var variables) {
    return Container(
        child: visible
            ? loading
                ? Center(
                    child: JumpingDotsProgressIndicator(
                      fontSize: 50.0,
                      color: Color(0xfff2029e),
                    ),
                  )
                : notificationItems.length == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'No ' + text + ' yet.',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'We will let you know when you have one.',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              getNotifications();
                            },
                            child: Container(
                              width: width * 0.35,
                              height: height * 0.07,
                              decoration: BoxDecoration(
                                color: Color(0xfff2029e),
                                border: Border.all(color: Color(0xfff2029e)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Refresh',
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xfff000000),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: height * 0.75,
                        child: RefreshIndicator(
                            onRefresh: () {
                              getNotifications();
                              return Future.delayed(Duration(seconds: 2));
                            },
                            backgroundColor: Colors.black,
                            color: Color(0xfff2029e),
                            child: Center(
                              child: Container(
                                width: width * 0.95,
                                height: height * 0.75,
                                child: ListView.builder(
                                  cacheExtent: 50000000,
                                  itemCount: item_list.length,
                                  controller: _scrollController,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // return shoppingItem(item_list[index], width, height, variables, index, );
                                    //return CircularProgressIndicator();
                                  },
                                ),
                              ),
                            )))
            : Center());
  }
}
