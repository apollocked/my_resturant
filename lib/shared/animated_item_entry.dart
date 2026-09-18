import 'package:flutter/material.dart';

/// Bookkeeping for one animated list row.
class AnimEntry {
  AnimEntry(this.id, this.controller);

  final Object id;
  final AnimationController controller;
  bool exiting = false;
  int removedIndex = 0;
}