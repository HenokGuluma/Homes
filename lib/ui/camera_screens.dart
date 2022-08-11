import 'dart:math';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_crop/image_crop.dart';
import 'package:instagram_clone/ui//preview_screen.dart';
import 'package:instagram_clone/ui/camera_cropper.dart';
import 'package:instagram_clone/ui/image_zoomer.dart';
import 'package:instagram_clone/ui/photo_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
//import 'package:image_cropper/image_cropper.dart';
import 'package:instagram_clone/ui/insta_upload_photo_screen.dart';
import 'package:photo_manager/photo_manager.dart';
//import 'package:image_size_getter/image_size_getter.dart';
//import 'package:image_size_getter/file_input.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
  bool original;
  DocumentReference reference;
  CameraScreen({this.original, this.reference});
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  List cameras;
  int selectedCameraIndex;
  String imgPath;
  File imageFile;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: _cameraPreviewWidget(context),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _cameraToggleRowWidget(),
                      _cameraControlWidget(context),
                      _storageWidget(context),
                      //Spacer()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget(context) {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          fontFamily: 'Muli',
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
    //return CameraPreview(controller);
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Transform.scale(
      scale: controller.value.aspectRatio / deviceRatio,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures
  Widget _cameraControlWidget(context) {
    Future<File> _openImage(File file) async {
      final sample = await ImageCrop.sampleImage(
        file: file,
        preferredSize: context.size.longestSide.ceil(),
      );
      return sample;
    }

    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(
                Icons.camera,
                color: Colors.black,
              ),
              backgroundColor: Color(0xff00ffff),
              onPressed: () {
                _onCapturePressed(context).then((value) {
                  /*_cropImage(imageFile.path).then((croppedImage) {
                    getThumbnail(croppedImage.readAsBytesSync()).then((image) {
                      getAspectRatio(croppedImage).then((aspectRatio) {
                        Navigator.push(context, MaterialPageRoute(
                            builder: ((context) => ImageZoomer(imageFile: croppedImage, original: widget.original, reference: widget.reference, thumnailFile: image, aspectRatio: aspectRatio,))
                        ));
                      });
                    });
                  });*/
                  getThumbnail(imageFile.readAsBytesSync()).then((image) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => ProfileCropper(
                                  original: widget.original,
                                  reference: widget.reference,
                                  thumbnail: image,
                                  imageFile: imageFile,
                                  sample: imageFile,
                                ))));
                  });
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Future<double> getAspectRatio(File imageFile) async {
    double aspectRatio;
    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    aspectRatio = decodedImage.width / decodedImage.height;
    return aspectRatio;
  }

  Future<Uint8List> getThumbnail(Uint8List imageFile) async {
    /*final tempDir = await getTemporaryDirectory();
    Im.Image image = Im.decodeImage(imageFile);
    Im.copyResizeCropSquare(image, 500);
    final path = tempDir.path;
    int rand = Random().nextInt(10000);
    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 3));
    return newim2;*/
    var result = await FlutterImageCompress.compressWithList(
      imageFile,
      quality: 5,
    );
    return result;
  }

  Widget _storageWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton.icon(
                icon: Icon(
                  Icons.sd_storage,
                  color: Colors.white,
                ),
                //backgroundColor: Color(0xff00ffff),
                onPressed: () {
                  /*_getFromGallery().then((value) {
                  getThumbnail(imageFile.readAsBytesSync()).then((image) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: ((context) => ImageZoomer(imageFile: imageFile, original: widget.original, reference: widget.reference, thumnailFile: image,))
                  ));
                  });
                });*/
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => Gallery(
                                original: widget.original,
                                reference: widget.reference,
                              ))));
                },
                label: Text(
                  "Storage",
                  style: TextStyle(
                      fontFamily: 'Muli', color: Colors.white, fontSize: 14.0),
                ))
          ],
        ),
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).

  Widget _cameraToggleRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
          onPressed: _onSwitchCamera,
          icon: Icon(
            _getCameraLensIcon(lensDirection),
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            '${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1).toUpperCase()}',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  Future<Null> _getFromGallery() async {
    var File = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      //maxWidth: 1800,
      //maxHeight: 1800,
    );
    //await _cropImage(File.path);
    setState(() {
      imageFile = File;
    });
  }

  /// Crop Image
  /* Future<File> _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      toolbarColor: Color(0xff00ffff),
      toolbarTitle:"Customize photo",
    );
    //if (croppedImage != null) {
      */ /*setState(() {
        imageFile = croppedImage;
      });*/ /*
    //}
    return croppedImage;
  }*/

  void _showCameraException(CameraException e) {
    String errorText = 'Error:${e.code}\nError message : ${e.description}';
    print(errorText);
  }

  Future _onCapturePressed(context) async {
    try {
      final path =
          join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
      await controller.takePicture(path);

      /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewScreen(
              imgPath: path,
            )),
      );*/
      //await _cropImage(path);
      setState(() {
        imageFile = File(path);
      });
    } catch (e) {
      _showCameraException(e);
    }
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    _initCameraController(selectedCamera);
  }
}
