import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'Hacker News App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _titles = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await http.get('https://api.hnpwa.com/v0/news/1.json');
    final data = json.decode(res.body);
    setState(() {
      final items = data as List;
      items.forEach((dynamic element) {
        final item = element as Map;
        _titles.add(item['title'] as String);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildItems(),
    );
  }

  Widget _buildItems() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext context, int index) {
          if (index.isOdd) return Divider();

          final i = index ~/ 2;
          if (i >= _titles.length) {
            return null;
          }
          return _buildRow(_titles[i]);
        });
  }

  Widget _buildRow(String item) {
    return ListTile(
      title: Text(
        item,
        style: _biggerFont,
      ),
    );
  }
}
