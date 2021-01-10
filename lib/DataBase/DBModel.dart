class VariableData extends DBModel{
  final int draftId;
  final String variableName;
  final String variableValue;
  final int orderNum;
  VariableData({this.orderNum, this.draftId,this.variableName,this.variableValue});

  @override
  List<String> getKeyList() {
    // TODO: implement getKeyList
    throw UnimplementedError();
  }
  factory VariableData.fromMap(Map<String, dynamic> json)=>VariableData(
    draftId: json["draftId"],
    variableName: json["variableName"],
    variableValue: json["variableValue"],
    orderNum: json["orderNum"]
  );

  @override
  Map<String, dynamic> toMap() =>{
    "draftId":draftId,
    "variableName":variableName,
    "variableValue":variableValue,
    "orderNum":orderNum
  };


  //DBModelName name=DBModelName.variable_data;


}
class DraftContentData extends DBModel{
  final int draftId;
  final String content;

  DraftContentData({this.draftId, this.content});
  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {
      "draftId":draftId,
      "content":content
    };
  }
  factory DraftContentData.fromMap(Map<String,dynamic> json)=>DraftContentData(
    draftId:json["draftId"],
    content:json["content"]
  );

}
class DraftData extends DBModel{
  int draftId;
  String get  pathName=>"$draftId.txt";
  final String title;
  final bool variable;
  final String header;
  copy({int draftId,String title,bool variable,String header}){
    return DraftData(
      draftId: draftId??this.draftId,
      title: title??this.title,
      variable: variable??this.variable,
      header:header??this.header
    );
  }
  DraftData( {this.header,this.draftId,this.title,this.variable});
  @override
  Map<String, dynamic> toMap()
   =>{
     "draftId":draftId,
   //  "textPath":textPath,
     "title":title,
     "variable" : variable==true?1:0,
     "header":header
   };

  factory DraftData.fromMap(Map<String, dynamic> json)=>DraftData(
      draftId:json["draftId"],
     // textPath:json["textPath"],
      title: json["title"],
      variable: json["variable"]==1 ? true:false,
      header: json["header"]
  );



}
enum DBModelName{
  variable_data,draft_data,content_data
}
abstract class DBModel{
  Map<String, dynamic> toMap();
}