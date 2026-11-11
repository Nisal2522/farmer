import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/app_snack.dart';
import '../../data/models/models.dart';

class LeaveApplyController extends GetxController {
  final type = LeaveType.annual.obs;
  final range = Rxn<DateTimeRange>();
  final halfDay = false.obs;
  final reasonCtrl = TextEditingController();

  bool get isSingleDay => range.value != null && Fmt.isSameDay(range.value!.start, range.value!.end);

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }

  Future<void> pickDates(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: Fmt.dayOnly(now).subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: range.value,
    );
    if (picked == null) return;
    range.value = picked;
    if (!isSingleDay) halfDay.value = false;
  }

  void submit() {
    if (range.value == null) {
      AppSnack.error('Pick your dates', 'Choose the day(s) you will be away.');
      return;
    }
    Get.back(
      result: LeaveRequest(
        id: 'leave${DateTime.now().microsecondsSinceEpoch}',
        type: type.value,
        from: range.value!.start,
        to: range.value!.end,
        status: LeaveStatus.pending,
        halfDay: isSingleDay && halfDay.value,
        reason: reasonCtrl.text.trim(),
      ),
    );
  }
}
