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
      home: const MyHomePage(title: 'Hacker News App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

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
  final List<Item> _items = <Item>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  int _pageIndex = 1;

  @override
  void initState() {
    super.initState();
    _load(_pageIndex);
  }

  Future<void> _load(int index) async {
    try {
      final http.Response res = await http
          .get(Uri.parse('https://api.hnpwa.com/v0/news/$index.json'));
      final dynamic data = json.decode(utf8.decode(res.bodyBytes));
      setState(() {
        final List items = data as List;
        for (dynamic element in items) {
          final Map item = element as Map;
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const SimpleDialog(
            title: Text('Error occurred'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Sorry, couldn\'t load items.'),
              )
            ],
          );
        },
      );
    }
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
    return RefreshIndicator(
      child: ListView.builder(
        key: const Key('hacker_news_list'),
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {
          final int i = index ~/ 2;
          // Add a line between item in list.
          if (index.isOdd) return const Divider();
          if (i == _items.length) {
            // Add a button to load more items.
            return Container(
              child: TextButton(
                child: const Text(
                  'Load More',
                  key: Key('load_more_button'),
                ),
                onPressed: () {
                  _pageIndex++;
                  _load(_pageIndex);
                },
              ),
            );
          } else if (i > _items.length) {
            return null;
          }
          return _buildRow(context, _items[i]);
        },
      ),
      onRefresh: () async {
        _items.clear();
        _pageIndex = 1;
        await _load(_pageIndex);
      },
    );
  }

  Widget _buildRow(BuildContext context, Item item) {
    Text subTitle;
    if (item.domain != null && item.points != null) {
      subTitle = Text(item.domain + '・' + item.points.toString() + 'points');
    } else if (item.domain != null && item.points == null) {
      subTitle = Text(item.domain);
    } else if (item.domain == null && item.points != null) {
      subTitle = Text(item.points.toString() + 'points');
    } else {
      subTitle = null;
    }
    return ListTile(
      title: Text(
        item.title,
        style: _biggerFont,
      ),
      subtitle: subTitle,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => WebViewPage(url: item.url)),
        );
      },
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key key, @required this.url}) : super(key: key);
  final String url;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(widget.url);
            },
          ),
        ],
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          print('WebView Created!');
        },
      ),
    );
  }
}
