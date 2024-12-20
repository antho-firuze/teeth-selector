import 'package:flutter/material.dart';
import 'package:teeth_selector/teeth_selector.dart';

void main() => runApp(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.blue,
        ),
        home: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TeethSelector(
      onChange: (selected) => print(selected),
    );
  }
}
