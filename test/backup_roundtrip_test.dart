import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tokens/core/crypto/cipher.dart';

void main() {
  test('backup encrypt -> decrypt round-trips with the same password', () async {
    final salt = List<int>.generate(16, (i) => i);
    const password = 'correct horse';

    final sw = Stopwatch()..start();
    final exportKey =
        await PasswordKeyDeriver.derive(password: password, salt: salt);
    sw.stop();
    // ignore: avoid_print
    print('Argon2id derive took ${sw.elapsedMilliseconds} ms');

    final payload = jsonEncode([
      {
        'id': '1',
        'issuer': 'Google',
        'label': 'a@b.com',
        'secret': 'JBSWY3DPEHPK3PXP',
        'digits': 6,
        'period': 30,
        'algorithm': 'SHA1',
      }
    ]);
    final envelope = await Cipher(exportKey).encrypt(payload);

    final importKey =
        await PasswordKeyDeriver.derive(password: password, salt: salt);
    final clear = await Cipher(importKey).decrypt(envelope);

    expect(clear, payload);
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('wrong password fails to decrypt', () async {
    final salt = List<int>.generate(16, (i) => i + 7);
    final good = await PasswordKeyDeriver.derive(
        password: 'right', salt: salt);
    final bad = await PasswordKeyDeriver.derive(
        password: 'wrong', salt: salt);

    final envelope = await Cipher(good).encrypt('secret-data');
    expect(
      () => Cipher(bad).decrypt(envelope),
      throwsA(isA<Object>()),
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}
