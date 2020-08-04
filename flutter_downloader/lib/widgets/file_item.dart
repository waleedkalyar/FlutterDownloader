
import 'dart:math';

import 'package:flutter/material.dart';

class FileItem extends StatelessWidget{
 final String name;
 final int size;


 FileItem(this.name, this.size);

 static String formatBytes(int bytes, int decimals) {
   if (bytes <= 0) return "0 B";
   const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
   var i = (log(bytes) / log(1024)).floor();
   return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
       ' ' +
       suffixes[i];
 }

 @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(name),
          trailing: Text('${formatBytes(size, 1)}'),
        ),
        Divider(),
      ],
    );
  }

}