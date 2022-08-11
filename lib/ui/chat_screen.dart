import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/chat_detail_screen.dart';

import 'package:progressive_image/progressive_image.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var _repository = Repository();
  User _user = User();
  List<User> usersList = List<User>();

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      _repository.fetchAllUsers(user).then((updatedList) {
        setState(() {
          usersList = updatedList;
        });
      });
    });
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
          backgroundColor: Color(0xff1a1a1a),
          title: Text(
            'Direct Message',
            style: TextStyle(fontFamily: 'Muli', color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: SvgPicture.asset("assets/search.svg",
                  width: 18, height: 18, color: Color(0xff00ffff)),
              onPressed: () {
                /* showSearch(
                    context: context,
                    delegate: shownSearch(usersList: usersList)); */
              },
            )
          ],
        ),
        body: ListView.builder(
          itemCount: usersList.length,
          itemBuilder: ((context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => ChatDetailScreen(
                                photoUrl: usersList[index].photoUrl,
                                name: usersList[index].displayName,
                                receiverUid: usersList[index].uid,
                              ))));
                },
                child: ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(left: 10),
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
                            image: NetworkImage(usersList[index].photoUrl),
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
                  //usersList[index].photoUrl

                  title: Text(
                    usersList[index].displayName,
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        ));
  }
}

class ChatSearch extends SearchDelegate<String> {
  List<User> usersList;
  ChatSearch({this.usersList});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<User> suggestionsList = query.isEmpty
        ? usersList
        : usersList.where((p) => p.displayName.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: ((context, index) => ListTile(
            onTap: () {
              //   showResults(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => ChatDetailScreen(
                            photoUrl: suggestionsList[index].photoUrl,
                            name: suggestionsList[index].displayName,
                            receiverUid: suggestionsList[index].uid,
                          ))));
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(suggestionsList[index].photoUrl),
            ),
            title: Text(suggestionsList[index].displayName,
                style: TextStyle(fontFamily: 'Muli', color: Colors.white)),
          )),
    );
  }
}
