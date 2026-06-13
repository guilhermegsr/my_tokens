import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final input = await stdin.transform(utf8.decoder).join();
  final report = jsonDecode(input) as Map<String, dynamic>;
  final packages = (report['packages'] as List<dynamic>).cast<Map>();
  final blocked = packages.where(
    (package) =>
        package['isCurrentAffectedByAdvisory'] == true ||
        package['isCurrentRetracted'] == true,
  );

  if (blocked.isEmpty) return;

  for (final package in blocked) {
    stderr.writeln('Blocked dependency: ${package['package']}');
  }
  exitCode = 1;
}
