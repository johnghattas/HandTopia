import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertestproject/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class ImageZoom extends StatefulWidget {
  final List<String?>? images;
  final int? currentIndex;

  const ImageZoom({Key? key, this.images, this.currentIndex}) : super(key: key);
  @override
  _ImageZoomState createState() => _ImageZoomState();
}

class _ImageZoomState extends State<ImageZoom> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {

          return PhotoViewGalleryPageOptions(
            imageProvider:  CachedNetworkImageProvider(widget.images![index]!),
            initialScale: PhotoViewComputedScale.contained ,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.images![widget.currentIndex!]!)
          );
        },
        itemCount: widget.images!.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: widget.currentIndex!),
        onPageChanged: onPageChanged,
      ),
    );
  }

  void onPageChanged(int index) {

  }
}
