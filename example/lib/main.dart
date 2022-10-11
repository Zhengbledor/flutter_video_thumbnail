import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_video_thumbnail/flutter_video_thumbnail.dart';
import 'package:flutter_video_thumbnail_example/thumbnail_list.dart';
import 'dart:io';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'gen_thumbnail_image.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({Key? key}) : super(key: key);

  @override
  DemoHomeState createState() => DemoHomeState();
}

class DemoHomeState extends State<DemoHome> {
  final _editNode = FocusNode();
  final _video = TextEditingController(
      text:
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4");
  ImageFormat _format = ImageFormat.JPEG;
  int _quality = 50;
  int _sizeH = 0;
  int _sizeW = 0;
  int _timeMs = 0;

  GenThumbnailImage? _futureImage;

  late String _tempDir;

  @override
  void initState() {
    super.initState();
    getTemporaryDirectory().then((d) => _tempDir = d.path);
  }

  @override
  Widget build(BuildContext context) {
    final settings = <Widget>[
      Slider(
        value: _sizeH * 1.0,
        onChanged: (v) => setState(() {
          _editNode.unfocus();
          _sizeH = v.toInt();
        }),
        max: 256.0,
        divisions: 256,
        label: "$_sizeH",
      ),
      Center(
        child: (_sizeH == 0)
            ? const Text(
                "Original of the video's height or scaled by the source aspect ratio")
            : Text("Max height: $_sizeH(px)"),
      ),
      Slider(
        value: _sizeW * 1.0,
        onChanged: (v) => setState(() {
          _editNode.unfocus();
          _sizeW = v.toInt();
        }),
        max: 256.0,
        divisions: 256,
        label: "$_sizeW",
      ),
      Center(
        child: (_sizeW == 0)
            ? const Text(
                "Original of the video's width or scaled by source aspect ratio")
            : Text("Max width: $_sizeW(px)"),
      ),
      Slider(
        value: _timeMs * 1.0,
        onChanged: (v) => setState(() {
          _editNode.unfocus();
          _timeMs = v.toInt();
        }),
        max: 10.0 * 1000,
        divisions: 1000,
        label: "$_timeMs",
      ),
      Center(
        child: (_timeMs == 0)
            ? const Text("The beginning of the video")
            : Text("The closest frame at $_timeMs(ms) of the video"),
      ),
      Slider(
        value: _quality * 1.0,
        onChanged: (v) => setState(() {
          _editNode.unfocus();
          _quality = v.toInt();
        }),
        max: 100.0,
        divisions: 100,
        label: "$_quality",
      ),
      Center(child: Text("Quality: $_quality")),
      Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 8.0),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            isDense: true,
            labelText: "Thumbnail Format",
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Radio<ImageFormat>(
                      groupValue: _format,
                      value: ImageFormat.JPEG,
                      onChanged: (v) => setState(() {
                        _format = v!;
                        _editNode.unfocus();
                      }),
                    ),
                    const Text("JPEG"),
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Radio<ImageFormat>(
                      groupValue: _format,
                      value: ImageFormat.PNG,
                      onChanged: (v) => setState(() {
                        _format = v!;
                        _editNode.unfocus();
                      }),
                    ),
                    const Text("PNG"),
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Radio<ImageFormat>(
                      groupValue: _format,
                      value: ImageFormat.WEBP,
                      onChanged: (v) => setState(() {
                        _format = v!;
                        _editNode.unfocus();
                      }),
                    ),
                    const Text("WebP"),
                  ]),
            ],
          ),
        ),
      )
    ];
    return Scaffold(
        appBar: AppBar(
          title: const Text('Thumbnail Plugin example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 8.0),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  isDense: true,
                  labelText: "Video URI",
                ),
                maxLines: null,
                controller: _video,
                focusNode: _editNode,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  _editNode.unfocus();
                },
              ),
            ),
            for (var i in settings) i,
            Expanded(
              child: Container(
                color: Colors.grey[300],
                child: Scrollbar(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      (_futureImage != null) ? _futureImage! : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              AppBar(
                title: const Text("Settings"),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              for (var i in settings) i,
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const ThumbNailList()));
              },
              child: const Icon(Icons.bedroom_baby_sharp),
            ),
            const SizedBox(
              width: 20.0,
            ),
            InkWell(
              onTap: () async {
                File? video = await selectVideo();
                setState(() {
                  if (video != null) {
                    _video.text = video.path;
                  }
                });
              },
              child: const Icon(Icons.local_movies),
            ),
            const SizedBox(
              width: 20.0,
            ),
            InkWell(
              onTap: () async {
                setState(() {
                  _futureImage = GenThumbnailImage(
                      thumbnailRequest: ThumbnailRequest(
                          video: _video.text,
                          thumbnailPath: null,
                          imageFormat: _format,
                          maxHeight: _sizeH,
                          maxWidth: _sizeW,
                          timeMs: _timeMs,
                          quality: _quality));
                });
              },
              child: const Text("Data"),
            ),
            const SizedBox(
              width: 5.0,
            ),
            InkWell(
              onTap: () async {
                setState(() {
                  _futureImage = GenThumbnailImage(
                      thumbnailRequest: ThumbnailRequest(
                          video: _video.text,
                          thumbnailPath: _tempDir,
                          imageFormat: _format,
                          maxHeight: _sizeH,
                          maxWidth: _sizeW,
                          timeMs: _timeMs,
                          quality: _quality));
                });
              },
              child: const Text("File"),
            ),
          ],
        ));
  }

  Future<File?> selectVideo() async {
    var isSuccess = true;
    AssetPickerConfig config = AssetPickerConfig(
        maxAssets: 1,
        pageSize: 2000,
        requestType: RequestType.video,
        textDelegate: const AssetPickerTextDelegate(),
        limitedPermissionOverlayPredicate: (permissionState) => false,
        filterOptions: FilterOptionGroup(containsLivePhotos: false));
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(context,
            pickerConfig: config, useRootNavigator: false)
        .catchError((err) {
      isSuccess = false;
    });

    if (!isSuccess) {
      return null;
    }

    if (assets == null || assets.isEmpty) {
      return null;
    }

    final AssetEntity asset = assets.first;
    final File? videoFile = await asset.file;
    if (videoFile == null || !await videoFile.exists()) {
      return null;
    }
    return videoFile;
  }
}
