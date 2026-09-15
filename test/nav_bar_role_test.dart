import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_glass_nav_bar.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_nav_item.dart';

LiquidNavItem _item(String label) => LiquidNavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: label,
    );

Widget _host(List<LiquidNavItem> items, int sel, ValueChanged<int> onTap) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: LiquidGlassNavBar(
          items: items,
          selectedIndex: sel,
          onTap: onTap,
          badgeCount: 2,
          badgeIndex: 0,
          isDark: false,
        ),
      ),
    ),
  );
}

Finder _pillFinder() => find.byKey(LiquidGlassNavBar.navChipKey);

/// Expected indicator `start` for a settled tab: the squircle sits at 86% of
/// the cell width, centred on the cell, so `start = tabW * (tab + 0.07)`.
double _expectedStart(double barWidth, int n, int tab) {
  final innerW = barWidth - 32; // right/left 16 px padding each side
  final tabW = innerW / n;
  return tabW * (tab + 0.07);
}

void main() {
  group('LiquidGlassNavBar role switching', () {
    testWidgets(
        'admin (5 tabs) -> kitchen (2 tabs) snaps the pill without error',
        (tester) async {
      final admin = [
        _item('cart'),
        _item('menu'),
        _item('kitchen'),
        _item('history'),
        _item('profile'),
      ];
      final kitchen = [_item('kitchen'), _item('profile')];

      // Admin seated on the last tab (position 4).
      await tester.pumpWidget(_host(admin, 4, (_) {}));
      await tester.pumpAndSettle();

      // Switch role to kitchen; the shell redirects to branch /kitchen which
      // is position 0 in the 2-item bar.
      await tester.pumpWidget(_host(kitchen, 0, (_) {}));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);
      expect(find.text('kitchen'), findsOneWidget);
      expect(find.text('profile'), findsOneWidget);
    });

    testWidgets('waiter (4 tabs) -> admin (5 tabs) keeps the pill valid',
        (tester) async {
      final waiter = [
        _item('cart'),
        _item('menu'),
        _item('orders'),
        _item('profile'),
      ];
      final admin = [
        _item('cart'),
        _item('menu'),
        _item('kitchen'),
        _item('history'),
        _item('profile'),
      ];

      await tester.pumpWidget(_host(waiter, 2, (_) {}));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_host(admin, 2, (_) {}));
      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);
    });

    testWidgets('admin -> kitchen -> admin round-trip never throws',
        (tester) async {
      final admin = [
        _item('cart'),
        _item('menu'),
        _item('kitchen'),
        _item('history'),
        _item('profile'),
      ];
      final kitchen = [_item('kitchen'), _item('profile')];

      await tester.pumpWidget(_host(admin, 1, (_) {}));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_host(kitchen, 0, (_) {}));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpWidget(_host(admin, 1, (_) {}));
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a tab reports the position for each role bar',
        (tester) async {
      final admin = [
        _item('cart'),
        _item('menu'),
        _item('kitchen'),
        _item('history'),
        _item('profile'),
      ];
      final taps = <int>[];
      await tester.pumpWidget(_host(admin, 0, taps.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('history'));
      expect(taps, [3]);
    });
  });

  group('LiquidGlassNavBar pill position', () {
    final admin = [
      _item('cart'),
      _item('menu'),
      _item('kitchen'),
      _item('history'),
      _item('profile'),
    ];

    testWidgets('pill lands behind every selected tab 0..4', (tester) async {
      final barWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      await tester.pumpWidget(_host(admin, 0, (_) {}));
      await tester.pumpAndSettle();

      for (var tab = 0; tab <= 4; tab++) {
        await tester.pumpWidget(_host(admin, tab, (_) {}));
        await tester.pumpAndSettle();
        final pos = tester.widget<PositionedDirectional>(_pillFinder());
        expect(
          pos.start!,
          closeTo(_expectedStart(barWidth, 5, tab), 1.0),
          reason: 'pill should sit behind tab $tab',
        );
      }
    });

    testWidgets(
        'admin(5) -> kitchen(2) snaps the pill behind the profile tab',
        (tester) async {
      final barWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final kitchen = [_item('kitchen'), _item('profile')];
      await tester.pumpWidget(_host(admin, 4, (_) {}));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_host(kitchen, 1, (_) {}));
      await tester.pumpAndSettle();
      final pos = tester.widget<PositionedDirectional>(_pillFinder());
      expect(
        pos.start!,
        closeTo(_expectedStart(barWidth, 2, 1), 1.0),
        reason: 'pill should sit behind the only non-kitchen tab',
      );
    });

    testWidgets('waiter(4) -> admin(5) keeps the pill on the same tab',
        (tester) async {
      final barWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final waiter = [
        _item('cart'),
        _item('menu'),
        _item('orders'),
        _item('profile'),
      ];
      await tester.pumpWidget(_host(waiter, 2, (_) {}));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_host(admin, 2, (_) {}));
      await tester.pumpAndSettle();
      final pos = tester.widget<PositionedDirectional>(_pillFinder());
      expect(pos.start!, closeTo(_expectedStart(barWidth, 5, 2), 1.0));
    });

    testWidgets('chip glides on a spring between tabs, not a snap',
        (tester) async {
      final barWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      await tester.pumpWidget(_host(admin, 0, (_) {}));
      await tester.pumpAndSettle();
      final from = _expectedStart(barWidth, 5, 0);
      final to = _expectedStart(barWidth, 5, 4);

      await tester.pumpWidget(_host(admin, 4, (_) {}));
      await tester.pump(const Duration(milliseconds: 120));
      final mid = tester.widget<PositionedDirectional>(_pillFinder()).start!;
      expect(mid, greaterThan(from));
      expect(mid, lessThan(to));
      expect((mid - from).abs(), greaterThan(10), reason: 'motion is real');

      await tester.pumpAndSettle();
      final settled =
          tester.widget<PositionedDirectional>(_pillFinder()).start!;
      expect(settled, closeTo(to, 1.0));
    });
  });
}