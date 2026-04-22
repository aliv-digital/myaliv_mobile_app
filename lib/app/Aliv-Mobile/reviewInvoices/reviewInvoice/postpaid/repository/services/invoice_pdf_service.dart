import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// Service for handling invoice PDF operations.
///
/// Responsibilities:
/// - Decode base64 PDF and save to file
/// - Open PDF with system viewer
/// - Share PDF via system share sheet
/// - Save PDF to downloads folder
class InvoicePdfService {
  /// Decodes base64 PDF string and saves to a temporary file.
  ///
  /// Returns the file path of the saved PDF.
  Future<String> decodeAndSavePdf(String base64String, String invoiceNo) async {
    if (kDebugMode) {
      debugPrint('InvoicePdfService: Decoding PDF for invoice $invoiceNo');
    }

    // Clean the base64 string (remove any whitespace or newlines)
    final cleanBase64 = base64String.replaceAll(RegExp(r'\s'), '');

    // Decode base64 to bytes
    final bytes = base64Decode(cleanBase64);

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final fileName = 'invoice_$invoiceNo.pdf';
    final filePath = '${tempDir.path}/$fileName';

    // Write to file
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (kDebugMode) {
      debugPrint('InvoicePdfService: PDF saved to $filePath');
    }

    return filePath;
  }

  /// Opens a PDF file with the system viewer.
  Future<bool> openPdf(String filePath) async {
    if (kDebugMode) {
      debugPrint('InvoicePdfService: Opening PDF at $filePath');
    }

    // Specify MIME type for better iOS/Android compatibility
    final result = await OpenFilex.open(filePath, type: 'application/pdf');

    if (kDebugMode) {
      debugPrint('InvoicePdfService: Open result: ${result.type} - ${result.message}');
    }

    // If no app found to open, fallback to share on iOS
    if (result.type == ResultType.noAppToOpen && Platform.isIOS) {
      await sharePdf(filePath, 'Invoice');
      return true;
    }

    return result.type == ResultType.done;
  }

  /// Shares a PDF file via the system share sheet.
  Future<void> sharePdf(String filePath, String invoiceNo) async {
    if (kDebugMode) {
      debugPrint('InvoicePdfService: Sharing PDF at $filePath');
    }

    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Invoice $invoiceNo',
    );
  }

  /// Saves a PDF file to the downloads folder.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> savePdfToDownloads(String sourcePath, String invoiceNo) async {
    if (kDebugMode) {
      debugPrint('InvoicePdfService: Saving PDF to downloads');
    }

    // Request storage permission on Android
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // Try manage external storage for Android 11+
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          if (kDebugMode) {
            debugPrint('InvoicePdfService: Storage permission denied');
          }
          return false;
        }
      }
    }

    try {
      // Get downloads directory
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        if (kDebugMode) {
          debugPrint('InvoicePdfService: Could not get downloads directory');
        }
        return false;
      }

      final fileName = 'invoice_$invoiceNo.pdf';
      final destinationPath = '${downloadsDir.path}/$fileName';

      // Copy file to downloads
      final sourceFile = File(sourcePath);
      await sourceFile.copy(destinationPath);

      if (kDebugMode) {
        debugPrint('InvoicePdfService: PDF saved to $destinationPath');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoicePdfService: Error saving to downloads: $e');
      }
      return false;
    }
  }
}
