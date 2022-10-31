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

class PayForKeys extends StatefulWidget {
  final String currentUserId;
  final UserVariables variables;
  int keys;
  double SubTotal;

  PayForKeys({this.currentUserId, this.variables, this.SubTotal, this.keys});

  @override
  _PayForKeysState createState() => _PayForKeysState();
}

class _PayForKeysState extends State<PayForKeys>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  User _currentUser = User();
  bool loading = true;
  bool ordering = false;
  Map<String, bool> followStatus = Map();
  TabController _tabController;
  List<DocumentSnapshot> notificationItems = [];
  ScrollController _scrollController = ScrollController();
  bool telebirr = true;
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
          SelectableText('Amount: ' + (widget.SubTotal).toString()
          ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          ),
           SizedBox(height: 5,),
          SelectableText('Remark: ' + remark ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          )
        ],
      ),
    );
  }

  Widget bankTransferWidget(var width, var height, UserVariables variables){
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
            child: Text('Complete your payment by transferring the following amount along with the remark given below to the bank account indicated'
          ,style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal, fontFamily: 'Muli'),
          ),
          ),
          SizedBox(height: 10,),
          Text('Bank Account: 1000109485725'
          ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          ),
          SizedBox(height: 5,),
          SelectableText('Amount: ' + (widget.SubTotal).toString()
          ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          ),
           SizedBox(height: 5,),
          SelectableText('Remark: ' + remark ,style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Muli'),
          )
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
        colors: [Color(0xff00ffff), Color(0xff00ffff)],
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
          title: Text('Payment Methods', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Muli'),),
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

  Future<void> addOrder()async{
    _repository.addOrder(widget.variables.currentUser, widget.keys, widget.SubTotal.toInt(), remark, telebirr);
   return;
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('   SubTotal: ', style: TextStyle(color: Color(0xff444444), fontFamily: 'Muli', fontSize: 18),),
                              Text((widget.SubTotal).toString() + ' ETB     ', style: TextStyle(color: Color(0xff444444), fontFamily: 'Muli', fontSize: 18),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('    Extra Charges: ', style: TextStyle(color: Color(0xff444444), fontFamily: 'Muli', fontSize: 18),),
                              Text((widget.SubTotal*0).toString() + ' ETB     ', style: TextStyle(color: Color(0xff444444), fontFamily: 'Muli', fontSize: 18),)
                            
                            ],
                          ),
                          Center(
                  child: Column(
                    children: [
                      Text('Your Total Checkout Price is ', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.normal), textAlign: TextAlign.center,),
                      Text((widget.SubTotal).toString() +' ETB', style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900), textAlign: TextAlign.center,)
                    ],
                  ),
                ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30,),

                    telebirr? telebirrWidget(width, height, variables):bankTransferWidget(width, height, variables),

                    SizedBox(height: 30,),

                    Center(
                      child: MaterialButton(
                        onPressed: (){
                          showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            title: new Text(
                              'Placing Order',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            content: new Text(
                              'Are you sure you want to place your order?',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                //  loggingOutDialog();
                                 setState(() {
                            ordering = true;
                           });
                          addOrder().then((value) {
                            setState(() {
                            ordering = false;
                           });
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => InstaHomeScreen())),
                              (Route<dynamic> route) => false,
                            );
                             Fluttertoast.showToast(
                                msg:
                                    'You have successfully placed your order.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Color(0xff00ffff),
                                textColor: Colors.black);
                            
                          });
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));

                         
                        },
                        child: Container(
                        width: width*0.6,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ordering?Color(0xff888888):Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(ordering?'Placing order...':'Buy Now', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 18),),
                        ),
                      ),
                      )
                    ),
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
          Center(
                child: Text('Choose your payment method.'
                , style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Muli'),),
              ),
          SizedBox(height: 20,),
          Container(
            width: width*0.9,
            height: height*0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 5,),
                    Checkbox(
                    value: telebirr,
                    onChanged: (value) {
                      setState(() {
                        telebirr = value;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Colors.black,
                    focusColor: Colors.black,
                  ),
                  SizedBox(width: 5,),
                  Image.asset('assets/telebirr.png', width: width*0.08),
                  SizedBox(width: 15,),
                  Text('Pay with Telebirr', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli'),)
                  ],
                ),
                Row(
                  children: [
                    SizedBox(width: 5,),
                    Checkbox(
                    value: !telebirr,
                    onChanged: (value) {
                      setState(() {
                        telebirr = !value;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Colors.black,
                    focusColor: Colors.black,
                  ),
                  SizedBox(width: 5,),
                  Image.asset('assets/delivery.png', width: width*0.08),
                  SizedBox(width: 15,),
                  Text('Pay via Bank Transfer', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli'),)
                  ],
                ),
              ],
            ),
          ), 
          SizedBox(height: 10,),
          Text('Your items', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Muli'),),
         
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
                    child: Text(widget.keys.toString() + ' Keys', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Muli'), overflow: TextOverflow.clip, textAlign: TextAlign.start,),
                  
                  ),
                  ],
              ),
             
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.SubTotal.toString() + ' ETB', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli', fontWeight: FontWeight.w900),),
              
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
                                  itemCount: variables.tempItems.length,
                                  controller: _scrollController,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // return shoppingItem(variables.tempItems[index], width, height, variables, index, );
                                    //return CircularProgressIndicator();
                                  },
                                ),
                              ),
                            )))
            : Center());
  }
}
