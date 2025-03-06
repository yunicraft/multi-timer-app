import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("timefolio"),
      ),
      body: Center(
        child: Text("timefolio"),
      ),
    );
  }
}
