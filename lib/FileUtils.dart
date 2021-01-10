import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
class FileUtils{
  static Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
  }
  static Future<io.File> getlocalFile(String pathName) async {
  final path = await _localPath;
  final res=io.File('$path/$pathName');
  return res;
  }
  static Future<String> getTexts(String pathName)async{
    final textFile=await getlocalFile(pathName);
    if(textFile.existsSync()){
      return textFile.readAsStringSync();
      //return io.File(path).readAsStringSync();
    }
    else
      return "";
  }



}