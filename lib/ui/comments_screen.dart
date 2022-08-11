import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/repository.dart';

import 'package:progressive_image/progressive_image.dart';

class CommentsScreen extends StatefulWidget {
  final DocumentReference documentReference;
  final User user;
  final int likecount;
  CommentsScreen({this.documentReference, this.user, this.likecount});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _commentController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var _repository = Repository();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _commentController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        brightness: Brightness.dark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1,
        toolbarHeight: 40.0,
        backgroundColor: new Color(0xff1a1a1a),
        title: Text(
          'Comments',
          style: TextStyle(fontFamily: 'Muli', color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            commentsListWidget(),
            Divider(
              height: 20.0,
              color: Colors.grey,
            ),
            commentInputWidget()
          ],
        ),
      ),
    );
  }

  Widget commentInputWidget() {
    return Container(
      height: 55.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Container(
              child:
                  Center() /* CachedNetworkImage(
            imageUrl: widget.user.photoUrl,
            imageBuilder: (context, imageProvider) => Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  image: DecorationImage(
                      image: AssetImage('assets/no_image.png'),
                      fit: BoxFit.cover),
                )),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ) */
              ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextFormField(
                style: TextStyle(fontFamily: 'Muli', color: Colors.white),
                validator: (String input) {
                  if (input.isEmpty) {
                    return "Please enter comment";
                  }
                },
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  hintStyle: TextStyle(fontFamily: 'Muli', color: Colors.white),
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: Text('Post',
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Color(0xff00ffff),
                      fontSize: 16)),
            ),
            onTap: () {
              if (_formKey.currentState.validate()) {
                postComment();
              }
            },
          )
        ],
      ),
    );
  }

  postComment() {
    FocusScope.of(context).unfocus();
    _repository.commentOnPost(widget.user, widget.documentReference,
        _commentController.text, widget.user.photoUrl);
    _commentController.clear();
    print("nigga attempted this shit");
  }

  Widget commentsListWidget() {
    print("Document Ref : ${widget.documentReference.path}");
    return Flexible(
      child: StreamBuilder(
        stream: widget.documentReference
            .collection("comments")
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xff00ffff))));
          } else {
            if (snapshot.data.size == 0) {
              return Center(
                  child: Text(
                "No comments yet",
                style: TextStyle(fontFamily: 'Muli', color: Colors.white),
              ));
            } else {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: ((context, index) =>
                    commentItem(snapshot.data.docs[index])),
              );
            }
          }
        }),
      ),
    );
  }

  Widget commentItem(DocumentSnapshot snapshot) {
    //   var time;
    //   List<String> dateAndTime;
    //   print('${snapshot.data['timestamp'].toString()}');
    //   if (snapshot.data['timestamp'].toString() != null) {
    //       Timestamp timestamp =snapshot.data['timestamp'];
    //  // print('${timestamp.seconds}');
    //  // print('${timestamp.toDate()}');
    //    time =timestamp.toDate().toString();
    //    dateAndTime = time.split(" ");
    //   }

    if (snapshot.data()['authorId'] != "Trendin") {
      return Padding(
        padding: const EdgeInsets.only(
            left: 5, top: 12.0, right: 12.0, bottom: 12.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xff00ffff)),
                  image: DecorationImage(
                    image: ProgressiveImage(
                      placeholder: AssetImage('assets/no_image.png'),
                      // size: 1.87KB
                      //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                      thumbnail: AssetImage('assets/grey.png'),
                      // size: 1.29MB
                      image: NetworkImage(snapshot.data()['authorPhoto']),
                      fit: BoxFit.cover,
                      width: 30,
                      height: 30,
                    ).image,
                    fit: BoxFit.cover,
                  ),
                ),
                width: 30,
                height: 30,
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            /*Row(
              children: <Widget>[
                Text(snapshot.data()['authorId'],
                    style: TextStyle( fontFamily: 'Muli', 
                      fontWeight: FontWeight.bold,
                      color: Colors.white, fontSize: 16.0
                    )),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Expanded(
                      child: Text(snapshot.data()['content'],
                        style: TextStyle( fontFamily: 'Muli', color: Colors.white, fontSize: 16.0),
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.justify,
                      ),
                    )),
                */ /*Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(snapshot.data()['content'], style: TextStyle( fontFamily: 'Muli', color: Colors.white),),
                ),*/ /*
              ],
            )*/
            Flexible(
              child: Container(
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 70),
                child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: snapshot.data()['authorName'] + ': ',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: snapshot.data()['content'],
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w300)),
                  ]),
                  //Text(snapshot.data()['content'],
                  overflow: TextOverflow.clip,
                  //textAlign: TextAlign.justify,
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
