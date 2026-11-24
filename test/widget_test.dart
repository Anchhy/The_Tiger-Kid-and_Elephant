import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tiger_kid_elephant/main.dart';

void main() {
  testWidgets('home screen displays the Week 1 controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TigerKidElephantApp());

    expect(find.text('The Tiger, Kid, and Elephant'), findsOneWidget);
    expect(find.text('Play Game'), findsOneWidget);
  });

  testWidgets('Play Game opens Flame and return control goes home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TigerKidElephantApp());

    await tester.tap(find.text('Play Game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.byWidgetPredicate((Widget widget) => widget is GameWidget),
      findsOneWidget,
    );
    expect(find.byKey(const Key('return-to-home')), findsOneWidget);

    await tester.tap(find.byKey(const Key('return-to-home')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('The Tiger, Kid, and Elephant'), findsOneWidget);
    expect(find.text('Play Game'), findsOneWidget);
  });
}
