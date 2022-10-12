import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_thumbnail/flutter_video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'gen_thumbnail_image.dart';

class ThumbNailList extends StatefulWidget {
  const ThumbNailList({Key? key}) : super(key: key);

  @override
  State<ThumbNailList> createState() => _ThumbNailListState();
}

class _ThumbNailListState extends State<ThumbNailList> {
  AssetEntity? asset;
  String path = '';
  late final String cachePath;

  final ImageFormat _format = ImageFormat.JPEG;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCachePath();
  }

  void getCachePath() async {
    cachePath = (await getTemporaryDirectory()).path;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            InkWell(
              onTap: () async {
                await selectVideo();
                setState(() {});
              },
              child: const Icon(Icons.camera),
            ),
            asset == null || path.isEmpty
                ? Container()
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildListView(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> selectVideo() async {
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
      return;
    }

    if (assets == null || assets.isEmpty) {
      return;
    }

    final AssetEntity asset = assets.first;
    final File? videoFile = await asset.file;
    if (videoFile == null || !await videoFile.exists()) {
      return;
    }
    path = videoFile.path;
    this.asset = asset;
  }

  List<Widget> _buildListView() {
    List<Widget> list = [];
    for (int index = 0; index < 20; index++) {
      final timeMs = ((asset!.videoDuration.inMilliseconds) * index) ~/ 20;
      final radio = asset!.width / asset!.height;
      list.add(SizedBox(
        width: 80,
        child: GenThumbnailImage(
            thumbnailRequest: ThumbnailRequest(
                video: path,
                thumbnailPath: '$cachePath/thumbnail/$timeMs.jpg',
                imageFormat: _format,
                maxHeight: 80 ~/ radio,
                timeMs: timeMs,
                quality: 50,
                maxWidth: 80)),
      ));
    }
    return list;
  }
}
