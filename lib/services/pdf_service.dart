import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/patient.dart';
import '../models/prescription.dart';

class PdfService {
  static Future<void> showPrescriptionPdf(
    context,
    Patient patient,
    Prescription presc,
  ) async {
    final doc = pw.Document();

    // Load Mongolian-supporting font with safe fallback on mobile
    pw.Font ttf;
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      );
      ttf = pw.Font.ttf(fontData);
    } catch (e) {
      // Fallback to Helvetica if asset isn't available or rootBundle fails
      ttf = pw.Font.helvetica();
    }

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

    String titleByType(PrescriptionType t) {
      switch (t) {
        case PrescriptionType.psychotropic:
          return 'СЭТГЭЦЭД НӨЛӨӨЛӨХ ЭМИЙН ЖОР';
        case PrescriptionType.narcotic:
          return 'МАНСУУРУУЛАХ ЭМИЙН ЖОР';
        case PrescriptionType.regular:
          return 'ЭНГИЙН ЭМИЙН ЖОР';
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Top header text
            pw.Center(
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
                  pw.Text(
                    'Эрүүл мэндийн бүртгэлийн маягт АМ-9А',
                    style: styleHeader,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Main border container
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1.5),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Title
                    pw.Center(
                      child: pw.Text(
                        titleByType(presc.type),
                        style: styleTitle,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Center(
                      child: pw.Text(
                        '${presc.createdAt.year} оны ${presc.createdAt.month} сарын ${presc.createdAt.day}',
                        style: style,
                      ),
                    ),
                    pw.SizedBox(height: 16),

                    // Patient info section - FILLED with actual data
                    pw.Text(
                      'Өвчтөний овог, нэр: ${patient.fullName}',
                      style: style,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Нас: ${patient.age}  Хүйс: ${patient.sex.name == 'male' ? 'Эр' : 'Эм'}  Онош: ${presc.diagnosis}',
                      style: style,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('ICD-10: ${presc.icd}', style: style),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Регистрийн №: ${patient.registrationNumber}',
                      style: style,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Утас: ${patient.phone}  Хаяг: ${patient.address}',
                      style: style,
                    ),
                    pw.SizedBox(height: 12),

                    // Prescription section with drugs
                    ...List.generate(
                      presc.drugs.length > 3 ? 3 : presc.drugs.length,
                      (index) {
                        if (index >= presc.drugs.length) return pw.SizedBox();
                        final drug = presc.drugs[index];
                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Rp:', style: styleBold),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '${drug.mongolianName} (${drug.latinName})',
                              style: style,
                            ),
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
                                pw.Expanded(
                                  child: pw.Text(
                                    drug.instructions,
                                    style: style,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    // Add empty Rp: sections if less than 3 drugs
                    if (presc.drugs.length < 3) ...[
                      for (int i = presc.drugs.length; i < 3; i++) ...[
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
                      ],
                    ],

                    // Notes/Description section
                    if (presc.notes != null && presc.notes!.isNotEmpty) ...[
                      pw.SizedBox(height: 12),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Нэмэлт тайлбар:', style: styleBold),
                            pw.SizedBox(height: 4),
                            pw.Text(presc.notes!, style: style),
                          ],
                        ),
                      ),
                    ],

                    pw.SizedBox(height: 12),
                    // Doctor/clinic and special fields
                    pw.SizedBox(height: 8),
                    if (presc.doctorName != null)
                      pw.Text(
                        'Жор бичсэн эмч: ${presc.doctorName}${presc.doctorPhone != null ? '  Утас: ${presc.doctorPhone}' : ''}',
                        style: style,
                      ),
                    if (presc.clinicName != null)
                      pw.Text(
                        'Эмнэлгийн нэр: ${presc.clinicName}',
                        style: style,
                      ),
                    if (presc.ePrescriptionCode != null)
                      pw.Text(
                        'E-жор код: ${presc.ePrescriptionCode}',
                        style: style,
                      ),
                    if (presc.clinicStamp == true)
                      pw.Text('Байгууллагын тэмдэг: ТИЙМ', style: style),
                    if (presc.generalDoctorSignature == true)
                      pw.Text('Ерөнхий эмчийн гарын үсэг: ТИЙМ', style: style),
                    if (presc.specialIndex != null ||
                        presc.serialNumber != null)
                      pw.Text(
                        'Индекс/Серийн дугаар: ${presc.specialIndex ?? ''} / ${presc.serialNumber ?? ''}',
                        style: style,
                      ),
                    if (presc.receiverName != null)
                      pw.Text(
                        'Хүлээн авагч: ${presc.receiverName}  РД: ${presc.receiverReg ?? ''}  Утас: ${presc.receiverPhone ?? ''}',
                        style: style,
                      ),
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.black),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 8),

            // Bottom table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
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
                // Data rows
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
            ),
          ],
        ),
      ),
    );

    // Show preview dialog with print/share options; fallback to share on failure
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => await doc.save(),
        name:
            'Жор_${patient.familyName}_${presc.createdAt.year}${presc.createdAt.month}${presc.createdAt.day}.pdf',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      // Some Android/iOS environments may not support inline preview (missing activities)
      // Fallback to system share so the user can still export/print the PDF
      try {
        await Printing.sharePdf(
          bytes: await doc.save(),
          filename:
              'Жор_${patient.familyName}_${presc.createdAt.year}${presc.createdAt.month}${presc.createdAt.day}.pdf',
        );
      } catch (_) {
        // Last resort: if context is available, inform the user
        try {
          // ignore: use_build_context_synchronously
          // We keep this best-effort and quiet if context isn't suitable
          // to avoid crashing during background operations
          // ScaffoldMessenger is in material, but we avoid importing here; caller can handle UI errors
        } catch (_) {}
      }
    }
  }

  /// Alternative method to share PDF directly
  static Future<void> sharePrescriptionPdf(
    Patient patient,
    Prescription presc,
  ) async {
    final doc = pw.Document();

    // Load font with safe fallback
    pw.Font ttf;
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      );
      ttf = pw.Font.ttf(fontData);
    } catch (e) {
      ttf = pw.Font.helvetica();
    }

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
            // Top header text
            pw.Center(
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
                  pw.Text(
                    'Эрүүл мэндийн бүртгэлийн маягт АМ-9А',
                    style: styleHeader,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Main border container
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1.5),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Title
                    pw.Center(
                      child: pw.Text('ЭНГИЙН ЭМИЙН ЖОР', style: styleTitle),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Center(
                      child: pw.Text(
                        '${presc.createdAt.year} оны ${presc.createdAt.month} сарын ${presc.createdAt.day}',
                        style: style,
                      ),
                    ),
                    pw.SizedBox(height: 16),

                    // Patient info section - FILLED with actual data
                    pw.Text(
                      'Өвчтөний овог, нэр: ${patient.fullName}',
                      style: style,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Нас: ${patient.age}  Хүйс: ${patient.sex.name == 'male' ? 'Эр' : 'Эм'}  Онош: ${presc.diagnosis}',
                      style: style,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('ICD-10: ${presc.icd}', style: style),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Регистрийн №: ${patient.registrationNumber}',
                      style: style,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Утас: ${patient.phone}  Хаяг: ${patient.address}',
                      style: style,
                    ),
                    pw.SizedBox(height: 12),

                    // Prescription section with drugs
                    ...List.generate(
                      presc.drugs.length > 3 ? 3 : presc.drugs.length,
                      (index) {
                        if (index >= presc.drugs.length) return pw.SizedBox();
                        final drug = presc.drugs[index];
                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Rp:', style: styleBold),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '${drug.mongolianName} (${drug.latinName})',
                              style: style,
                            ),
                            pw.Text(
                              'Тун: ${drug.dose}, Хэлбэр: ${drug.form}, Тоо: ${drug.quantity}',
                              style: style,
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('S:', style: styleBold),
                                pw.SizedBox(width: 8),
                                pw.Expanded(
                                  child: pw.Text(
                                    drug.instructions,
                                    style: style,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    // Add empty Rp: sections if less than 3 drugs
                    if (presc.drugs.length < 3) ...[
                      for (int i = presc.drugs.length; i < 3; i++) ...[
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
                      ],
                    ],

                    // Notes/Description section
                    if (presc.notes != null && presc.notes!.isNotEmpty) ...[
                      pw.SizedBox(height: 12),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Нэмэлт тайлбар:', style: styleBold),
                            pw.SizedBox(height: 4),
                            pw.Text(presc.notes!, style: style),
                          ],
                        ),
                      ),
                    ],

                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Жор бичсэн эмчийн нэр, утас, тэмдэг:',
                      style: style,
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Эмнэлгийн нэр:_____________________________________',
                      style: style,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.black),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 8),

            // Bottom table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
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
                // Data rows
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
                            '${drug.mongolianName}\n${drug.dose}, ${drug.form}, ${drug.quantity}',
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
            ),
          ],
        ),
      ),
    );

    // Share PDF file
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'Жор_${patient.familyName}_${presc.createdAt.year}${presc.createdAt.month}${presc.createdAt.day}.pdf',
    );
  }
}
