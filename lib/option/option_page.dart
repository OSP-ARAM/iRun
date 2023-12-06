import 'package:flutter/material.dart';

import 'logout_page.dart';
import 'oss_licenses_page.dart';
import 'privacy_policy.dart';
import 'terms_of_service.dart';
import 'tts_setting_page.dart';

class OptionPage extends StatelessWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('개인정보 처리방침'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
              );
            },
          ),
          ListTile(
            title: const Text('서비스 이용약관'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfService()),
              );
            },
          ),
          ListTile(
            title: const Text('오픈소스 라이선스'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OssLicensesPage()),
              );
            },
          ),
          ListTile(
            title: const Text('TTS 설정'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TTSSetting()),
              );
            },
          ),
          ListTile(
            title: const Text('로그아웃'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LogoutPage(context: context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
