import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'DataBase/DBModel.dart';
import 'DataBase/DBProvider.dart';

class Utils{
  static  Future<String> getRawText(int draftId)async{
    final ContentDB db=DBProvider.of(DBModelName.content_data);
    String rawText=await db.getContent(draftId);
    return rawText;
  }
  static Future<void> copyToClipboard(String text) async{
    //String rawText=await getRawText(e.draftId);
    FlutterClipboard.copy(text).then(( value ) {
      Fluttertoast.showToast(
        msg: "クリップボードにコピーされました",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        //backgroundColor: Colors.red,
        //textColor: Colors.white,
        //fontSize: 16.0
      );
    });
  }
}