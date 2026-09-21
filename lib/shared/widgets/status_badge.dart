import 'package:flutter/material.dart';
import '../../data/models/models.dart';
class StatusBadge extends StatelessWidget { const StatusBadge(this.status, {super.key}); final AppointmentStatus status; @override Widget build(BuildContext context) => Chip(label: Text(statusLabel(status)), avatar: const Icon(Icons.circle, size: 10)); }
