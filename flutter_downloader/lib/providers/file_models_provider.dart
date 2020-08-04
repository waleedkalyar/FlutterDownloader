
 import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/models/file_model.dart';

class FileModelsProvider with ChangeNotifier{

 List<FileModel> models = [];

 List<FileModel> get files {
  return [...models];
 }
 void addFile(String name, int size){
  models.add(new FileModel(name,size));
  notifyListeners();
 }

}
