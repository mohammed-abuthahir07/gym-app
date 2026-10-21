import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymmanagement/shared/widgets/custom_button.dart';
import 'package:gymmanagement/shared/widgets/stat_card.dart';
import 'package:gymmanagement/shared/widgets/empty_state.dart';

void main() {
  testWidgets('CustomButton renders text and responds to tap', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(text: 'Sign In', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Sign In'), findsOneWidget);
    await tester.tap(find.byType(CustomButton));
    expect(tapped, isTrue);
  });

  testWidgets('StatCard displays title and value correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(
            title: 'Total Members',
            value: '40',
            icon: Icons.people,
            subtitle: '35 active',
          ),
        ),
      ),
    );

    expect(find.text('Total Members'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(find.text('35 active'), findsOneWidget);
  });

  testWidgets('EmptyState displays placeholder messaging', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No Workouts',
            message: 'No exercises scheduled for today.',
          ),
        ),
      ),
    );

    expect(find.text('No Workouts'), findsOneWidget);
    expect(find.text('No exercises scheduled for today.'), findsOneWidget);
  });
}
