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
            leading: Icon(Icons.exit_to_app),
            title: Text('ライセンス'),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('終了'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}