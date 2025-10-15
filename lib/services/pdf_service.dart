import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models.dart';

class PdfService {
  // Public API: Preview
  static Future<void> showPrescriptionPdf(
    context,
    Patient patient,
    Prescription presc,
  ) async {
    final bytes = await _buildPrescriptionPdfBytes(patient, presc);
    final filename = _buildFilename(patient, presc);
    try {
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: filename,
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      // Fallback to share if preview isn't available
      await Printing.sharePdf(bytes: bytes, filename: filename);
    }
  }

  // Public API: Direct Share
  static Future<void> sharePrescriptionPdf(
    Patient patient,
    Prescription presc,
  ) async {
    final bytes = await _buildPrescriptionPdfBytes(patient, presc);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _buildFilename(patient, presc),
    );
  }

  // ---------- Internals ----------
  static Future<pw.Font> _loadMongolianFont() async {
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      );
      return pw.Font.ttf(fontData);
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  static String _titleByType(PrescriptionType t) {
    switch (t) {
      case PrescriptionType.psychotropic:
        return 'СЭТГЭЦЭД НӨЛӨӨЛӨХ ЭМИЙН ЖОР';
      case PrescriptionType.narcotic:
        return 'МАНСУУРУУЛАХ ЭМИЙН ЖОР';
      case PrescriptionType.regular:
        return 'ЭНГИЙН ЭМИЙН ЖОР';
    }
  }

  static String _buildFilename(Patient patient, Prescription presc) =>
      'Жор_${patient.familyName}_${presc.createdAt.year}${presc.createdAt.month}${presc.createdAt.day}.pdf';

  static Future<Uint8List> _buildPrescriptionPdfBytes(
    Patient patient,
    Prescription presc,
  ) async {
    final doc = pw.Document();
    final ttf = await _loadMongolianFont();

    final styleTitle = pw.TextStyle(
      font: ttf,
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );
    final styleHeader = pw.TextStyle(font: ttf, fontSize: 11);
    final style = pw.TextStyle(font: ttf, fontSize: 11);
    final styleBold = pw.TextStyle(
      font: ttf,
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildTopHeader(styleHeader),
            pw.SizedBox(height: 20),
            _buildMainContainer(patient, presc, styleTitle, style, styleBold),
            pw.SizedBox(height: 8),
            _buildBottomTable(presc, style, styleBold),
          ],
        ),
      ),
    );

    final data = await doc.save();
    return Uint8List.fromList(data);
  }

  static pw.Widget _buildTopHeader(pw.TextStyle styleHeader) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'Эрүүл мэндийн сайдын 2019 оны 12 дугаар сарын 30-ны өдрийн',
            style: styleHeader,
          ),
          pw.Text(
            'А/611 дугаар тушаалын өрвлнөлгүүлээр хавсралт',
            style: styleHeader,
          ),
          pw.Text('Эрүүл мэндийн бүртгэлийн маягт АМ-9А', style: styleHeader),
        ],
      ),
    );
  }

  static pw.Widget _buildMainContainer(
    Patient patient,
    Prescription presc,
    pw.TextStyle styleTitle,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(_titleByType(presc.type), style: styleTitle),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                '${presc.createdAt.year} оны ${presc.createdAt.month} сарын ${presc.createdAt.day}',
                style: style,
              ),
            ),
            pw.SizedBox(height: 16),
            _buildPatientInfo(patient, presc, style, styleBold),
            pw.SizedBox(height: 12),
            ..._buildDrugsSection(presc, style, styleBold),
            if (presc.drugs.length < 3)
              ..._buildEmptyDrugSlots(presc, style, styleBold),
            if (presc.notes != null && presc.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _buildNotes(presc.notes!, style, styleBold),
            ],
            pw.SizedBox(height: 12),
            _buildDoctorClinicSection(presc, style, styleBold),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.black),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildPatientInfo(
    Patient patient,
    Prescription presc,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Өвчтөний овог, нэр: ${patient.fullName}', style: style),
        pw.SizedBox(height: 8),
        pw.Text(
          'Нас: ${patient.age}  Хүйс: ${patient.sex.name == 'male' ? 'Эр' : 'Эм'}  Онош: ${presc.diagnosis}',
          style: style,
        ),
        pw.SizedBox(height: 4),
        pw.Text('ICD-10: ${presc.icd}', style: style),
        pw.SizedBox(height: 8),
        pw.Text('Регистрийн №: ${patient.registrationNumber}', style: style),
        pw.SizedBox(height: 8),
        pw.Text(
          'Утас: ${patient.phone}  Хаяг: ${patient.address}',
          style: style,
        ),
      ],
    );
  }

  static List<pw.Widget> _buildDrugsSection(
    Prescription presc,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    final maxRows = presc.drugs.length > 3 ? 3 : presc.drugs.length;
    return List.generate(maxRows, (index) {
      final drug = presc.drugs[index];
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Rp:', style: styleBold),
          pw.SizedBox(height: 4),
          pw.Text('${drug.mongolianName}', style: style),
          pw.Text(
            'Тун: ${drug.dose}, Хэлбэр: ${drug.form}, Тоо: ${drug.quantity}' +
                (drug.treatmentDays != null
                    ? ', Хоног: ${drug.treatmentDays}'
                    : ''),
            style: style,
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text('S:', style: styleBold),
              pw.SizedBox(width: 8),
              pw.Expanded(child: pw.Text(drug.instructions, style: style)),
            ],
          ),
          pw.SizedBox(height: 16),
        ],
      );
    });
  }

  static List<pw.Widget> _buildEmptyDrugSlots(
    Prescription presc,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    final widgets = <pw.Widget>[];
    for (int i = presc.drugs.length; i < 3; i++) {
      widgets.addAll([
        pw.Row(
          children: [
            pw.Text('Rp:', style: styleBold),
            pw.SizedBox(width: 100),
            pw.Text('#', style: style),
          ],
        ),
        pw.SizedBox(height: 40),
        pw.Text('S:', style: styleBold),
        pw.SizedBox(height: 40),
      ]);
    }
    return widgets;
  }

  static pw.Widget _buildNotes(
    String notes,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Нэмэлт тайлбар:', style: styleBold),
          pw.SizedBox(height: 4),
          pw.Text(notes, style: style),
        ],
      ),
    );
  }

  static pw.Widget _buildDoctorClinicSection(
    Prescription presc,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (presc.doctorName != null)
          pw.Text(
            'Жор бичсэн эмч: ${presc.doctorName}${presc.doctorPhone != null ? '  Утас: ${presc.doctorPhone}' : ''}',
            style: style,
          ),
        if (presc.clinicName != null)
          pw.Text('Эмнэлгийн нэр: ${presc.clinicName}', style: style),
        if (presc.ePrescriptionCode != null)
          pw.Text('E-жор код: ${presc.ePrescriptionCode}', style: style),
        if (presc.clinicStamp == true)
          pw.Text('Байгууллагын тэмдэг: ТИЙМ', style: style),
        if (presc.generalDoctorSignature == true)
          pw.Text('Ерөнхий эмчийн гарын үсэг: ТИЙМ', style: style),
        if (presc.specialIndex != null || presc.serialNumber != null)
          pw.Text(
            'Индекс/Серийн дугаар: ${presc.specialIndex ?? ''} / ${presc.serialNumber ?? ''}',
            style: style,
          ),
        if (presc.receiverName != null)
          pw.Text(
            'Хүлээн авагч: ${presc.receiverName}  РД: ${presc.receiverReg ?? ''}  Утас: ${presc.receiverPhone ?? ''}',
            style: style,
          ),
      ],
    );
  }

  static pw.Widget _buildBottomTable(
    Prescription presc,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Center(child: pw.Text('№', style: styleBold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Center(
                child: pw.Text(
                  'Эмийн нэр, тун,\nхэмжээ, хэлбэр',
                  style: styleBold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Center(
                child: pw.Text(
                  'Хэрэглэх арга,\nхугацаа',
                  style: styleBold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Center(
                child: pw.Text(
                  'Олгосон\n/гарын үсэг/',
                  style: styleBold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        ...List.generate(3, (index) {
          if (index < presc.drugs.length) {
            final drug = presc.drugs[index];
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Center(
                    child: pw.Text('${index + 1}', style: style),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    '${drug.mongolianName}\n${drug.dose}, ${drug.form}, ${drug.quantity}' +
                        (drug.treatmentDays != null
                            ? ', ${drug.treatmentDays} хоног'
                            : ''),
                    style: style,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(drug.instructions, style: style),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('', style: style),
                ),
              ],
            );
          } else {
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Center(
                    child: pw.Text('${index + 1}', style: style),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Text('', style: style),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Text('', style: style),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Text('', style: style),
                ),
              ],
            );
          }
        }),
      ],
    );
  }
}
