import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class CloudStorageService {
  // Google Drive configuration
  // Note: These are placeholder values. In production, use environment variables
  static const String _googleClientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  static const String _googleClientSecret = 'YOUR_GOOGLE_CLIENT_SECRET';
  static const List<String> _googleScopes = [
    drive.DriveApi.driveFileScope,
  ];

  // Microsoft Graph configuration
  static const String _msClientId = 'YOUR_MS_CLIENT_ID';
  static const String _msRedirectUri = 'https://localhost/auth';
  static const String _msAuthority = 'https://login.microsoftonline.com/common';
  static const List<String> _msScopes = [
    'Files.ReadWrite',
    'offline_access',
  ];

  // Upload to Google Drive
  Future<String?> uploadToGoogleDrive({
    required String fileName,
    required String content,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 Authenticating with Google...');
      }

      // Web OAuth flow for Google
      final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'client_id': _googleClientId,
        'redirect_uri': 'https://localhost/auth',
        'response_type': 'code',
        'scope': _googleScopes.join(' '),
        'access_type': 'offline',
      });

      // Open authentication window
      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'https',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('認証コードの取得に失敗しました');
      }

      // Exchange code for tokens
      final tokenResponse = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        body: {
          'code': code,
          'client_id': _googleClientId,
          'client_secret': _googleClientSecret,
          'redirect_uri': 'https://localhost/auth',
          'grant_type': 'authorization_code',
        },
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception('トークンの取得に失敗しました');
      }

      final tokens = jsonDecode(tokenResponse.body);
      final accessToken = tokens['access_token'] as String;

      if (kDebugMode) {
        debugPrint('✅ Google認証成功');
        debugPrint('📤 ファイルをアップロード中...');
      }

      // Create authenticated HTTP client
      final authClient = _GoogleAuthClient(accessToken);
      final driveApi = drive.DriveApi(authClient);

      // Create file metadata
      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'text/csv';

      // Upload file
      final media = drive.Media(
        Stream.value(utf8.encode(content)),
        content.length,
      );

      final uploadedFile = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      if (kDebugMode) {
        debugPrint('✅ アップロード成功: ${uploadedFile.id}');
      }

      // Make file shareable and get link
      await driveApi.permissions.create(
        drive.Permission()
          ..type = 'anyone'
          ..role = 'reader',
        uploadedFile.id!,
      );

      final fileUrl = 'https://drive.google.com/file/d/${uploadedFile.id}/view';
      
      return fileUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Google Driveエラー: $e');
      }
      rethrow;
    }
  }

  // Upload to OneDrive
  Future<String?> uploadToOneDrive({
    required String fileName,
    required String content,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 Authenticating with Microsoft...');
      }

      // Microsoft OAuth flow
      final authUrl = Uri.parse(
        '$_msAuthority/oauth2/v2.0/authorize'
        '?client_id=$_msClientId'
        '&response_type=code'
        '&redirect_uri=${Uri.encodeComponent(_msRedirectUri)}'
        '&scope=${Uri.encodeComponent(_msScopes.join(' '))}'
      );

      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'https',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('認証コードの取得に失敗しました');
      }

      // Exchange code for tokens
      final tokenResponse = await http.post(
        Uri.parse('$_msAuthority/oauth2/v2.0/token'),
        body: {
          'client_id': _msClientId,
          'code': code,
          'redirect_uri': _msRedirectUri,
          'grant_type': 'authorization_code',
          'scope': _msScopes.join(' '),
        },
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception('トークンの取得に失敗しました');
      }

      final tokens = jsonDecode(tokenResponse.body);
      final accessToken = tokens['access_token'] as String;

      if (kDebugMode) {
        debugPrint('✅ Microsoft認証成功');
        debugPrint('📤 ファイルをアップロード中...');
      }

      // Upload to OneDrive using Microsoft Graph API
      final uploadResponse = await http.put(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me/drive/root:/$fileName:/content',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'text/csv',
        },
        body: utf8.encode(content),
      );

      if (uploadResponse.statusCode != 200 && uploadResponse.statusCode != 201) {
        throw Exception('アップロードに失敗しました: ${uploadResponse.statusCode}');
      }

      final uploadedFile = jsonDecode(uploadResponse.body);
      final fileId = uploadedFile['id'] as String;

      if (kDebugMode) {
        debugPrint('✅ アップロード成功: $fileId');
      }

      // Create sharing link
      final shareResponse = await http.post(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me/drive/items/$fileId/createLink',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'view',
          'scope': 'anonymous',
        }),
      );

      if (shareResponse.statusCode == 200 || shareResponse.statusCode == 201) {
        final shareData = jsonDecode(shareResponse.body);
        final webUrl = shareData['link']['webUrl'] as String;
        return webUrl;
      }

      return 'https://onedrive.live.com/';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ OneDriveエラー: $e');
      }
      rethrow;
    }
  }

  // Upload to SharePoint (similar to OneDrive)
  Future<String?> uploadToSharePoint({
    required String fileName,
    required String content,
    String? siteId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 Authenticating with Microsoft (SharePoint)...');
      }

      // Use same authentication as OneDrive
      // SharePoint uses Microsoft Graph API as well
      
      // For simplicity, we'll redirect to OneDrive
      // In production, you would specify the SharePoint site
      return await uploadToOneDrive(
        fileName: fileName,
        content: content,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SharePointエラー: $e');
      }
      rethrow;
    }
  }
}

// Custom HTTP client for Google API authentication
class _GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}
