import 'package:flutter_test/flutter_test.dart';
import 'package:hacker_news_app/main.dart';

void main() {
  testWidgets('MyWidget has a title and a Text Button',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the title of this app.
    expect(find.text('Hacker News App'), findsOneWidget);
    expect(find.text('Load More'), findsOneWidget);
  });
}
