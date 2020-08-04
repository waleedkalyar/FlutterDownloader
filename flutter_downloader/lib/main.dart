import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/providers/file_models_provider.dart';
import 'package:flutter_downloader/widgets/file_item.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: FileModelsProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  List<String> urls = [
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg'
  ];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _progress = 0;
  int _total = 0;
  int _downloaded = 0;
  String _fileName = 'File Name';
  int _fileNumber = 0;

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  // String filename =basename(_file.path);//'test.pdf'; // file name that you desire to keep
  Future<void> downloadFile(uri, BuildContext context) async {
//    String uri =
//        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    //'https://file-examples.com/wp-content/uploads/2017/10/file-example_PDF_1MB.pdf'; // url of the file to be downloaded

    File _file = File(uri);

    String filename = basename(_file.path);

    setState(() {
      _fileName = filename;
    });
    print(filename);
    String savePath = await getFilePath(filename);

    Dio dio = Dio();

   await dio.download(uri, savePath, onReceiveProgress: (rcv, total) {
      setState(() {
        print(
            'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
        _total = total;
        _downloaded = rcv;
        _progress = ((rcv / total));
      });
    }, deleteOnError: true).then((_) {
      Provider.of<FileModelsProvider>(context).addFile(_fileName, _total);
      setState(() {
        _progress = 1;
      });
    });
  }

  Future<String> getFilePath(uFileName) async {
    String path = '';
    Directory dir = await getApplicationDocumentsDirectory();
    path = '${dir.path}/$uFileName';

    return path;
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileModelsProvider>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.file_download),
        onPressed: () async {
          for (int i = 0; i < widget.urls.length; i++) {
            setState(() {
              _fileNumber = i + 1;
            });
            await downloadFile(widget.urls[i], context);
          }
        },
      ),
      appBar: AppBar(
        title: Text('Downloader'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            color: Colors.lightBlueAccent,
            child: Container(
              height: 100,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(4),
              child: ListTile(
                leading: CircularPercentIndicator(
                  radius: 48,
                  lineWidth: 8.0,
                  percent: _progress,
                  center: Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 11),
                  ),
                  backgroundColor: Colors.grey,
                  progressColor: Colors.white,
                ),
                title: Text(
                  '$_fileName',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                subtitle: Chip(
                  label: Text(
                    '${formatBytes(_downloaded, 1)} / ${formatBytes(_total, 1)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
                trailing: Text(
                  'file(${_fileNumber}) of (${widget.urls.length})',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ),
//          Container(
//            padding: EdgeInsets.all(10),
//            margin: EdgeInsets.all(4),
//            child: Card(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  Column(
//                    children: <Widget>[
//                      CircularPercentIndicator(
//                        radius: 80,
//                        lineWidth: 12.0,
//                        percent: _progress,
//                        center: Text(
//                          '${(_progress * 100).toStringAsFixed(0)}%',
//                          style: TextStyle(
//                              fontWeight: FontWeight.bold,
//                              color: Colors.green,
//                              fontSize: 12),
//                        ),
//                        backgroundColor: Colors.grey,
//                        progressColor: Colors.green,
//                      ),
//                      Chip(
//                        label: Text(
//                          '${formatBytes(_downloaded, 1)} / ${formatBytes(_total, 1)}',
//                          style: TextStyle(
//                            fontSize: 11,
//                            fontWeight: FontWeight.w600,
//                            color: Colors.blue,
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                  Column(
//                    children: <Widget>[
//                      Text(
//                        'file(${_fileNumber}) of (${widget.urls.length})',
//                        textAlign: TextAlign.end,
//                        style: TextStyle(fontSize: 10),
//                      ),
//                      Text(
//                        '$_fileName',
//                        textAlign: TextAlign.start,
//                        style: TextStyle(
//                            fontSize: 14,
//                            fontWeight: FontWeight.bold,
//                            color: Colors.green),
//                      ),
//                    ],
//                  ),
//                ],
//              ),
//            ),
//          ),
          Expanded(
            child: ListView.builder(
              itemCount: fileProvider.files.length,
              itemBuilder: (ctx, index) {
                return FileItem(fileProvider.files[index].fileName,
                    fileProvider.files[index].size);
              },
            ),
          ),
        ],
      ),
    );
  }
}
