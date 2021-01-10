import 'dart:math';

import 'package:draft/DataBase/DBModel.dart';
import 'package:draft/DataBase/DBProvider.dart';
import 'package:draft/FileUtils.dart';
import  'package:flutter/material.dart';
import 'dart:io' as io;

import 'package:shared_preferences/shared_preferences.dart';

class DraftDataWithVariable{
  final DraftData draftData;
  List<VariableData> variableDataList=[];

  DraftDataWithVariable({this.draftData,this.variableDataList});

}

class DraftPage extends StatefulWidget {
  final DraftDataWithVariable data;
  const  DraftPage({this.data});

  @override
  State<StatefulWidget> createState() {
  return _DraftPageState(data);
  }

}

class  _DraftPageState extends State< DraftPage> {
  bool newCheck=false;
  bool currentVariable;
  //String defaultText;
  DraftDataWithVariable data;
  TextEditingController textController;
  String inputTitle="";
  List<String> variableNames=[];
  _DraftPageState(this.data){
    currentVariable=data.draftData.variable;
    inputTitle=data.draftData.title;
    data.variableDataList?.forEach((element) {variableNames.add(element.variableName);});
   // final DraftDB db=DBProvider.of(DBModelName.draft_data);
    //db.insert(data.draftData);
  }
  Future<void> saveDraft()async{
        /*String currentText=textController.text;
        io.File textFile=await FileUtils.getlocalFile(data.draftData.pathName);
        if(textFile.existsSync()==false)
          await textFile.create(recursive: true);
        textFile.writeAsStringSync(currentText);*/

        String currentText=textController.text;
        parseInput(currentText);
        tempSave();
        final DraftDB db=DBProvider.of(DBModelName.draft_data);
        if(currentText.isNotEmpty)
          await db.insert_update(data.draftData.copy(variable: currentVariable,title: inputTitle,header: currentText.substring(0,min(10,currentText.length))??""));
        else
          await db.delete(data.draftData.draftId);
        List<VariableData> set=[];
        int index=0;
        await Future.forEach(variableNames, (element){
          set.add(VariableData(orderNum: index, variableName: element, variableValue: "", draftId: data.draftData.draftId));
          index++;
        });

        final VariableSetDB db2=DBProvider.of(DBModelName.variable_data);
        await db2.deleteAllById(data.draftData.draftId);
        await Future.forEach(set, (element) async => await db2.insert_update(element));
        //final VariableSetDB db2=DBProvider()(DBModelName.variable_data);
        //db2.insert_update(model)
       // print("test");
  }
  void tempSave() async{
    String currentText=textController.text;
    final ContentDB db=DBProvider.of(DBModelName.content_data);
    await db.insert_update(DraftContentData(draftId:data.draftData.draftId,content: currentText));
   /* io.File textFile=await FileUtils.getlocalFile(data.draftData.pathName);
    if(textFile.existsSync()==false) {
      await textFile.create(recursive: true);
      final DraftDB db=DBProvider.of(DBModelName.draft_data);
      await db.insert_update(data.draftData);
    }
    textFile.writeAsStringSync(currentText);*/

}
  get _defaultText async{
    final ContentDB db=DBProvider.of(DBModelName.content_data);
    String rawText=await db.getContent(data.draftData.draftId);
    //String rawText=await FileUtils.getTexts(data.draftData.pathName);//getTextFromFile(data.draftData.pathName);
    String defaultText;
    if(data.draftData.variable && data.variableDataList!=null) {
      //final withvariable=data as DraftDataWithVariableData;
      defaultText=replaceVariable(rawText,data.variableDataList);
    }
    else{
      defaultText=rawText;
    }
    return defaultText;
  }

