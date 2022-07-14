import 'package:flutter/material.dart';

class InstaActivityScreen extends StatefulWidget {
  @override
  _InstaActivityScreenState createState() => _InstaActivityScreenState();
}

class _InstaActivityScreenState extends State<InstaActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xff333333),
        toolbarHeight: 40.0,
        centerTitle: false,
        title: SelectableText('Notification',
            style: TextStyle(fontFamily: 'Muli', color: Colors.white)),
      ),
      body: Center(
        child: SelectableText('NOT IMPLEMENTED YET',
            style: TextStyle(fontFamily: 'Muli', color: Colors.white)),
      ),
    );
  }
}
