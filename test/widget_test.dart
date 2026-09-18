import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip/main.dart';

void main() {
  testWidgets('JastipApp smoke test and navigation to Register', (WidgetTester tester) async {
    // Set a realistic mobile screen size (iPhone 14: 390x844)
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const JastipApp());
    await tester.pumpAndSettle();

    // Verify Login Screen elements
    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    final registerFinder = find.text('Daftar Sekarang');
    expect(registerFinder, findsOneWidget);

    // Scroll to and tap register link
    await tester.ensureVisible(registerFinder);
    await tester.pumpAndSettle();
    await tester.tap(registerFinder);
    await tester.pumpAndSettle();

    // Verify Register Screen elements
    expect(find.text('Buat Akun Baru'), findsOneWidget);
    final masukFinder = find.text('Masuk di sini');
    expect(masukFinder, findsOneWidget);

    // Scroll to and tap back to login
    await tester.ensureVisible(masukFinder);
    await tester.pumpAndSettle();
    await tester.tap(masukFinder);
    await tester.pumpAndSettle();

    // Verify back to Login Screen
    expect(find.text('Selamat Datang!'), findsOneWidget);
  });
}
