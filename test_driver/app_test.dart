import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Scroll listview', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('verifies the list view and text button', () async {
      final listFinder = find.byValueKey('hacker_news_list');
      final itemFinder = find.byValueKey('load_more_button');

      // wait for loading news items.
      await driver.waitForAbsent(itemFinder);

      await driver.scrollUntilVisible(
        listFinder,
        itemFinder,
        dyScroll: -300.0,
      );

      expect(
        await driver.getText(itemFinder),
        'Load More',
      );
    });
  });
}
