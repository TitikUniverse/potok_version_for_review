import 'dart:io';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';


import '../models/attachment_style.dart';
import '../picker.dart';

class ViewContent extends StatefulWidget {
  const ViewContent({
    super.key,
    required this.entities,
    this.initialIndex = 0,
    this.attachmentStyle,
  });

  final List<AssetEntity> entities;
  final int initialIndex;
  final AttachmentStyle? attachmentStyle;

  @override
  State<ViewContent> createState() => _ViewContentState();
}

class _ViewContentState extends State<ViewContent> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initialIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DismissiblePage(
        onDismissed: () {
          Navigator.of(context).pop();
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.entities.length,
          itemBuilder: (context, index) => ViewedElement(key: ValueKey<int>(widget.initialIndex), entity: widget.entities[index], attachmentStyle: widget.attachmentStyle),
        ),
      ),
    );
  }
}

class ViewedElement extends StatefulWidget {
  const ViewedElement({super.key, required this.entity, this.attachmentStyle});

  final AssetEntity entity;
  final AttachmentStyle? attachmentStyle;

  @override
  State<ViewedElement> createState() => _ViewedElementState();
}

class _ViewedElementState extends State<ViewedElement> {
  File? _file;

  VideoPlayerController? _videoPlayerController;
  // final bool _pauseOnTap = true;

  int numberOfSelectedItem = 0;
  GlobalKey<GalleryPickerState>? galleryPickerState;

  void _initializePlayer() {
    if (_file == null) return;
    _videoPlayerController = VideoPlayerController.file(_file!)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _file = await widget.entity.file;
      if (widget.entity.type == AssetType.video) _initializePlayer();

      if (widget.entity.type == AssetType.image) {
        galleryPickerState = galleryPickerKeys[0];
      } else if (widget.entity.type == AssetType.video) {
        galleryPickerState = galleryPickerKeys[1];
      }
      if (galleryPickerState?.currentState != null) {
        numberOfSelectedItem = galleryPickerState!.currentState!.numberOfSelectedItem(widget.entity);
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_file == null) const SizedBox.shrink()
        else if (widget.entity.type == AssetType.image) SizedBox.expand(
          child: Image.file(_file!),
        )
        else if (_videoPlayerController == null) const SizedBox.shrink()
        else if (widget.entity.type == AssetType.video) SizedBox.expand(
          child: _videoPlayerController!.value.isInitialized 
          ? VisibilityDetector(
            key: ObjectKey(_file),
            onVisibilityChanged: (visibility) {
              if (visibility.visibleFraction < 1 && mounted) {
                _videoPlayerController!.pause();
              } else if (visibility.visibleFraction == 1) {
                _videoPlayerController!.play();
              }
            },
            child: VideoPlayer(_videoPlayerController!),
          )
          : const SizedBox.shrink()
        )
        else Container(),

        if (_file != null && (widget.entity.type == AssetType.image || widget.entity.type == AssetType.video)) PositionedDirectional(
          top: 4,
          end: 4,
          child: StatefulBuilder(
            builder: (context, setState) {
              return InkWell(
                onTap: () {
                  late GlobalKey<GalleryPickerState> item;
                  if (widget.entity.type == AssetType.image) {
                    item = galleryPickerKeys[0];
                  } else if (widget.entity.type == AssetType.video) {
                    item = galleryPickerKeys[1];
                  }
                  if (item.currentState != null) {
                    bool enabled = item.currentState!.enabled();
                    if (!enabled && numberOfSelectedItem < 0) return;
                  }
                  
                  if (widget.key is ValueKey<int>) {
                    int index = (widget.key as ValueKey<int>).value;
                    if (item.currentState != null) {
                      int number = item.currentState!.onSelect(index, widget.entity);
                      setState(() {
                        numberOfSelectedItem = number;
                      });
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 30,
                    height: 30,
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: numberOfSelectedItem < 0 ? Colors.transparent : widget.attachmentStyle != null ? widget.attachmentStyle!.selectedColor : Colors.blueGrey,
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: Colors.white,
                        strokeAlign: BorderSide.strokeAlignInside,
                        width: 2
                      )
                    ),
                    child: numberOfSelectedItem >= 0 ? Text(
                      (numberOfSelectedItem + 1).toString(),
                      style: widget.attachmentStyle != null && widget.attachmentStyle!.selectedTextStyle != null ? widget.attachmentStyle!.selectedTextStyle : const TextStyle(
                        color: Colors.white
                      ),
                    ) : const SizedBox()
                  ),
                ),
              );
            }
          ),
        )
      ],
    );
  }
}