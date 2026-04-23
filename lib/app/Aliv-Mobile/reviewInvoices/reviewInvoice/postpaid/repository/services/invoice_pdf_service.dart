import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// Service for handling invoice PDF operations with caching support.
class InvoicePdfService {
  String? _cacheDirPath;

  /// Gets the cache directory path (lazily initialized).
  Future<String> get _cacheDir async {
    if (_cacheDirPath != null) return _cacheDirPath!;
    final tempDir = await getTemporaryDirectory();
    _cacheDirPath = tempDir.path;
    return _cacheDirPath!;
  }

  /// Returns the cache file path for an invoice.
  Future<String> getCachePath(int invoiceId) async {
    final dir = await _cacheDir;
    return '$dir/invoice_$invoiceId.pdf';
  }

  /// Checks if PDF is already cached for the given invoice.
  Future<bool> isCached(int invoiceId) async {
    final path = await getCachePath(invoiceId);
    return File(path).existsSync();
  }

  /// Decodes base64 PDF and saves to cache.
  Future<String> decodeAndSavePdf(String base64String, int invoiceId) async {
    if (kDebugMode) {
      debugPrint('InvoicePdfService: Decoding PDF for invoice $invoiceId');
    }

    final cleanBase64 = base64String.replaceAll(RegExp(r'\s'), '');
    final bytes = base64Decode(cleanBase64);

    final filePath = await getCachePath(invoiceId);
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (kDebugMode) {
      debugPrint('InvoicePdfService: PDF cached at $filePath');
    }

    return filePath;
  }

  /// Opens a PDF file with the system viewer.
  Future<bool> openPdf(String filePath) async {
    if (kDebugMode) {
      debugPrint('InvoicePdfService: Opening PDF at $filePath');
    }

    final result = await OpenFilex.open(filePath, type: 'application/pdf');

    if (kDebugMode) {
      debugPrint('InvoicePdfService: Open result: ${result.type}');
    }

    // Fallback to share on iOS if no app found
    if (result.type == ResultType.noAppToOpen && Platform.isIOS) {
      await sharePdf(filePath, 'Invoice');
      return true;
    }

    return result.type == ResultType.done;
  }

  /// Shares a PDF file via the system share sheet.
  Future<void> sharePdf(String filePath, String invoiceNo) async {
    if (kDebugMode) {
      debugPrint('InvoicePdfService: Sharing PDF');
    }

    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Invoice $invoiceNo',
    );
  }

  /// Saves a PDF to the downloads folder.
  Future<bool> savePdfToDownloads(String sourcePath, String invoiceNo) async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) return false;
      }
    }

    try {
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) return false;

      final destinationPath = '${downloadsDir.path}/invoice_$invoiceNo.pdf';
      await File(sourcePath).copy(destinationPath);

      if (kDebugMode) {
        debugPrint('InvoicePdfService: Saved to $destinationPath');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoicePdfService: Error saving: $e');
      }
      return false;
    }
  }

  /// Clears all cached PDFs.
  Future<void> clearCache() async {
    final dir = await _cacheDir;
    final cacheDir = Directory(dir);
    final files = cacheDir.listSync().whereType<File>();

    for (final file in files) {
      if (file.path.contains('invoice_') && file.path.endsWith('.pdf')) {
        await file.delete();
      }
    }

    if (kDebugMode) {
      debugPrint('InvoicePdfService: Cache cleared');
    }
  }
}
