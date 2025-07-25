import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
//import 'package:image_size_getter/file_input.dart';
//import 'package:image_size_getter/image_size_getter.dart';
import 'package:instagram_clone/ui/chat_screen.dart';
import 'package:instagram_clone/ui/sample_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:instagram_clone/ui/image_zoomer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as Im;
import 'package:instagram_clone/ui/insta_upload_photo_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
  bool original;
  DocumentReference reference;
  Gallery({this.original, this.reference});
}

class _GalleryState extends State<Gallery> {
  // This will hold all the assets we fetched
  List<AssetEntity> assets = [];

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(
        onlyAll: true, type: RequestType.image);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    setState(() => assets = recentAssets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Photo Gallery',
          style: TextStyle(fontFamily: 'Muli', color: Colors.white),
        ),
        backgroundColor: Color(0xff1a1a1a),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // A grid view with 3 items per row
          crossAxisCount: 3,
        ),
        itemCount: assets.length,
        itemBuilder: (_, index) {
          return AssetThumbnail(
            asset: assets[index],
            original: widget.original,
            reference: widget
                .reference, /* original: widget.original, reference: widget.reference,*/
          );
        },
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail(
      {Key key,
      @required this.asset,
      @required this.original,
      @required this.reference})
      : super(key: key);
  final AssetEntity asset;
  final bool original;
  final DocumentReference reference;

  /*Future<File>_cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      toolbarColor: Color(0xff00ffff),
      toolbarTitle:"Customize photo",
    );
    //if (croppedImage != null) {
    //}
    return croppedImage;
  }*/
  // ignore: missing_return
  Future<double> getAspectRatio(File imageFile) async {
    double aspectRatio;
    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    aspectRatio = decodedImage.width / decodedImage.height;
    return aspectRatio;
  }
  /*Future<Null> _getFromGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      //maxWidth: 1800,
      //maxHeight: 1800,
    );
    await _cropImage(pickedFile.path);
  }*/

  @override
  Widget build(BuildContext context) {
    Future<File> _openImage(File file) async {
      final sample = await ImageCrop.sampleImage(
        file: file,
        preferredSize: context.size.longestSide.ceil(),
      );
      return sample;
    }

    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List>(
      future: asset.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return Center();
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            print('stage0');
            asset.file.then((images) {
              _openImage(images).then((value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => SampleCropper(
                              original: original,
                              reference: reference,
                              thumbnail: bytes,
                              imageFile: images,
                              sample: images,
                            ))));
              });
              /*_cropImage(images.path).then((croppedImage) {
                getAspectRatio(croppedImage).then((aspect) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // builder: ((context) => ImageZoomer(imageFile: image, original: widget.original, reference: widget.reference,))
                      // ignore: missing_return
                      builder: (_) {
                        if (asset.type == AssetType.image) {
                          getFile(bytes).then((thumbnail) {
                            return ImageZoomers(imageFile: images, original: original, reference: reference, thumbnailFile: thumbnail);
                          });
                          return ImageZoomer(imageFile: croppedImage, original: original, reference: reference, thumnailFile: bytes, aspectRatio: aspect);
                          // If this is an image, navigate to ImageScreen
                          //return ImageScreen(imageFile: asset.file);

                        }
                        else {
                          // if it's not, navigate to VideoScreen
                          return VideoScreen(videoFile: asset.file);
                        }
                      },
                    ),
                  );
                });

              });*/
            });
            /* Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  if (asset.type == AssetType.image) {
                    // If this is an image, navigate to ImageScreen
                    //return ImageScreen(imageFile: asset.file);
                    return ImageZoomers(imageFile: asset.file, )
                  } else {
                    // if it's not, navigate to VideoScreen
                    return VideoScreen(videoFile: asset.file);
                  }
                },
              ),
            );*/
          },
          child: Stack(
            children: [
              // Wrap the image in a Positioned.fill to fill the space
              Positioned.fill(
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
              // Display a Play icon if the asset is a video
              if (asset.type == AssetType.video)
                Center(
                  child: Container(
                    //color: Colors.blue,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
}

class ImageZoomers extends StatelessWidget {
  const ImageZoomers(
      {Key key,
      @required this.imageFile,
      @required this.thumbnailFile,
      @required this.original,
      @required this.aspectRatio,
      @required this.reference})
      : super(key: key);
  final File imageFile;
  final File thumbnailFile;
  final bool original;
  final double aspectRatio;
  final DocumentReference reference;
  //final bool buttonActive;

  /// Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color(0xff00ffff),
          title: Row(
            children: <Widget>[
              Text(
                "Image Cropper",
                style: TextStyle(fontFamily: 'Muli', color: Colors.black),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 100),
                  child: MaterialButton(
                      child: Text(
                        "Next",
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 17),
                      ),
                      onPressed: imageFile == null
                          ? () {}
                          : () {
                              print("The file is ${imageFile}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          InstaUploadPhotoScreen(
                                            thumbnailFile:
                                                thumbnailFile.readAsBytesSync(),
                                            imageFile:
                                                imageFile.readAsBytesSync(),
                                            original: original,
                                            reference: reference,
                                            aspectRatio: aspectRatio,
                                          ))));
                            }))
            ],
          ),
        ),
        body: Container(
            child: imageFile == null
                ? Center()
                : Center(
                    child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Image.file(imageFile, fit: BoxFit.fitHeight
                        //BoxFit.cover
                        ),
                  ))));
  }

  /// Crop Image
  /*_cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      toolbarColor: Color(0xff00ffff),
      toolbarTitle:"Customize photo",
    );
    if (croppedImage != null) {
      setState(() {
        imageFile = croppedImage;
        buttonActive = true;
      });
    }
  }*/
}

class ImageScreen extends StatelessWidget {
  const ImageScreen({
    Key key,
    @required this.imageFile,
  }) : super(key: key);

  final Future<File> imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: FutureBuilder<File>(
        future: imageFile,
        builder: (_, snapshot) {
          final file = snapshot.data;
          if (file == null) return Container();
          return Image.file(file);
        },
      ),
    );
  }
}
