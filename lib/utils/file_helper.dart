import 'dart:convert';
import 'dart:html' as html;

class FileHelper {
  // Download text content as file (Web platform)
  static void downloadFile({
    required String content,
    required String filename,
    String mimeType = 'text/csv',
  }) {
    // Convert content to bytes
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create download link and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();

    // Cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // Generate Google Drive upload URL
  static String generateGoogleDriveUploadUrl(String filename) {
    // Google Drive upload URL
    return 'https://drive.google.com/drive/my-drive';
  }

  // Generate SharePoint upload URL with pre-filled data
  static String generateSharePointUploadUrl(String filename) {
    // SharePoint upload URL (would need to be configured with actual tenant)
    // This is a placeholder that opens SharePoint main page
    return 'https://www.office.com/launch/sharepoint?filename=${Uri.encodeComponent(filename)}';
  }

  // Generate OneDrive upload URL
  static String generateOneDriveUploadUrl(String filename) {
    // OneDrive upload URL
    return 'https://onedrive.live.com/?id=root&cid=root&filename=${Uri.encodeComponent(filename)}';
  }

  // Open URL in new tab
  static void openUrlInNewTab(String url) {
    html.window.open(url, '_blank');
  }
}
