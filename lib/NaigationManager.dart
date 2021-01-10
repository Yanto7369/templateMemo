import 'package:flutter/widgets.dart';

class NavigationManager{
  BuildContext _context;
  NavigationManager._(this._context);
  static of(BuildContext context){
    return NavigationManager._(context);
  }
   push({Route route,Function complete})async{
   final  res= await Navigator.of(_context).push(route);
    if(res==NavigationProcess.ongoing){

    }
   }
}
enum NavigationProcess{
  cancel,complete,ongoing
}