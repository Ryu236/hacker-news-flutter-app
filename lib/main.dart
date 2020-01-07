import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

class Item {
  final String title;
  final int points;
  final String user;
  final String timeAgo;
  final int commentsCount;
  final String url;
  final String domain;

  Item({
    this.title,
    this.points,
    this.user,
    this.timeAgo,
    this.commentsCount,
    this.url,
    this.domain,
  });
}

class _MyHomePageState extends State<MyHomePage> {
  List<Item> _items = <Item>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final http.Response res =
        await http.get('https://api.hnpwa.com/v0/news/1.json');
    final String responseBody = utf8.decode(res.bodyBytes);
    final dynamic data = json.decode(responseBody);
    setState(() {
      final items = data as List;
      for (dynamic element in items) {
        final item = element as Map;
        _items.add(Item(
          title: item['title'] as String,
          points: item['points'] as int,
          user: item['user'] as String,
          timeAgo: item['time_ago'] as String,
          commentsCount: item['comment_count'] as int,
          url: item['url'] as String,
          domain: item['domain'] as String,
        ));
      }
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
          if (i >= _items.length) {
            return null;
          }
          return _buildRow(context, _items[i]);
        });
  }

  Widget _buildRow(BuildContext context, Item item) {
    return ListTile(
      title: Text(
        item.title,
        style: _biggerFont,
      ),
      subtitle: Text(item.domain + '・' + item.points.toString() + 'points'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WebViewPage(url: item.url)),
        );
      },
    );
  }
}

class WebViewPage extends StatefulWidget {
  WebViewPage({Key key, @required this.url}) : super(key: key);
  final String url;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WebView"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(widget.url);
            },
          ),
        ],
      ),
      body: WebView(
        initialUrl: (widget.url),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          print("WebView Created!");
        },
      ),
    );
  }
}
