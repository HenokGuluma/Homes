import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/repository.dart';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';

class AddText extends StatefulWidget {
  DocumentReference reference;
  bool original;

  AddText({this.reference, this.original});

  @override
  AddTextState createState() => AddTextState();
}

class AddTextState extends State<AddText> with AutomaticKeepAliveClientMixin {
  TextEditingController textController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var _repository = Repository();
  String text1 =
      'I was crying and my bf said "look at yourself. You are wearing your big hoops and this is not big hoop attitude" you right boo';
  String text2 =
      "There is nothing better than showering and putting on a big tshirt and getting into bed with clean sheets, literally nothing. Don't fight me on this.";
  String text3 =
      "I love it when someone's laugh is funnier than the actual joke.";
  String text4 =
      "I didn't see my boyfriend for 3 days and when we sat down to eat at this restaurant he pulls out a piece of paper and said 'I had so much tea to spill and I didn't want to forget any details' lmaoooo";
  String text5 =
      "I love when someone opens up to me and call me nicknames on their own and just like me. It is such a great fucking feeling";
  String text6 =
      "Bitch no offense but money would solve literally every single one of my problems. Like all of them. I don't have a single problem that money wouldn't immediately solve.";
  List<String> tweets = List<String>();
  bool posted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tweets.add(text1);
    tweets.add(text2);
    tweets.add(text3);
    tweets.add(text4);
    tweets.add(text5);
    tweets.add(text6);
  }

  @override
  void dispose() {
    super.dispose();
    textController?.dispose();
  }

  void showFloatingFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 8,
      //flushbarPosition: FlushbarPosition.,
      backgroundGradient: LinearGradient(
        colors: [Color(0xff00ffff), Color(0xff00ffff)],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      messageText: Center(
          child: SelectableText(
        'Enter text before posting',
        style: TextStyle(fontFamily: 'Muli', color: Colors.black),
      )),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              top: 100,
                              left: MediaQuery.of(context).size.width * 0.8,
                              bottom: 20),
                          child: posted
                              ? Container(
                                  width: 60.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                      color: Color(0xff009999),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border:
                                          Border.all(color: Color(0xff009999))),
                                  child: Center(
                                    child: SelectableText('Post',
                                        style: TextStyle(
                                            fontFamily: 'Muli',
                                            color: Colors.black,
                                            fontSize: 16)),
                                  ),
                                )
                              : GestureDetector(
                                  child: Container(
                                    width: 60.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                        color: Color(0xff00ffff),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                            color: Color(0xff00ffff))),
                                    child: Center(
                                      child: SelectableText('Post',
                                          style: TextStyle(
                                              fontFamily: 'Muli',
                                              color: Colors.black,
                                              fontSize: 16)),
                                    ),
                                  ),
                                  onTap: () {
                                    if (textController.text == '') {
                                      showFloatingFlushbar(context);
                                    } else {
                                      setState(() {
                                        posted = true;
                                      });
                                      _repository
                                          .getCurrentUser()
                                          .then((currentUser) {
                                        if (!widget.original) {
                                          widget.reference.get().then((doc) {
                                            if (currentUser != null) {
                                              _repository
                                                  .retrieveUserDetails(
                                                      currentUser)
                                                  .then((user) {
                                                double bonus =
                                                    doc['trending'] * 0.2;
                                                _repository
                                                    .addTextPostToDb(
                                                        user,
                                                        textController.text,
                                                        20 + bonus.toInt(),
                                                        doc['postOwnerName'],
                                                        widget.reference,
                                                        widget.original)
                                                    .then((ref) {
                                                  print("Post added to db");
                                                  _repository.followTextTrend(
                                                      user,
                                                      widget.reference,
                                                      ref);
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: ((context) =>
                                                            InstaHomeScreen())),
                                                    (Route<dynamic> route) =>
                                                        false,
                                                  );
                                                });
                                              });
                                            } else {
                                              print("Current User is null");
                                            }
                                          });
                                        } else {
                                          if (currentUser != null) {
                                            _repository
                                                .retrieveUserDetails(
                                                    currentUser)
                                                .then((user) {
                                              _repository.addTextPostToDb(
                                                  user,
                                                  textController.text,
                                                  20,
                                                  null,
                                                  widget.reference,
                                                  widget.original);
                                              print("Post added to db");
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: ((context) =>
                                                        InstaHomeScreen())),
                                                (Route<dynamic> route) => false,
                                              );
                                            });
                                          } else {
                                            print("Current User is null");
                                          }
                                        }
                                      });
                                    }
                                  },
                                ))
                    ]),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      constraints: BoxConstraints(
                          minWidth: 300,
                          maxWidth: 400,
                          minHeight: 80,
                          maxHeight: 300),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border:
                              Border.all(color: Color(0xff00ffff), width: 1),
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: AutoSizeTextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: "Enter a text trend",
                            hintStyle: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.grey,
                                fontSize: 22),
                            fillColor: Colors.white,
                          ),
                          fullwidth: true,
                          minFontSize: 13,
                          maxLines: 5,
                          maxLength: 250,
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.white,
                              fontSize: 17),
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.multiline,
                          /*onChanged: ((value) {
                      textController.value = TextEditingValue(
                        text: value,
                        selection: TextSelection.collapsed(offset: value.length),
                      );
                    }),*/
                        ),
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1,
                      left: 20,
                      right: 20),
                  child: Center(
                    child: SelectableText(
                        "Ideas keep flowing each day. What are your thoughts today?",
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 18)),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: GridView.builder(
                      //  shrinkWrap: true,
                      itemCount: 6,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio: 2),
                      itemBuilder: ((context, index) {
                        return Stack(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width / 2 - 2,
                              height: MediaQuery.of(context).size.width / 4,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Color(0xff00ffff))),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 2, right: 2),
                                  child: SelectableText(tweets[index],
                                      style: TextStyle(
                                          fontFamily: 'Muli',
                                          color: Colors.white,
                                          fontSize: 9)),
                                ),
                              ),
                            ),
                            /*Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/2 -100.0, top: MediaQuery.of(context).size.width/2 -125, bottom: 5.0, right: 5),
                              child:SelectableText("Trending 1200", style: TextStyle( fontFamily: 'Muli', color: Color(0xff00ffff), fontSize: 14,),
                              )
                          )*/
                          ],
                        );
                      })),
                )
                /* */
              ],
            ),
          ),
        ));
  }
}
