import 'package:clipboard/clipboard.dart';
import 'package:draft/DataBase/DBModel.dart';
import 'package:draft/DataBase/DBProvider.dart';
import 'package:draft/MyColors.dart';
import 'package:draft/VariableSetPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'NavDrawer.dart';
import 'Utils.dart';
import 'draft.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'テンプレメモ',
        debugShowCheckedModeBanner: false,
      theme: ThemeData(

        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,

        //primaryIconTheme: IconThemeData(color: Colors.white)
      ),
      home: MyHomePage(title:"テンプレート") //DraftPage(),//MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  _MyHomePageState(){

  }
  _getlist() async{
    //return [];
    DraftDB db= DBProvider.of(DBModelName.draft_data) ;
    List<DraftData> res=await db.getIdSortedAll();
    if(res.length>0) {
      newId = res.first.draftId + 1;
    }
    else {
      newId = 1;
    }
    return res;
  }
  Future<void> newDraft() async{
    DraftDB db=DBProvider.of(DBModelName.draft_data);
   // await db.insert(DraftData(textPath: ))
  }

  int newId;
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer:NavDrawer(),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _getlist(),
        builder: (BuildContext context,  snapshot){
          if(snapshot.data==null) {
            return Container();
          }
          else {
            List<DraftData> datas=snapshot.data;
            List<Widget> ls= datas.map<Widget>((e ) =>
                Slidable(
                  actionPane:SlidableDrawerActionPane(),
                  child: ListTile(
                        trailing: IconButton(
                          icon: Icon(Icons.content_copy) ,
                          onPressed:e.variable ?()=>editDraft(e):()async=>Utils.copyToClipboard(await Utils.getRawText(e.draftId)),
                        ),
                        onTap: ()=>editDraft(e),
                       // tileColor: MyColors.tileColor,
                        title: Text(e.title??"",),
                    subtitle: Text(e.header??""),
                        ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: ()async => await deleteItem(e.draftId),
                    ),
                  ],
                )).toList();
            return ListView(children: ls
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:()async {
          final result=await Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  DraftPage(data: DraftDataWithVariable(draftData: DraftData(
                      draftId: newId, title: "", variable: false))))
          );
          if (result == true) {
            setState(() {

            });
          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  editDraft(DraftData draftData) async {
    var result;
    if (draftData.variable) {
      result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context){
            return ChangeNotifierProvider(
                create: (context) => TextHolder(),
                child: VariableSetPage(draftData)
            );
          } ));

    }
    else {
      result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              DraftPage(data: DraftDataWithVariable(draftData: draftData),)
      ));
      /* if (result == true) {
       setState(() {

       });
     }*/
    }
    if (result??false) {
      setState(() {

      });
    }
  }

  deleteItem(int draftId) async{
    final DraftDB db=DBProvider.of(DBModelName.draft_data);
    await db.delete(draftId);
    final VariableSetDB db2=DBProvider.of(DBModelName.variable_data);
    await db2.deleteAllById(draftId);
    final ContentDB db3=DBProvider.of(DBModelName.content_data);
    await db3.delete(draftId);
    setState(() {

    });
  }

}
