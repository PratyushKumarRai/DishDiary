import 'dart:io';

void main() async {
  print('Looking for keytool in common locations...\n');
  
  final commonPaths = [
    r'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe',
    r'C:\Program Files\Android\Android Studio\jre\bin\keytool.exe',
    r'C:\Program Files\Java\jdk\bin\keytool.exe',
    r'C:\Program Files\Java\jdk-17\bin\keytool.exe',
    r'C:\Program Files\Java\jdk-11\bin\keytool.exe',
    r'C:\Program Files\Java\jre\bin\keytool.exe',
  ];
  
  String? keytoolPath;
  
  // Check common locations
  for (final path in commonPaths) {
    if (File(path).existsSync()) {
      keytoolPath = path;
      print('✓ Found keytool at: $path\n');
      break;
    }
  }
  
  // Check PATH
  if (keytoolPath == null) {
    try {
      final result = await Process.run('where', ['keytool']);
      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        keytoolPath = result.stdout.toString().trim().split('\r\n').first;
        print('✓ Found keytool in PATH: $keytoolPath\n');
      }
    } catch (_) {}
  }
  
  if (keytoolPath == null) {
    print('❌ keytool not found!\n');
    print('Please install one of these:');
    print('  1. Android Studio (recommended)');
    print('     Download: https://developer.android.com/studio\n');
    print('  2. Java JDK\n');
    print('     Download: https://www.oracle.com/java/technologies/downloads/\n');
    print('\nAfter installation, run this command in Android Studio Terminal:');
    print('keytool -list -v -keystore %USERPROFILE%\\.android\\debug.keystore -alias androiddebugkey -storepass android -keypass android\n');
    return;
  }
  
  // Run keytool
  final keystorePath = '${Platform.environment['USERPROFILE']}\\.android\\debug.keystore';
  final result = await Process.run(
    keytoolPath,
    [
      '-list',
      '-v',
      '-keystore',
      keystorePath,
      '-alias',
      'androiddebugkey',
      '-storepass',
      'android',
      '-keypass',
      'android',
    ],
  );
  
  if (result.exitCode == 0) {
    print('═══════════════════════════════════════════════════════');
    print('YOUR SHA-1 FINGERPRINT:');
    print('═══════════════════════════════════════════════════════');
    
    // Extract SHA1 from output
    final lines = result.stdout.toString().split('\n');
    for (final line in lines) {
      if (line.contains('SHA1:')) {
        print('\n  ${line.trim()}\n');
        print('═══════════════════════════════════════════════════════');
        print('\nCopy this SHA-1 and add it to Google Cloud Console:');
        print('1. Go to: https://console.cloud.google.com/apis/credentials');
        print('2. Click your OAuth 2.0 Client ID (Android)');
        print('3. Click "+ Add Fingerprint"');
        print('4. Paste the SHA-1 value');
        print('5. Click Save');
        print('6. Wait 2-5 minutes');
        print('7. Run: flutter clean && flutter run\n');
        break;
      }
    }
  } else {
    print('❌ Error running keytool:');
    print(result.stderr.toString());
  }
}
