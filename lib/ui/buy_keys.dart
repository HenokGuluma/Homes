import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/pay_for_keys.dart';
import 'package:provider/provider.dart';

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
  bool like;
  int counter = 0;
  List<Map<String, int>> options = [
    {'amount': 1, 'price': 40},
    {'amount': 3, 'price': 90},
    {'amount': 5, 'price': 150},
    {'amount': 10, 'price': 200}
  ];
  Map<int, double> optionsMap = {1: 25, 3: 50, 5: 75, 10: 100};

  List<bool> balls = [true, true, true, true, true];

  @override
  void initState() {
    super.initState();
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
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
              height: width * 0.8,
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
          ))
        ]));
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
            width: width * 0.3,
            height: width * 0.3,
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
