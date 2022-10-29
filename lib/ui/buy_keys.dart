import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/orderDetails.dart';
import 'package:instagram_clone/ui/pay_for_keys.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class BuyKeys extends StatefulWidget {
  final UserVariables variables;

  BuyKeys({this.variables});

  @override
  BuyKeysState createState() => BuyKeysState();
}

class BuyKeysState extends State<BuyKeys> {
  File _image;
  File imageFile;
  final picker = ImagePicker();
  Repository _repository = Repository();
  bool like;
  int counter = 0;
  List<Map<String, int>> options = [
    {'amount': 1, 'price': 40},
    {'amount': 3, 'price': 90},
    {'amount': 5, 'price': 120},
    {'amount': 10, 'price': 200}
  ];
  Map<int, double> optionsMap = {1: 25, 3: 50, 5: 75, 10: 100};

  List<bool> balls = [true, true, true, true, true];
  List<DocumentSnapshot> keyOrderList = [];

  @override
  void initState() {
    super.initState();
    _repository.getOrderHistory(widget.variables.currentUser.uid).then((keyOrders) {
      setState(() {
              keyOrderList = keyOrders;
            });
    });
  }

  @override
  void dispose() {
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      
        appBar: AppBar(
          brightness: Brightness.dark,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
          ),
          toolbarHeight: 50,
          backgroundColor: Colors.black,
          title: Text(
            'Buy Keys',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        backgroundColor: Color(0xffe1e1e1),
        body: ListView(children: [
          SizedBox(height: height * 0.05),
          Center(
              child: Text(
            'Number of keys in your wallet: ' +
                widget.variables.keys.toString(),
            style: TextStyle(
                fontFamily: 'Muli',
                color: Color(0xff444444),
                fontSize: 20,
                fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          )),
          SizedBox(height: height * 0.05),
          Container(
              width: width * 0.8,
              height: width,
              child: Center(
                child: GridView.builder(
                    itemCount: options.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2),
                    cacheExtent: 5000000,

                    // ignore: missing_return
                    itemBuilder: ((context, index) {
                      return UnlockOptions(options[index]['amount'],
                          options[index]['price'], width);
                    })),
              )),
          SizedBox(height: height * 0.01),
          Center(
              child: Text(
            'Select the option you want to proceed with.',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 18),
          )), 
          keyOrderList.length>0
          ?Column(
            children: [
              SizedBox(height: 30,),
              Text(
            'Pending Key Orders',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 18),
          ),
              SizedBox(height: 5,),
              Container(
            width: width,
            height: height*0.3,
            child: ListView.builder(
            //shrinkWrap: true,
          
            itemCount: keyOrderList.length,
            itemBuilder: ((context, index) => listingItem(
                list: keyOrderList,
                index: index,
                width: width,
                height: height,
                variables: widget.variables))),
          )
            ],
          )
          :Center()
        ]));
  }

    Widget listingItem({List<DocumentSnapshot> list, int index, double width, double height, UserVariables variables}){
      var dt = DateTime.fromMillisecondsSinceEpoch(list[index]['time']);
    var date = DateFormat('MM/dd/yyyy').format(dt);
    return GestureDetector(
      onTap: (){
         Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => OrderDetails(
                        currentUserId: variables.currentUser.uid,
                        variables: variables,
                        order: list[index],
                        ))));
      },
       child: Padding(
        padding: EdgeInsets.only(left: width*0.03, right: width*0.03, top: 10, bottom: 10),
        child: Container(
        padding: EdgeInsets.only(left: width*0.03, right: width*0.03),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        width: width * 0.9,
        height: height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: width*0.12,
              height: width*0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: list[index]['user']['photoUrl']!=null
                  ?CachedNetworkImageProvider(list[index]['user']['photoUrl'])
                  :CachedNetworkImageProvider('')
                )
              ),
            ),
            SizedBox(width: width*0.08,),
            Container(
              width: width*0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    list[index]['user']['displayName'],
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    list[index]['amount'].toString() + ' keys, '+ list[index]['price'].toString() + ' ETB',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
              ],
            ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child:Text(
                    date,
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  )),
            )
          ],
        )
        )
    
       ));
  }


  Widget UnlockOptions(int amount, int price, var width) {
    return GestureDetector(
        onTap: () {
          print('The option that you chose is ' + price.toString());
           Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => PayForKeys(variables: widget.variables, SubTotal: price.toDouble(), keys: amount,))));
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: width * 0.25,
            height: width * 0.25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black),
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SvgPicture.asset("assets/key.svg",
                      width: 20, height: 20, color: Colors.yellow),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    amount != 1
                        ? amount.toString() + ' keys'
                        : amount.toString() + ' key',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff00ffff),
                        fontWeight: FontWeight.w900,
                        fontSize: 20),
                  ),
                ]),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'for ' + price.toString() + ' ETB',
                  style: TextStyle(
                      fontFamily: 'Muli', color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ));
  }
}
