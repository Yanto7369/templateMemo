

import 'package:draft/DataBase/DBProvider.dart';
import 'package:draft/draft.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataBase/DBModel.dart';
import 'Utils.dart';

class VariableSetPage extends StatefulWidget{
  final DraftData draftData;
  VariableSetPage(this.draftData);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return _VariableSetPageState(draftData);
  }
  
}

class _VariableSetPageState extends State<VariableSetPage> {
  DraftData draftData;
  List<VariableData> variableDataList;
  Map<String,String> variableMap={};//
 // String previewText="";
  //String rawText="";
  _VariableSetPageState(this.draftData);
  get _getlist async{
    List<VariableData> set;
    set=await DBProvider.of(DBModelName.variable_data).getListById(draftData.draftId);
    return set;
  }
  loadedData()async{
    variableDataList=await _getlist;
    Future.forEach<VariableData>(variableDataList, (element) {
      variableMap.addAll({element.variableName:element.variableValue});
    });
    final ContentDB db=DBProvider.of(DBModelName.content_data);
    String rawText=await Utils.getRawText(draftData.draftId);//await db.getContent(draftData.draftId);
    //previewText=rawText;
    Provider.of<TextHolder>(context ,listen:false).init(rawText);
    return variableDataList;
  }

  onBackPressed(){
    Navigator.of(context).pop(true);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop:() async{
        onBackPressed();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("変数設定"),
          actions: <Widget>[  FlatButton(
            onPressed: (){
             Utils.copyToClipboard(Provider.of<TextHolder>(context,listen:false).previewText);
            },
            child: Icon(Icons.content_copy),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),

          ],
          leading: FlatButton(
            onPressed: () => onBackPressed(),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
              child: Icon(Icons.arrow_back),
            ),
        ),
        body: FutureBuilder(
          future: loadedData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
            if(snapshot.data==null)
              return Container();
            else {
              List<Widget> ls=[];
              List<VariableData> dataList=snapshot.data;
              dataList.forEach((element) { ls.add(variableColumn(element));});
              ls.add(PreviewWidget());
              //forEach<Widget>((e) => variableColumn(e)).toList()
              return ListView(children:
              ls//snapshot.data.map<Widget>((e) => variableColumn(e)).toList()
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:() async{
            final result=await Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                    DraftPage(data: DraftDataWithVariable(draftData: draftData,
                        variableDataList: variableDataList),))
            );
            if(result??false){
              setState(() {

              });
            }
          },
          tooltip: 'Edit',
          child: Icon(Icons.edit),
        ),

      ),
    );
  }
  Widget variableColumn(VariableData variableData){
    return Column(children: [
      ListTile(title: Text(variableData.variableName)),
      TextFormField(
          decoration: InputDecoration(
            labelText: "値",
          ),
          maxLines: 1,onChanged: (val){
        variableMap[variableData.variableName]=val;
        Provider.of<TextHolder>(context,listen:false).replaceVariable(variableMap);
    })
    ],);
  }
}
class PreviewWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return //Text("${Provider.of<TextHolder>(context).previewText}");
    Consumer<TextHolder>(builder: (_,textHolder,__){
      return Text('${textHolder.previewText}');

    });
  }

}
class TextHolder extends ChangeNotifier{
  String rawText="";
  String previewText="";
  init(String rawText){
    this.rawText=rawText;
    previewText=rawText;
    notifyListeners();
  }
  void replaceVariable(Map<String, String> variableMap){
    previewText=rawText;
    variableMap.forEach((key, value) {
      if(value.isNotEmpty)
      previewText=previewText.replaceAll("\$$key\$", value);
    });
    //previewText=rawText+"a";
    notifyListeners();
  }
}