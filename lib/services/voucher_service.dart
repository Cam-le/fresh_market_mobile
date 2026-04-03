import 'package:flutter/foundation.dart';
import '../data/app_data.dart';
import 'api_client.dart';

class VoucherService {
  /// Fetches active vouchers from GET /voucher.
  /// Writes results into [AppData] cache so [AppData.vouchers] is always current.
  /// Returns the list on success, empty list on failure.
  static Future<List<PromoVoucher>> fetchAll() async {
    try {
      final response = await ApiClient.get('/voucher');
      final data = response['data'];
      if (data is! List) return [];

      final result = <PromoVoucher>[];
      for (final raw in data) {
        if (raw is! Map<String, dynamic>) continue;
        final voucher = _fromJson(raw);
        if (voucher != null) result.add(voucher);
      }

      // Populate global cache so PromoCodeScreen (standalone route)
      // also shows live vouchers without needing to re-fetch.
      AppData.setLiveVouchers(result);

      return result;
    } catch (e) {
      debugPrint('[VoucherService] fetchAll error: $e');
      return [];
    }
  }

  static PromoVoucher? _fromJson(Map<String, dynamic> json) {
    final id = json['voucherId'];
    if (id == null) return null;

    final code = json['voucherCode'] as String? ?? '';
    final title = json['voucherName'] as String? ?? code;
    final description = json['description'] as String? ?? '';
    final status = json['status'] as String? ?? '';

    // Only show ACTIVE vouchers to customers
    if (status.toUpperCase() != 'ACTIVE') return null;

    final discountPct = json['discountPercentage'];
    final discountAmt = json['discountAmount'];
    final isPercent = discountPct != null;
    final discount = isPercent ? _safeInt(discountPct) : _safeInt(discountAmt);

    // validFrom is the minimum order amount in the API (e.g. 500000)
    final minOrder = _safeInt(json['validFrom']);

    // Build an expiry label from toDate if available
    final toDateStr = json['toDate'] as String?;
    String expiry = 'Không giới hạn';
    if (toDateStr != null) {
      final dt = DateTime.tryParse(toDateStr);
      if (dt != null) {
        expiry =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      }
    }

    return PromoVoucher(
      id: _safeInt(id),
      code: code,
      title: title,
      description: description,
      expiry: expiry,
      discount: discount,
      isPercent: isPercent,
      minOrder: minOrder,
    );
  }

  static int _safeInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }
}
