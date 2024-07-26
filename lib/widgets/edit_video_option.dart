import 'package:flutter/material.dart';

class EditVideoOption extends StatelessWidget {
  const EditVideoOption(
      {super.key,
      this.iconData,
      this.asset,
      required this.text,
      required this.onTap});
  final IconData? iconData;
  final String? asset;
  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
              iconData != null ? Icon(
                iconData,
                color: Colors.white,
              ) : Image.asset(asset!,width: asset == 'assets/youtube.png'? 45 : 20,color: Colors.white,),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
