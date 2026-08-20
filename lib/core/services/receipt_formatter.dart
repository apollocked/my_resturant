import 'dart:convert';
import 'dart:typed_data';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/core/services/printer_config.dart';

class ReceiptFormatter {
  static const _esc = [0x1B];
  static const _gs = [0x1D];
  static const _lf = [0x0A];
  static const _cut = [0x1D, 0x56, 0x00];

  static Uint8List kitchenTicket(
    Order order,
    PrinterConfig config,
  ) {
    final buf = BytesBuilder();
    _initPrinter(buf);
    _centerAlign(buf);
    _bold(buf);
    _largeText(buf);
    _addText(buf, config.restaurantName);
    _normalText(buf);
    _resetBold(buf);
    _addLine(buf);
    _centerAlign(buf);
    _bold(buf);
    _addText(buf, 'KITCHEN ORDER');
    _resetBold(buf);
    _addLine(buf);
    _leftAlign(buf);
    _addText(buf, 'Table: ${order.displayTable}');
    _addText(buf, 'Order: ${order.displayTrackingCode}');
    _addText(buf, 'Time: ${_formatTime(order.createdAt)}');
    _addLine(buf);
    _addText(buf, '-------------------------------');
    _addLine(buf);
    for (final item in order.items) {
      _bold(buf);
      _addText(buf, 'x${item.quantity}  ${item.recipe.name}');
      _resetBold(buf);
      if (item.notes.isNotEmpty) {
        _addText(buf, '  Note: ${item.notes}');
      }
    }
    _addLine(buf);
    _addText(buf, '-------------------------------');
    if (order.notes.isNotEmpty) {
      _addLine(buf);
      _bold(buf);
      _addText(buf, 'Order Notes: ${order.notes}');
      _resetBold(buf);
    }
    _addLine(buf);
    _addLine(buf);
    _feedAndCut(buf);
    return buf.toBytes();
  }

  static Uint8List fullReceipt(
    Order order,
    PrinterConfig config,
  ) {
    final buf = BytesBuilder();
    _initPrinter(buf);
    _centerAlign(buf);
    _bold(buf);
    _largeText(buf);
    _addText(buf, config.restaurantName);
    _normalText(buf);
    _resetBold(buf);
    _addLine(buf);
    _leftAlign(buf);
    _addText(buf, 'Table: ${order.displayTable}');
    _addText(buf, 'Order: ${order.displayTrackingCode}');
    _addText(buf, 'Date: ${_formatDate(order.createdAt)}');
    _addText(buf, 'Time: ${_formatTime(order.createdAt)}');
    _addLine(buf);
    _addText(buf, '-----------------------------------');
    _addLine(buf);
    _addText(buf, 'Item          Qty   Price');
    _addText(buf, '-----------------------------------');
    for (final item in order.items) {
      _addReceiptItem(buf, item);
    }
    _addLine(buf);
    _addText(buf, '-----------------------------------');
    _bold(buf);
    final total = order.totalPrice.toInt();
    _addText(buf, 'TOTAL:          $total');
    _resetBold(buf);
    _addText(buf, '-----------------------------------');
    if (order.notes.isNotEmpty) {
      _addLine(buf);
      _addText(buf, 'Notes: ${order.notes}');
    }
    _addLine(buf);
    _centerAlign(buf);
    _addText(buf, 'Thank you!');
    _addLine(buf);
    _addLine(buf);
    _feedAndCut(buf);
    return buf.toBytes();
  }

  static void _addReceiptItem(BytesBuilder buf, CartItem item) {
    final name = item.recipe.name;
    final qty = 'x${item.quantity}';
    final price = item.totalPrice.toInt().toString();
    final nameLen = name.length > 12 ? 12 : name.length;
    final padded = name.substring(0, nameLen).padRight(12);
    final qtyPadded = qty.padRight(5);
    _addText(buf, '$padded$qtyPadded$price');
    if (item.notes.isNotEmpty) {
      _addText(buf, '  > ${item.notes}');
    }
  }

  static void _initPrinter(BytesBuilder buf) {
    buf.write([0x1B, 0x40]); // ESC @
  }

  static void _centerAlign(BytesBuilder buf) =>
      buf.write([0x1B, 0x61, 0x01]);

  static void _leftAlign(BytesBuilder buf) =>
      buf.write([0x1B, 0x61, 0x00]);

  static void _bold(BytesBuilder buf) =>
      buf.write([0x1B, 0x45, 0x01]);

  static void _resetBold(BytesBuilder buf) =>
      buf.write([0x1B, 0x45, 0x00]);

  static void _largeText(BytesBuilder buf) =>
      buf.write([0x1D, 0x21, 0x11]); // double height+width

  static void _normalText(BytesBuilder buf) =>
      buf.write([0x1D, 0x21, 0x00]);

  static void _addText(BytesBuilder buf, String text) {
    buf.write(utf8.encode('$text\n'));
  }

  static void _addLine(BytesBuilder buf) => buf.write(_lf);

  static void _feedAndCut(BytesBuilder buf) {
    buf.write([0x1D, 0x64, 0x03]); // feed 3 lines
    buf.write(_cut);
  }

  static String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
