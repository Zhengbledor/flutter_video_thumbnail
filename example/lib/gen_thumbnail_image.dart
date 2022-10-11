import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_video_thumbnail/flutter_video_thumbnail.dart';

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  const GenThumbnailImage({Key? key, required this.thumbnailRequest})
      : super(key: key);

  @override
  GenThumbnailImageState createState() => GenThumbnailImageState();
}

class GenThumbnailImageState extends State<GenThumbnailImage> {
  ThumbnailRequest? thumbnailRequest;

  @override
  void initState() {
    super.initState();
    thumbnailRequest = widget.thumbnailRequest;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThumbnailResult>(
      future: genThumbnail(thumbnailRequest!),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final image = snapshot.data.image;
          return image;
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
    Uint8List? bytes;
    final Completer<ThumbnailResult> completer = Completer();
    if (r.thumbnailPath != null) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: r.video,
          headers: {
            "USERHEADER1": "user defined header1",
            "USERHEADER2": "user defined header2",
          },
          thumbnailPath: r.thumbnailPath,
          imageFormat: r.imageFormat,
          maxHeight: r.maxHeight,
          maxWidth: r.maxWidth,
          timeMs: r.timeMs,
          quality: r.quality);

      print("thumbnail file is located: $thumbnailPath");

      final file = File(thumbnailPath!);
      bytes = file.readAsBytesSync();
    } else {
      bytes = await VideoThumbnail.thumbnailData(
          video: r.video,
          headers: {
            "USERHEADER1": "user defined header1",
            "USERHEADER2": "user defined header2",
          },
          imageFormat: r.imageFormat,
          maxHeight: r.maxHeight,
          maxWidth: r.maxWidth,
          timeMs: r.timeMs,
          quality: r.quality);
    }

    int imageDataSize = bytes!.length;
    final image = Image.memory(bytes);
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(ThumbnailResult(
        image: image,
        dataSize: imageDataSize,
        height: info.image.height,
        width: info.image.width,
      ));
    }));
    return completer.future;
  }
}

class ThumbnailRequest {
  final String video;
  final String? thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest(
      {required this.video,
      required this.thumbnailPath,
      required this.imageFormat,
      required this.maxHeight,
      required this.maxWidth,
      required this.timeMs,
      required this.quality});
}

class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;

  const ThumbnailResult(
      {required this.image,
      required this.dataSize,
      required this.height,
      required this.width});
}
