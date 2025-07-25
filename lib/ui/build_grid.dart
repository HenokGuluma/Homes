import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:image_gallery/image_gallery.dart';

import 'package:flutter/material.dart';

class BuildGrid extends StatefulWidget {
  @override
  _BuildGridState createState() => _BuildGridState();
}

class _BuildGridState extends State<BuildGrid> {
  Map<dynamic, dynamic> allImageInfo = new HashMap();
  List allImage = new List();
  List allNameList = new List();

  @override
  void initState() {
    super.initState();
    loadImageList();
  }

  Future<void> loadImageList() async {
    Map<dynamic, dynamic> allImageTemp;
    allImageTemp = await FlutterGallaryPlugin.getAllImages;
    print(" call $allImageTemp.length");

    setState(() {
      this.allImage = allImageTemp['URIList'] as List;
      this.allNameList = allImageTemp['DISPLAY_NAME'] as List;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
        maxCrossAxisExtent: 150.0,
        // padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: _buildGridTileList(allImage.length));
  }

  List<Container> _buildGridTileList(int count) {
    return List<Container>.generate(
        count,
        (int index) => Container(
                child: new Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.file(
                  File(allImage[index].toString()),
                  width: 96.0,
                  height: 96.0,
                  fit: BoxFit.contain,
                ),
                Text(allNameList[index])
              ],
            )));
  }
}
