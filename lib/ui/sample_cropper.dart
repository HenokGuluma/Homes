import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:instagram_clone/ui/image_zoomer.dart';
import 'package:image/image.dart' as Im;

class SampleCropper extends StatefulWidget {
  Uint8List thumbnail;
  File imageFile;
  File sample;
  double aspectRatio;
  bool original;
  DocumentReference reference;
  SampleCropper(
      {this.reference,
      this.original,
      this.thumbnail,
      this.aspectRatio,
      this.imageFile,
      this.sample});
  @override
  _SampleCropperState createState() => new _SampleCropperState();
}

class _SampleCropperState extends State<SampleCropper> {
  final cropKey = GlobalKey<CropState>();
  File _file;
  File _sample;
  File _lastCropped;
  bool loading = false;

  @override
  void dispose() {
    super.dispose();
    _file?.delete();
    _sample?.delete();
    _lastCropped?.delete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
            /*SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child:  _buildCroppingImage(),
        ),
      ),*/
            Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            brightness: Brightness.dark,
            toolbarHeight: 40,
            centerTitle: true,
            title: SelectableText(
              'Crop your picture',
              style: TextStyle(
                  fontFamily: 'Muli', color: Colors.white, fontSize: 16),
            ),
          ),
          body: _buildCroppingImage(),
          backgroundColor: Colors.black,
        ));
  }

  Widget _buildOpeningImage() {
    return Center(child: _buildOpenImage());
  }

  Future<double> getAspectRatio(File imageFile) async {
    double aspectRatio;
    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    aspectRatio = decodedImage.width / decodedImage.height;
    return aspectRatio;
  }

  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(widget.sample, key: cropKey),
        ),
        Container(
          padding: const EdgeInsets.only(top: 30.0, bottom: 10),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 90.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                        color: Color(0xff00ffff),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: Color(0xff00ffff))),
                    child: Center(
                      child: SelectableText('Back',
                          style: TextStyle(
                              fontFamily: 'Muli', color: Colors.black)),
                    ),
                  )),
              loading
                  ? TextButton(
                      onPressed: null,
                      child: Container(
                        width: 90.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                            color: Color(0xff009999),
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(color: Color(0xff009999))),
                        child: Center(
                          child: SelectableText('Next',
                              style: TextStyle(
                                  fontFamily: 'Muli', color: Colors.black)),
                        ),
                      ))
                  : TextButton(
                      child: Container(
                        width: 90.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                            color: Color(0xff00ffff),
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(color: Color(0xff00ffff))),
                        child: Center(
                          child: SelectableText('Next',
                              style: TextStyle(
                                  fontFamily: 'Muli', color: Colors.black)),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          loading = true;
                        });
                        _cropImage().then((value) {
                          getAspectRatio(_lastCropped).then((aspect) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // builder: ((context) => ImageZoomer(imageFile: image, original: widget.original, reference: widget.reference,))
                                // ignore: missing_return
                                builder: (_) {
                                  return ImageZoomer(
                                      imageFile: _lastCropped,
                                      original: widget.original,
                                      reference: widget.reference,
                                      thumnailFile: widget.thumbnail,
                                      aspectRatio: aspect);
                                  // If this is an image, navigate to ImageScreen
                                  //return ImageScreen(imageFile: asset.file);
                                },
                              ),
                            );
                          });
                        });
                      }),
            ],
          ),
        )
      ],
    );
  }

  Future<File> getFile(Uint8List images) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(images);
    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 100));

    return newim2;
  }

  Widget _buildOpenImage() {
    return FlatButton(
      child: SelectableText(
        'Open Image',
        style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
      ),
      onPressed: () => _openImage(),
    );
  }

  Future<void> _openImage() async {
    final file = await ImagePicker.pickImage(source: ImageSource.gallery);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: context.size.longestSide.ceil(),
    );

    _sample?.delete();
    _file?.delete();

    setState(() {
      _sample = sample;
      _file = file;
    });
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: widget.imageFile,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    _lastCropped?.delete();
    _lastCropped = file;

    debugPrint('$file');
  }
}
