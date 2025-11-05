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
        usePrinterSettings: false,
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

  static Future<Uint8List> generatePrescriptionPng(
    Patient patient,
    Prescription presc, {
    double dpi = 300,
  }) async {
    final pdfBytes = await _buildPrescriptionPdfBytes(patient, presc);
    final rasterPage = await Printing.raster(
      pdfBytes,
      pages: const [0],
      dpi: dpi,
    ).first;
    return await rasterPage.toPng();
  }

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

    PdfColor? stripeColor;
    if (presc.type == PrescriptionType.psychotropic) {
      stripeColor = PdfColors.green;
    } else if (presc.type == PrescriptionType.narcotic) {
      stripeColor = PdfColors.yellow;
    }

    final body = pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildTopHeader(styleSmall),
          pw.SizedBox(height: 2),
          _buildPrescriptionBox(patient, presc, styleTitle, style, styleBold),
          pw.SizedBox(height: 2),
          _buildBottomTable(presc, style, styleBold),
        ],
      ),
    );

    final card = pw.Container(
      width: 99 * PdfPageFormat.mm,
      height: 215 * PdfPageFormat.mm,
      color: PdfColors.black,
      child: pw.Stack(
        children: [
          if (stripeColor != null)
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
        build: (_) => pw.Container(
          width: PdfPageFormat.a4.width,
          height: PdfPageFormat.a4.height,
          child: pw.Stack(
            children: [pw.Positioned(top: 0, right: 0, child: card)],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: _buildFilename(patient, presc).replaceFirst('.pdf', '_A4.pdf'),
      format: PdfPageFormat.a4,
      usePrinterSettings: false,
    );
  }

  static Future<pw.Font> _loadMongolianFont() async {
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
              pw.SizedBox(height: 1),
              _buildPrescriptionBox(
                patient,
                presc,
                styleTitle,
                style,
                styleBold,
              ),
            ],
          ),
        ),
      ),
    );

    return Uint8List.fromList(await doc.save());
  }

  static String _safeStr(String? text, {String fallback = ''}) {
    return text?.trim().isEmpty ?? true ? fallback : text!;
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year оны $month сарын $day';
  }

  static pw.Widget _buildTopHeader(pw.TextStyle style) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(height: 3),
        pw.Text(_headerText1, style: style, textAlign: pw.TextAlign.end),
        pw.Text(_headerText2, style: style, textAlign: pw.TextAlign.end),
        pw.Text(_headerText3, style: style, textAlign: pw.TextAlign.end),
        pw.SizedBox(height: 3),
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
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.max,
        children: [
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(_titleByType(presc.type), style: styleTitle),
          ),
          pw.SizedBox(height: 4),

          pw.Padding(
            padding: pw.EdgeInsets.all(4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(_formatDate(presc.createdAt), style: style),
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text('Өвчтөний овог, нэр: ', style: style),
                    pw.Expanded(
                      child: pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Text(
                          _safeStr(patient.fullName),
                          style: style,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
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
                    pw.SizedBox(width: 6),
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
                    pw.SizedBox(width: 6),
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
                pw.SizedBox(height: 4),
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
                pw.SizedBox(height: 6),
                ..._buildDrugSection(presc, style, styleBold),
                pw.SizedBox(height: 6),
                pw.Container(
                  height: 0.5,
                  color: PdfColors.grey800,
                  margin: const pw.EdgeInsets.symmetric(vertical: 1),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Жор бичсэн эмчийн нэр, утас: ${_safeStr(presc.doctorName)} ${_safeStr(presc.doctorPhone)}',
                  style: style,
                ),
                pw.SizedBox(height: 4),
                pw.Text('Тэмдэг: _________________', style: style),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Эмнэлгийн нэр: ${_safeStr(presc.clinicName)}',
                  style: style,
                ),
                pw.SizedBox(height: 4),
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
                pw.SizedBox(height: 4),
              ],
            ),
          ),

          // Table at the very bottom, no extra padding
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  margin: pw.EdgeInsets.zero,
                  padding: pw.EdgeInsets.zero,
                  child: _buildBottomTable(presc, style, styleBold),
                ),
              ),
            ],
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
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Text(
                  'D.t.d. № ${drug.quantity}${drug.treatmentDays != null ? " (${drug.treatmentDays} хоног)" : ""}',
                  style: style,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('S: ', style: styleBold),
              pw.Expanded(
                child: pw.Text(_safeStr(drug.instructions), style: style),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
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
          pw.SizedBox(height: 4),
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
          pw.SizedBox(height: 3),
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
    // Table with full grid (outer border and all cell borders), increased row heights
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
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
            _tableCell('№', styleBold, center: true, minHeight: 14),
            _tableCell(
              'Эмийн нэр, тун, хэмжээ, хэлбэр',
              styleBold,
              center: true,
              minHeight: 14,
            ),
            _tableCell(
              'Хэрэглэх арга, хугацаа',
              styleBold,
              center: true,
              minHeight: 14,
            ),
            _tableCell(
              'Олгосон\n/гарын үсэг/',
              styleBold,
              center: true,
              minHeight: 14,
            ),
          ],
        ),
        // Data rows (always 3, empty if no drug)
        ...List.generate(3, (index) {
          if (index < presc.drugs.length) {
            final d = presc.drugs[index];
            return pw.TableRow(
              children: [
                _tableCell('${index + 1}', style, center: true, minHeight: 22),
                _tableCell(
                  '${_safeStr(d.mongolianName)}\n${_safeStr(d.dose)}, ${_safeStr(d.form)}, ${d.quantity}',
                  style,
                  minHeight: 22,
                ),
                _tableCell(_safeStr(d.instructions), style, minHeight: 22),
                _tableCell('', style, minHeight: 22),
              ],
            );
          } else {
            return pw.TableRow(
              children: [
                _tableCell('${index + 1}', style, center: true, minHeight: 22),
                _tableCell('', style, minHeight: 22),
                _tableCell('', style, minHeight: 22),
                _tableCell('', style, minHeight: 22),
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
