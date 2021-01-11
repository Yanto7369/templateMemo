import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'メニュー',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                 color: Colors.blue,),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('ライセンス情報'),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('アプリを評価する'),
            //onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}