import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CraftWidget extends StatelessWidget {
  const CraftWidget({
    Key? key,
    required this.imageUrl,
    required this.text
  }) :super(key: key);

  final String? text;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      child: Stack(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.25),
                  borderRadius: BorderRadius.circular(51.0),
                  image: DecorationImage(
                    image:  CachedNetworkImageProvider(imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(51.0),
                  color: const Color(0x42000000),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x00000000),
                      offset: Offset(0, 8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(right: 30, bottom: 16),
              child: Text(
                text!,
                style: TextStyle(
                  fontFamily: 'HS Dream',
                  fontSize: 20,
                  color: const Color(0xffffffff),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}