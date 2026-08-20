import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/core/services/printer_service.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

class PrinterState {
  final PrinterConfig config;
  final bool isConnected;
  final bool isPrinting;
  final String? error;
  const PrinterState({
    this.config = const PrinterConfig(),
    this.isConnected = false,
    this.isPrinting = false,
    this.error,
  });

  PrinterState copyWith({
    PrinterConfig? config,
    bool? isConnected,
    bool? isPrinting,
    String? error,
    bool clearError = false,
  }) => PrinterState(
    config: config ?? this.config,
    isConnected: isConnected ?? this.isConnected,
    isPrinting: isPrinting ?? this.isPrinting,
    error: clearError ? null : (error ?? this.error),
  );
}

class PrinterCubit extends Cubit<PrinterState> {
  final PrinterService _service;
  StreamSubscription? _sub;

  PrinterCubit(this._service) : super(const PrinterState()) {
    _sub = _service.statusStream.listen((connected) {
      if (!isClosed) emit(state.copyWith(isConnected: connected));
    });
  }

  Future<void> init() async {
    await _service.init();
    if (!isClosed) {
      emit(state.copyWith(
        config: _service.config,
        isConnected: _service.isConnected,
      ));
    }
  }

  Future<void> updateConfig(PrinterConfig config) async {
    await _service.updateConfig(config);
    if (!isClosed) {
      emit(state.copyWith(
        config: config,
        isConnected: _service.isConnected,
        clearError: true,
      ));
    }
  }

  Future<bool> connect() async {
    final ok = await _service.connect();
    if (!isClosed) emit(state.copyWith(isConnected: ok));
    return ok;
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    if (!isClosed) emit(state.copyWith(isConnected: false));
  }

  Future<bool> printKitchen(Order order) async {
    if (!state.isConnected) {
      final ok = await connect();
      if (!ok) {
        if (!isClosed) emit(state.copyWith(error: 'printer_not_connected'));
        return false;
      }
    }
    if (!isClosed) emit(state.copyWith(isPrinting: true, clearError: true));
    final ok = await _service.printKitchenTicket(order);
    if (!isClosed) emit(state.copyWith(isPrinting: false));
    return ok;
  }

  Future<bool> printReceipt(Order order) async {
    if (!state.isConnected) {
      final ok = await connect();
      if (!ok) {
        if (!isClosed) emit(state.copyWith(error: 'printer_not_connected'));
        return false;
      }
    }
    if (!isClosed) emit(state.copyWith(isPrinting: true, clearError: true));
    final ok = await _service.printFullReceipt(order);
    if (!isClosed) emit(state.copyWith(isPrinting: false));
    return ok;
  }

  void clearError() {
    if (!isClosed) emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
