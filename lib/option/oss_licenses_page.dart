import 'package:flutter/material.dart';
import 'oss_licenses.dart';
import 'misc_oss_license_single.dart';
import 'package:flutter/foundation.dart';

class OssLicensesPage extends StatelessWidget {
  const OssLicensesPage({super.key});

  static Future<List<Package>> loadLicenses() async {
    final lm = <String, List<String>>{};
    await for (var l in LicenseRegistry.licenses) {
      for (var p in l.packages) {
        final lp = lm.putIfAbsent(p, () => []);
        lp.addAll(l.paragraphs.map((p) => p.text));
      }
    }

    final licenses = ossLicenses.toList();
    for (var key in lm.keys) {
      licenses.add(Package(
        name: key,
        description: '',
        authors: [],
        version: '',
        license: lm[key]!.join('\n\n'),
        isMarkdown: false,
        isSdk: false,
        isDirectDependency: false,
      ));
    }
    return licenses..sort((a, b) => a.name.compareTo(b.name));
  }

  static final _licenses = loadLicenses();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Open Source Licenses'),
        ),
        body: FutureBuilder<List<Package>>(
            future: _licenses,
            initialData: const [],
            builder: (context, snapshot) {
              return ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final package = snapshot.data![index];
                    return ListTile(
                      title: Text('${package.name} ${package.version}'),
                      subtitle: package.description.isNotEmpty
                          ? Text(package.description)
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MiscOssLicenseSingle(package: package),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider());
            }));
  }
}