 /* Future<String> getTextFromFile(String pathName) async{
    io.File textFile=await FileUtils.getlocalFile(data.draftData.pathName);
    if(textFile.existsSync()){
      return textFile.readAsStringSync();
      //return io.File(path).readAsStringSync();
      }
    else
      return "";
  }*/
  replaceVariable(String rawText, List<VariableData> variableDataList){
    return rawText;
  }
  get _haveText{
    return textController.text.isNotEmpty;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async{
        onBackPressed();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("編集"),
          actions: <Widget>[  FlatButton(
            //textTheme:Theme.of(context).copyWith(accentColor: Colors.white) ,
            onPressed: (){
              FocusScope.of(context).requestFocus(FocusNode());
              saveDraft();
              },
            child: Icon(Icons.check),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          ],
          leading: FlatButton(
            onPressed: () => onBackPressed(),
            child: Icon(Icons.arrow_back),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ),
        body: Column(children: [
          IntrinsicHeight(child: Row(
            children: [
              Expanded(flex:4,child: TextFormField(
          initialValue: inputTitle,
                decoration: InputDecoration(
                  labelText: "タイトル",
                ),
          onChanged: (val)=>inputTitle=val,)),
              Expanded(flex:1,child: RaisedButton(
                  color: Colors.white,
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.blueAccent),
                  ),
                  onPressed:(){
                    addVariableCode();
                    //FocusScope.of(context).requestFocus(FocusNode());
                    },
                  child: Text("\$")),
              )
            ],
          )),
          Expanded(child:FutureBuilder(
            future:_defaultText,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
                if(snapshot.data==null)
                  return Container();
                textController= TextEditingController(text: snapshot.data);
                //textController.text(snapshot.data);
              return editor();
              //Editor(EditorInfo(snapshot.data,()=>saveDraft(),textController));
            },
           )
          )
        ],),
      ),
    );
  }
  addVariableCode(){
    try {
      var pos = textController.selection.baseOffset;
      var start = textController.text?.substring(0, pos);
      var end = textController.text?.substring(pos);
      textController.text = start + "\$" + end;
      final val = TextSelection.collapsed(offset: textController.text.length);
      textController.selection = val;
    }
    catch(e){}
  }
  onBackPressed()async{
   await saveDraft();
    Navigator.of(context).pop(true);
  }
  Widget editor(){
    return TextFormField (
      maxLines: 999,
      decoration: InputDecoration(
          labelText: "本文",
          ),
      //initialValue: info.defaultText,
      onChanged: (val){
        /*String last = val.substring(val.length - 1) ?? "";
            if(formerLength>val.length) {
             // deletedProcess
              codeState.deleted(last);
            }
            else if (formerLength<val.length)
            {

              codeState.added(last);
            }
            formerLength=val.length;
            print(codeState.variableNames);*/
        parseInput(val);
        //final last=val;
        tempSave();
      },
      controller: textController,
      //obscuringCharacter: defaultText,
    );
  }
  parseInput(String input){
    List<String> ls=input.split("\$");
    List<String> res=[];
    ls.asMap().forEach((key, value) {
      if(key%2==1&&key<ls.length-1){
        res.add(value);
      }
    });
    currentVariable=(res.length>=1);

    variableNames=res;
  }
}
/*
class Editor extends StatefulWidget{
  EditorInfo info;
  Editor(this.info);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditorState(info);
  }

}
typedef onChangedCallback = void Function();
class EditorInfo{
  final String defaultText;
  final onChangedCallback callback;
  final TextEditingController textController;
  EditorInfo(this.defaultText,this.callback,this.textController);
}
String get variableCode=>'\$';
class _VariableCodeState{
 bool lastIsVariableCode=false;
 bool variableNameInputting=false;
 //bool formerCodeExists=false;
 //List<String> variableNameList=[];
 String variableNames="";

 deleted(String last){
   if(lastIsVariableCode) {
     lastIsVariableCode = false;
     if(!variableNameInputting)
       variableNames=variableNames?.substring(0,variableNames.length-1);
     variableNameInputting ^=true;

   }
   else if (variableNameInputting) {
     variableNames =variableNames?.substring(0,variableNames.length-1);
   }
   lastIsVariableCode=(last==variableCode);
 }
 added(String s){
   lastIsVariableCode=(s==variableCode);
   if(lastIsVariableCode) {
     if (variableNameInputting) {
       variableNames += ",";
     }
     variableNameInputting^=true;
   }
   else if(variableNameInputting){
     variableNames+=s;
   }
 }

 _VariableCodeState();
}
class EditorState extends State<Editor> {
 // final String defaultText;

  //final Function listener;
  final EditorInfo info;
  VariableData variabledata;
  String variableName="";
  _VariableCodeState codeState;
  int formerLength;
 // TextEditingController textController= TextEditingController();
  EditorState(this.info){
    codeState=_VariableCodeState();
    formerLength=info.defaultText.length;
  }
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Container(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField (
          maxLines: 999,
          //initialValue: info.defaultText,
          onChanged: (val){
            /*String last = val.substring(val.length - 1) ?? "";
            if(formerLength>val.length) {
             // deletedProcess
              codeState.deleted(last);
            }
            else if (formerLength<val.length)
            {

              codeState.added(last);
            }
            formerLength=val.length;
            print(codeState.variableNames);*/
            List<String> ls=val.split("\$");
            List<String> res=[];
            ls.asMap().forEach((key, value) {
              if(key%2==1&&key<ls.length-1){
                res.add(value);
              }
            });
            //final last=val;
            info.callback();
          },
          controller: info.textController,
          //obscuringCharacter: defaultText,
        )
    );
  }
}
*/