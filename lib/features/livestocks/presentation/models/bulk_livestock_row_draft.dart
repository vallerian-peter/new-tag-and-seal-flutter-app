import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String buildBulkLivestockIdentificationSerial(
  DateTime dateOfBirth,
  int index,
  int total,
) {
  final prefix = DateFormat('yyyyMMdd').format(dateOfBirth);
  final width = total > 99 ? 3 : 2;
  return '$prefix-${index.toString().padLeft(width, '0')}';
}

class BulkLivestockRowDraft {
  BulkLivestockRowDraft({
    required this.identificationNumber,
    this.uuid,
    required this.namePrefixController,
    required this.nicknameController,
    required this.officialIdController,
    required this.dummyTagIdController,
    required this.barcodeTagIdController,
    required this.rfidTagIdController,
    required this.weightController,
    required this.disposalReasonController,
    required this.disposalRemarksController,
    required this.isDeadAtBirth,
  });

  String identificationNumber;
  String? uuid;
  bool isDeadAtBirth;
  String? gender;
  String? statusOverride;
  String? motherUuidOverride;
  String? fatherUuidOverride;
  String? birthEventUuidOverride;
  DateTime? dateOfBirthOverride;
  bool? isIdentifiedOverride;
  int? obtainedMethodIdOverride;
  DateTime? dateEnteredFarmOverride;
  String? primaryColorOverride;
  String? secondaryColorOverride;
  int? disposalTypeId;
  DateTime? disposalDate;
  bool individualDetailsExpanded = false;

  final TextEditingController namePrefixController;
  final TextEditingController nicknameController;
  final TextEditingController officialIdController;
  final TextEditingController dummyTagIdController;
  final TextEditingController barcodeTagIdController;
  final TextEditingController rfidTagIdController;
  final TextEditingController weightController;
  final TextEditingController disposalReasonController;
  final TextEditingController disposalRemarksController;
}
