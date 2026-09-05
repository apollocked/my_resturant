import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/core/services/printer_config.dart';

class ReceiptFormatter {
  static Uint8List kitchenTicket(Order order, PrinterConfig config, Locale locale) {
    String tr(String key) => Tr.get(key, locale);
    final restaurantName =
        config.restaurantName.isNotEmpty ? config.restaurantName : tr('restaurant_name');
    final buf = BytesBuilder();
    _init(buf);
    _center(buf);
    _bold(buf);
    _large(buf);
    _text(buf, restaurantName);
    _normal(buf);
    _reset(buf);
    _lf2(buf);
    _center(buf);
    _bold(buf);
    _text(buf, tr('receipt_kitchen_header'));
    _reset(buf);
    _lf(buf);
    _left(buf);
    _text(buf, '${tr('receipt_table')}: ${order.displayTable}');
    _text(buf, '${tr('receipt_order')}: ${order.displayTrackingCode}');
    _text(buf, '${tr('receipt_time')}: ${_time(order.createdAt)}');
    _lf(buf);
    _text(buf, '-------------------------------');
    _lf(buf);
    for (final item in order.items) {
      _bold(buf);
      _text(buf, 'x${item.quantity}  ${item.recipe.name}');
      _reset(buf);
      if (item.notes.isNotEmpty) {
        _text(buf, '  ${tr('receipt_note')}: ${item.notes}');
      }
    }
    _lf(buf);
    _text(buf, '-------------------------------');
    if (order.notes.isNotEmpty) {
      _lf(buf);
      _bold(buf);
      _text(buf, '${tr('receipt_notes')}: ${order.notes}');
      _reset(buf);
    }
    _lf2(buf);
    _cut(buf);
    return buf.toBytes();
  }

  static Uint8List fullReceipt(Order order, PrinterConfig config, Locale locale) {
    String tr(String key) => Tr.get(key, locale);
    final restaurantName =
        config.restaurantName.isNotEmpty ? config.restaurantName : tr('restaurant_name');
    final buf = BytesBuilder();
    _init(buf);
    _center(buf);
    _bold(buf);
    _large(buf);
    _text(buf, restaurantName);
    _normal(buf);
    _reset(buf);
    _lf(buf);
    _left(buf);
    _text(buf, '${tr('receipt_table')}: ${order.displayTable}');
    _text(buf, '${tr('receipt_order')}: ${order.displayTrackingCode}');
    _text(buf, '${tr('receipt_date')}: ${_date(order.createdAt)}');
    _text(buf, '${tr('receipt_time')}: ${_time(order.createdAt)}');
    _lf(buf);
    _text(buf, '-----------------------------------');
    _lf(buf);
    _text(buf, '${tr('receipt_header_item')}          ${tr('receipt_header_qty')}   ${tr('receipt_header_price')}');
    _text(buf, '-----------------------------------');
    for (final item in order.items) {
      _receiptItem(buf, item);
    }
    _lf(buf);
    _text(buf, '-----------------------------------');
    _bold(buf);
    _text(buf, '${tr('receipt_total')}:          ${order.totalPrice.toInt()}');
    _reset(buf);
    _text(buf, '-----------------------------------');
    if (order.notes.isNotEmpty) {
      _lf(buf);
      _text(buf, '${tr('receipt_notes')}: ${order.notes}');
    }
    _lf(buf);
    _center(buf);
    _text(buf, tr('receipt_thanks'));
    _lf2(buf);
    _cut(buf);
    return buf.toBytes();
  }

  static void _receiptItem(BytesBuilder buf, CartItem item) {
    final name = item.recipe.name;
    final n = name.length > 12 ? name.substring(0, 12) : name;
    final q = 'x${item.quantity}'.padRight(5);
    final p = item.totalPrice.toInt().toString();
    _text(buf, '${n.padRight(12)}$q$p');
    if (item.notes.isNotEmpty) _text(buf, '  > ${item.notes}');
  }

  static void _init(BytesBuilder buf) => buf.add([0x1B, 0x40]);
  static void _center(BytesBuilder buf) => buf.add([0x1B, 0x61, 0x01]);
  static void _left(BytesBuilder buf) => buf.add([0x1B, 0x61, 0x00]);
  static void _bold(BytesBuilder buf) => buf.add([0x1B, 0x45, 0x01]);
  static void _reset(BytesBuilder buf) => buf.add([0x1B, 0x45, 0x00]);
  static void _large(BytesBuilder buf) => buf.add([0x1D, 0x21, 0x11]);
  static void _normal(BytesBuilder buf) => buf.add([0x1D, 0x21, 0x00]);
  static void _lf(BytesBuilder buf) => buf.add([0x0A]);
  static void _lf2(BytesBuilder buf) => buf.add([0x0A, 0x0A]);

  static void _text(BytesBuilder buf, String t) {
    buf.add(utf8.encode('$t\n'));
  }

  static void _cut(BytesBuilder buf) {
    buf.add([0x1D, 0x64, 0x03, 0x1D, 0x56, 0x00]);
  }

  static String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
