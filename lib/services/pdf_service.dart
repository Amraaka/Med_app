import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models.dart';

class PdfService {
  static final PdfPageFormat prescriptionFormat = PdfPageFormat(
    99 * PdfPageFormat.mm,
    215 * PdfPageFormat.mm,
    marginAll: 0,
  );

  // ====== Constants ======
  static const String _headerText1 =
      'Эрүүл мэндийн сайдын 2019 оны 12 дугаар сарын 30-ны өдрийн';
  static const String _headerText2 =
      'А/611 дугаар тушаалын арваннэгдүгээр хавсралт';
  static const String _headerText3 = 'Эрүүл мэндийн бүртгэлийн маягт АМ-9А';

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
        format: prescriptionFormat,
        usePrinterSettings: false, // Show at actual prescription size
      );
    } catch (e) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    }
  }

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

  /// Optional: Preview on an A4 sheet with the prescription centered.
  /// This doesn't change the prescription size; it only wraps it on A4 for printers
  /// that don't support custom paper sizes.
  static Future<void> showPrescriptionOnA4(
    context,
    Patient patient,
    Prescription presc, {
    bool centered = true,
  }) async {
    final doc = pw.Document();
    final ttf = await _loadMongolianFont();

    final styleTitle = pw.TextStyle(
      font: ttf,
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );
    final styleSmall = pw.TextStyle(font: ttf, fontSize: 6.5);
    final style = pw.TextStyle(font: ttf, fontSize: 8);
    final styleBold = pw.TextStyle(
      font: ttf,
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );

    // Determine stripe color based on prescription type (optional on A4)
    PdfColor? stripeColor;
    if (presc.type == PrescriptionType.psychotropic) {
      stripeColor = PdfColors.green;
    } else if (presc.type == PrescriptionType.narcotic) {
      stripeColor = PdfColors.yellow;
    }

    // Build the same content we use for the fixed-size page
    final body = pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildTopHeader(styleSmall),
          pw.SizedBox(height: 3),
          _buildPrescriptionBox(patient, presc, styleTitle, style, styleBold),
          pw.SizedBox(height: 3),
          _buildBottomTable(presc, style, styleBold),
        ],
      ),
    );

    // Create an A4 page and place the prescription in a fixed-size container
    final card = pw.Container(
      width: 99 * PdfPageFormat.mm,
      height: 215 * PdfPageFormat.mm,
      color: PdfColors.black,
      child: pw.Stack(
        children: [
          if (stripeColor != null)
            // draw stripe over the card area (not the whole A4)
            () {
              final w = 99 * PdfPageFormat.mm;
              final h = 215 * PdfPageFormat.mm;
              final diagonal = math.sqrt(w * w + h * h);
              final stripeWidth = 2 * PdfPageFormat.mm;
              return pw.Positioned(
                left: (w - diagonal) / 2,
                top: (h - stripeWidth) / 2,
                child: pw.Transform.rotate(
                  angle: -math.atan(h / w),
                  child: pw.Container(
                    width: diagonal,
                    height: stripeWidth,
                    color: stripeColor!,
                  ),
                ),
              );
            }(),
          body,
        ],
      ),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => centered
            ? pw.Center(child: card)
            : pw.Align(alignment: pw.Alignment.topLeft, child: card),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: _buildFilename(patient, presc).replaceFirst('.pdf', '_A4.pdf'),
      format: PdfPageFormat.a4,
      usePrinterSettings: false,
    );
  }

  // ====== Internal ======
  static Future<pw.Font> _loadMongolianFont() async {
    // Try Times New Roman first (as in example), fallback to NotoSans, then Helvetica
    try {
      final tnr = await rootBundle.load('assets/fonts/TimesNewRoman.ttf');
      return pw.Font.ttf(tnr);
    } catch (_) {
      try {
        final noto = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
        return pw.Font.ttf(noto);
      } catch (_) {
        return pw.Font.helvetica();
      }
    }
  }

  static String _buildFilename(Patient patient, Prescription presc) =>
      'Жор_${patient.familyName}_${presc.createdAt.year}${presc.createdAt.month}${presc.createdAt.day}.pdf';

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

  static pw.PageTheme _pageTheme({PdfColor? stripeColor}) {
    return pw.PageTheme(
      pageFormat: prescriptionFormat,
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Container(color: PdfColors.white),
            if (stripeColor != null) _diagonalStripe(stripeColor: stripeColor),
          ],
        ),
      ),
    );
  }

  static pw.Widget _diagonalStripe({required PdfColor stripeColor}) {
    final w = prescriptionFormat.width;
    final h = prescriptionFormat.height;
    final diagonal = math.sqrt(w * w + h * h);
    final stripeWidth = 1 * PdfPageFormat.mm;

    return pw.Positioned(
      left: (w - diagonal) / 2,
      top: (h - stripeWidth) / 2,
      child: pw.Transform.rotate(
        angle: -math.atan(h / w),
        child: pw.Container(
          width: diagonal,
          height: stripeWidth,
          color: stripeColor,
        ),
      ),
    );
  }

  static Future<Uint8List> _buildPrescriptionPdfBytes(
    Patient patient,
    Prescription presc,
  ) async {
    final doc = pw.Document();
    final ttf = await _loadMongolianFont();

    final styleTitle = pw.TextStyle(
      font: ttf,
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );
    final styleSmall = pw.TextStyle(font: ttf, fontSize: 6.5);
    final style = pw.TextStyle(font: ttf, fontSize: 8);
    final styleBold = pw.TextStyle(
      font: ttf,
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );

    // Determine stripe color based on prescription type
    PdfColor? stripeColor;
    if (presc.type == PrescriptionType.psychotropic) {
      stripeColor = PdfColors.green;
    } else if (presc.type == PrescriptionType.narcotic) {
      stripeColor = PdfColors.yellow;
    }

    doc.addPage(
      pw.Page(
        pageTheme: _pageTheme(stripeColor: stripeColor),
        build: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildTopHeader(styleSmall),
              pw.SizedBox(height: 3),
              _buildPrescriptionBox(
                patient,
                presc,
                styleTitle,
                style,
                styleBold,
              ),
              pw.SizedBox(height: 3),
              _buildBottomTable(presc, style, styleBold),
            ],
          ),
        ),
      ),
    );

    return Uint8List.fromList(await doc.save());
  }

  // ====== Widgets ======

  // Helper method for safe string handling
  static String _safeStr(String? text, {String fallback = ''}) {
    return text?.trim().isEmpty ?? true ? fallback : text!;
  }

  // Helper method for date formatting
  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day / $month / $year';
  }

  static pw.Widget _buildTopHeader(pw.TextStyle style) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(_headerText1, style: style, textAlign: pw.TextAlign.center),
        pw.Text(_headerText2, style: style, textAlign: pw.TextAlign.center),
        pw.Text(_headerText3, style: style, textAlign: pw.TextAlign.center),
      ],
    );
  }

  static pw.Widget _buildPrescriptionBox(
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          // Title
          pw.Center(
            child: pw.Text(_titleByType(presc.type), style: styleTitle),
          ),
          pw.SizedBox(height: 2),

          // Date line with actual date
          pw.Center(child: pw.Text(_formatDate(presc.createdAt), style: style)),
          pw.SizedBox(height: 3),

          // Patient name with underline
          pw.Row(
            children: [
              pw.Text('Өвчтөний овог, нэр: ', style: style),
              pw.Expanded(
                child: pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                  ),
                  child: pw.Text(_safeStr(patient.fullName), style: style),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),

          // Age, Sex, Diagnosis line with underlines
          pw.Row(
            children: [
              pw.Text('Нас: ', style: style),
              pw.Container(
                width: 20,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                ),
                child: pw.Text('${patient.age}', style: style),
              ),
              pw.SizedBox(width: 2),
              pw.Text('Хүйс: ', style: style),
              pw.Container(
                width: 18,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                ),
                child: pw.Text(
                  patient.sex.name == 'male' ? 'Эр' : 'Эм',
                  style: style,
                ),
              ),
              pw.SizedBox(width: 2),
              pw.Text('Онош: ', style: style),
              pw.Expanded(
                child: pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                  ),
                  child: pw.Text(_safeStr(presc.diagnosis), style: style),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),

          pw.Row(
            children: [
              pw.Text('Регистрийн №: ', style: style),
              pw.Expanded(
                child: pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                  ),
                  child: pw.Text(
                    _safeStr(patient.registrationNumber),
                    style: style,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          ..._buildDrugSection(presc, style, styleBold),

          pw.SizedBox(height: 3),

          // Doctor and clinic information
          pw.Container(
            height: 0.5,
            color: PdfColors.grey800,
            margin: const pw.EdgeInsets.symmetric(vertical: 2),
          ),
          pw.Text(
            'Жор бичсэн эмчийн нэр, утас: ${_safeStr(presc.doctorName)} ${_safeStr(presc.doctorPhone)}',
            style: style,
          ),
          pw.SizedBox(height: 1.5),
          pw.Text('Тэмдэг: _________________', style: style),
          pw.SizedBox(height: 1.5),
          pw.Text('Эмнэлгийн нэр: ${_safeStr(presc.clinicName)}', style: style),
          pw.SizedBox(height: 2),
          // Tear-off line
          pw.Row(
            children: List.generate(
              80,
              (i) => pw.Container(
                width: 2,
                height: 1,
                margin: const pw.EdgeInsets.symmetric(horizontal: 0.5),
                color: PdfColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildDrugSection(
    Prescription presc,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    final widgets = <pw.Widget>[];
    final drugs = presc.drugs.take(3).toList();

    for (int i = 0; i < 3; i++) {
      if (i < drugs.length) {
        final drug = drugs[i];
        // Build drug info string
        String drugInfo = _safeStr(drug.mongolianName);
        if (drug.dose.isNotEmpty) {
          drugInfo += ' ${drug.dose}';
        }
        if (drug.form.isNotEmpty) {
          drugInfo += ' (${drug.form})';
        }

        widgets.addAll([
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rp: ', style: styleBold),
              pw.Expanded(child: pw.Text(drugInfo, style: style)),
            ],
          ),
          pw.Row(
            children: [
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Text(
                  'D.t.d. № ${drug.quantity}${drug.treatmentDays != null ? " (${drug.treatmentDays} хоног)" : ""}',
                  style: style,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('S: ', style: styleBold),
              pw.Expanded(
                child: pw.Text(_safeStr(drug.instructions), style: style),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
        ]);
      } else {
        // Empty slot for unused prescription lines
        widgets.addAll([
          pw.Row(
            children: [
              pw.Text('Rp: ', style: styleBold),
              pw.Expanded(
                child: pw.Container(
                  height: 6,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.3)),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text('S: ', style: styleBold),
              pw.Expanded(
                child: pw.Container(
                  height: 6,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.3)),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
        ]);
      }
    }

    return widgets;
  }

  static pw.Widget _buildBottomTable(
    Prescription presc,
    pw.TextStyle style,
    pw.TextStyle styleBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: pw.FixedColumnWidth(15),
        1: pw.FlexColumnWidth(2.5),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(1.2),
      },
      children: [
        // Header row
        pw.TableRow(
          children: [
            _tableCell('№', styleBold, center: true, minHeight: 10),
            _tableCell(
              'Эмийн нэр, тун, хэмжээ, хэлбэр',
              styleBold,
              center: true,
              minHeight: 10,
            ),
            _tableCell(
              'Хэрэглэх арга, хугацаа',
              styleBold,
              center: true,
              minHeight: 10,
            ),
            _tableCell(
              'Олгосон\n/гарын үсэг/',
              styleBold,
              center: true,
              minHeight: 10,
            ),
          ],
        ),
        // Data rows
        ...List.generate(3, (index) {
          if (index < presc.drugs.length) {
            final d = presc.drugs[index];
            return pw.TableRow(
              children: [
                _tableCell('${index + 1}', style, center: true, minHeight: 14),
                _tableCell(
                  '${_safeStr(d.mongolianName)}\n${_safeStr(d.dose)}, ${_safeStr(d.form)}, ${d.quantity}',
                  style,
                  minHeight: 14,
                ),
                _tableCell(_safeStr(d.instructions), style, minHeight: 14),
                _tableCell('', style, minHeight: 14),
              ],
            );
          } else {
            return pw.TableRow(
              children: [
                _tableCell('${index + 1}', style, center: true, minHeight: 14),
                _tableCell('', style, minHeight: 14),
                _tableCell('', style, minHeight: 14),
                _tableCell('', style, minHeight: 14),
              ],
            );
          }
        }),
      ],
    );
  }

  static pw.Widget _tableCell(
    String text,
    pw.TextStyle style, {
    bool center = false,
    double minHeight = 0,
  }) {
    return pw.Container(
      constraints: minHeight > 0
          ? pw.BoxConstraints(minHeight: minHeight)
          : null,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
      child: pw.Text(
        text,
        style: style,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
}
