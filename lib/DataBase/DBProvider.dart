import 'package:flutter/cupertino.dart';

import 'package:path/path.dart';
import 'dart:io' as io;
import 'package:sqflite/sqflite.dart';

import 'DBModel.dart';


abstract class BaseDB{
  final String  initSQL;
  final String tableName;
  Database _database;
  String _dbFileName="draft.db";
  BaseDB({this.tableName,this.initSQL});
  
  Future<Database> get database async {
    /*if (_database != null) {
      try {
        await _createTable(_database, 1);
      } catch (e, s) {
        print(s);
      }
      return _database;
    }*/
    // DBがなかったら作る
    if(_database==null)
      _database = await initDB();

    try {
      await _createTable(_database, 1);//.catchError(()=>print("error"));
    } catch (e, s) {
      print(s);
    }
    return _database;
  }

  Future<void> _createTable(Database db, int version) async {
    return await db.execute(
        initSQL
    );
  }
  reset()async{
    String path = join(await getDatabasesPath(), _dbFileName);
    deleteDatabase(path);
  }
  Future<Database> initDB() async{

    // import 'package:path/path.dart'; が必要
    // なぜか サジェスチョンが出てこない
    String path = join(await getDatabasesPath(), _dbFileName);
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }
  insert(DBModel model)async{
    final db = await database;
    // var tes=state.toMap();
    var res = await db.insert(tableName, model.toMap());
    return res;
  }
 /* update(DBModel s)async{
    final db = await database;
   String sql=s.whereSQL();
    int res=await db.update(tableName, s.toMap() ,where: sql);
    return res;
  }*/
  //level
  insert_update(model)async{
    final db = await database;
    // var tes=state.toMap();
    var res = await db.insert(tableName, model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,);
    /*if(res==1)
        return 1;
      res=await update(state);*/
    return res;
  }

}
class DraftDB extends BaseDB{
  DraftDB():super(
    tableName: "Draft",
    initSQL: "CREATE TABLE IF NOT EXISTS Draft("
        "draftId  INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT,"
        "variable INTEGER,"
        "header TEXT"
        ")"
  );

  Future<List<DraftData>> getIdSortedAll()async{
    final db=await database;
    List<Map> res=await db.rawQuery("SELECT * FROM $tableName ORDER BY draftId DESC");
    List<DraftData> ls=[];
    await Future.forEach(res, (element) => ls.add(DraftData.fromMap(element)));
   // res.forEach((element) {ls.add(DraftData.fromMap(element));});
//    return res.map((e) => DraftData.fromMap(e)).toList();
  return ls;
  }

  delete(int draftId) async{
    final db=await database;
    await db.delete(tableName,where: "draftId=?",whereArgs: [draftId]);
  }
}
class VariableSetDB  extends BaseDB {
  //tableName= "VariableSet";
  //init_sql="CREATE TABLE IF NOT EXISTS VariableSet";
  VariableSetDB():super(
      tableName:"VariableSet",
      initSQL: "CREATE TABLE IF NOT EXISTS VariableSet("
          "draftId INTEGER KEY,"
          "variableName TEXT,"
          "variableValue TEXT,"
          "orderNum INTEGER,"
          "PRIMARY KEY (draftId,variableName)"
          ")"


  );

  deleteAllById(int draftId) async{
    final db=await database;
    await db.delete(tableName,where: "draftId = ?",whereArgs: [draftId]);
  }
  Future<List<VariableData>>getListById(int draftId) async{
    final db=await database;
   List<Map> resMap=await db.rawQuery("SELECT * FROM $tableName WHERE draftId='$draftId' ORDER BY orderNum ASC ");
   //Future.forEach(elements, (element) => null)
    List<VariableData> ls=[];
    await Future.forEach(resMap, (element) => ls.add(VariableData.fromMap(element)));
   return ls;
  }
}

class DBProvider  {
  //static Database _database;
  //DBProvider._(this.tableName,this._init_sql);
  //pathとはf000など
 static of(DBModelName name ){
    switch(name){
      case DBModelName.variable_data : return  VariableSetDB();
      case DBModelName.draft_data:return DraftDB();
      case DBModelName.content_data:return ContentDB();
      default:return null;
    }
  }

  
}

class ContentDB extends BaseDB{
  ContentDB():super(
      tableName:"Content",
      initSQL: "CREATE TABLE IF NOT EXISTS Content("
          "draftId  INTEGER  Primary KEY ,"
          "content TEXT"
          ")"


  );

  Future<String> getContent(int draftId) async{
    final db=await database;
    final  resMap=await db.rawQuery("SELECT * FROM $tableName WHERE draftId=?",[draftId]);
    String res="";
    await Future.forEach(resMap, (element) =>res=DraftContentData.fromMap(element).content);
    return res;
  }
  delete(int draftId) async{
    final db=await database;
    await db.delete(tableName,where: "draftId=?",whereArgs: [draftId]);
  }
}
