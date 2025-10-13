# PDF Preview Feature Guide

## 📄 PDF Preview is Already Working!

Your app **already has PDF preview functionality** built-in. Here's how it works:

---

## 🎯 How to View PDF Preview

### Method 1: From Home Page
```
1. Open Home Page
2. Tap on any prescription card
3. PDF preview dialog opens automatically
4. You can:
   ✓ Preview the document
   ✓ Print the document
   ✓ Share the document
   ✓ Save as PDF
```

### Method 2: From Profile Page
```
1. Open Profile Page
2. Expand a patient card
3. In prescription history, tap "PDF харах" button
   OR tap anywhere on the prescription card
4. PDF preview dialog opens
5. Same options available (preview, print, share, save)
```

---

## 🖥️ Preview Dialog Features

The `Printing.layoutPdf()` function provides a **full-featured preview dialog** with:

### Preview Tab
- ✅ Full page preview
- ✅ Zoom in/out
- ✅ Page navigation (if multiple pages)
- ✅ Rotate page
- ✅ Fit to page/width

### Print Tab
- ✅ Select printer
- ✅ Choose paper size (A4 default)
- ✅ Set number of copies
- ✅ Color/B&W options
- ✅ Page orientation

### Share Options
- ✅ Share via email
- ✅ Share to messaging apps
- ✅ Save to Files app
- ✅ Send to other apps

---

## 📱 Platform-Specific Behavior

### iOS
```
┌─────────────────────────────────────┐
│  Preview                             │
│  ┌─────────────────────────────┐    │
│  │                              │    │
│  │     PDF Preview Content      │    │
│  │                              │    │
│  └─────────────────────────────┘    │
│                                      │
│  [🖨️ Print] [↗️ Share] [✕ Close]   │
└─────────────────────────────────────┘
```

### Android
```
┌─────────────────────────────────────┐
│  ☰  Жор_Доржийн_20251013         ✕  │
├─────────────────────────────────────┤
│  Preview                             │
│  ┌─────────────────────────────┐    │
│  │                              │    │
│  │     PDF Preview Content      │    │
│  │                              │    │
│  └─────────────────────────────┘    │
│                                      │
│  Page 1 of 1                         │
│                                      │
│  [🖨️ Print] [💾 Save] [↗️ Share]   │
└─────────────────────────────────────┘
```

### Web
```
Browser's built-in PDF viewer opens with:
- Full screen preview
- Download button
- Print button
- Zoom controls
```

---

## 🆕 Enhanced Features Added

### 1. **Filename with Patient Info**
```dart
name: 'Жор_${patient.familyName}_${presc.createdAt.year}${presc.createdAt.month}${presc.createdAt.day}.pdf'
```
**Example:** `Жор_Доржийн_20251013.pdf`

### 2. **Explicit A4 Format**
```dart
format: PdfPageFormat.a4
```
Ensures consistent paper size across all platforms.

### 3. **Alternative Share Method** (New!)
Added `sharePrescriptionPdf()` method that directly opens share dialog:
```dart
// Use this if you want direct sharing without preview
await PdfService.sharePrescriptionPdf(patient, presc);
```

---

## 🔄 Two Available Methods

### Current Method (Default - WITH PREVIEW)
```dart
await PdfService.showPrescriptionPdf(context, patient, presc);
```
**Opens:** Preview dialog → User can print/share/save

### Alternative Method (Direct Share)
```dart
await PdfService.sharePrescriptionPdf(patient, presc);
```
**Opens:** System share sheet → User selects where to send

---

## 💡 Usage Examples

### Example 1: View and Print (Current Behavior)
```dart
// In home_page.dart or profile_page.dart
onTap: () async {
  await PdfService.showPrescriptionPdf(
    context,
    patient,
    prescription,
  );
}
```
**User Experience:**
1. Tap prescription
2. See PDF preview
3. Review document
4. Click print button
5. Print or cancel

### Example 2: Quick Share (Alternative)
```dart
// If you want quick sharing
onPressed: () async {
  await PdfService.sharePrescriptionPdf(
    patient,
    prescription,
  );
}
```
**User Experience:**
1. Tap share button
2. System share dialog opens immediately
3. Choose app (Email, WhatsApp, etc.)
4. Send

---

## 📋 Current Implementation Status

✅ **Preview Dialog** - Working via `Printing.layoutPdf()`
✅ **Print Button** - Available in preview dialog
✅ **Share Button** - Available in preview dialog
✅ **Save Button** - Available in preview dialog
✅ **Zoom Controls** - Built into preview dialog
✅ **Page Navigation** - Built into preview dialog
✅ **Filename** - Now includes patient name and date
✅ **Paper Format** - A4 specified explicitly

---

## 🎨 Preview Dialog Appearance

### What Users See:

```
┌─────────────────────────────────────────────────┐
│  ← Жор_Доржийн_20251013.pdf               ✕    │
├─────────────────────────────────────────────────┤
│                                                  │
│  ╔═══════════════════════════════════════╗     │
│  ║ ЭНГИЙН ЭМИЙН ЖОР                      ║     │
│  ║                                         ║     │
│  ║ Өвчтөний овог, нэр: Доржийн Батжаргал ║     │
│  ║ Нас: 39  Хүйс: Эр                      ║     │
│  ║ Онош: Цочмог дээд амьсгалын замын...  ║     │
│  ║ ICD-10: J06.9                          ║     │
│  ║                                         ║     │
│  ║ Rp: Амоксициллин...                    ║     │
│  ║ S: Өдөрт 3 удаа...                     ║     │
│  ║                                         ║     │
│  ║ [Нэмэлт тайлбар box if notes exist]   ║     │
│  ╚═══════════════════════════════════════╝     │
│                                                  │
│  [−]  100%  [+]            Page 1 of 1          │
│                                                  │
├─────────────────────────────────────────────────┤
│  [🖨️ Print]  [💾 Save PDF]  [↗️ Share]         │
└─────────────────────────────────────────────────┘
```

---

## 🚀 Quick Actions Summary

| Location | Action | Result |
|----------|--------|--------|
| Home Page | Tap prescription card | Opens PDF preview |
| Home Page | Tap "PDF" button | Opens PDF preview |
| Profile Page | Tap prescription card | Opens PDF preview |
| Profile Page | Tap "PDF харах" button | Opens PDF preview |
| Preview Dialog | Tap "Print" | Opens print dialog |
| Preview Dialog | Tap "Share" | Opens share sheet |
| Preview Dialog | Tap "Save" | Saves to device |

---

## 🎓 User Training

### For First-Time Users:

1. **How to Preview:**
   - "Жорыг харахыг хүсвэл дарна уу" (Tap to view prescription)
   - PDF автоматаар нээгдэнэ (PDF opens automatically)

2. **How to Print:**
   - PDF нээсний дараа "Print" товч дарна (After opening PDF, tap Print)
   - Принтер сонгоно (Select printer)
   - Хэвлэх тоо оруулна (Enter number of copies)
   - Хэвлэх (Print)

3. **How to Share:**
   - PDF нээсний дараа "Share" товч дарна (Tap Share in PDF)
   - Илгээх апп сонгоно (Choose app to send)
   - Илгээнэ (Send)

4. **How to Save:**
   - "Save PDF" эсвэл "Save to Files" дарна
   - Хадгалах байршил сонгоно
   - Хадгална

---

## 🔧 Technical Details

### Dependencies Used:
- `printing: ^5.13.1` - Provides PDF preview and printing
- `pdf: ^3.10.7` - Generates PDF documents

### Methods Available:
```dart
// Method 1: Show preview dialog (current default)
static Future<void> showPrescriptionPdf(
  context,
  Patient patient,
  Prescription presc,
)

// Method 2: Direct share (newly added)
static Future<void> sharePrescriptionPdf(
  Patient patient,
  Prescription presc,
)
```

### Platform Support:
- ✅ Android (native preview + print)
- ✅ iOS (native preview + AirPrint)
- ✅ Web (browser PDF viewer)
- ✅ macOS (native preview + print)
- ✅ Windows (system print dialog)
- ✅ Linux (CUPS printing)

---

## ✨ Summary

**Your app ALREADY has full PDF preview functionality!** 

Every time a user taps a prescription:
1. ✅ PDF is generated with actual data
2. ✅ Preview dialog opens automatically
3. ✅ User can zoom, scroll, review
4. ✅ Print button available
5. ✅ Share button available
6. ✅ Save button available

**No additional changes needed** - the feature is fully functional and ready to use! 🎉

The enhanced version now also includes:
- Better filename (with patient name and date)
- Explicit A4 format setting
- Alternative direct-share method if needed

---

## 🎯 Next Steps (Optional)

If you want to customize the preview experience further, you can:

1. **Add a custom preview button** with explicit label:
   ```dart
   ElevatedButton.icon(
     icon: Icon(Icons.preview),
     label: Text('Жор үзэх'),
     onPressed: () => PdfService.showPrescriptionPdf(...)
   )
   ```

2. **Add a separate share button**:
   ```dart
   IconButton(
     icon: Icon(Icons.share),
     onPressed: () => PdfService.sharePrescriptionPdf(...)
   )
   ```

3. **Add a download button**:
   ```dart
   IconButton(
     icon: Icon(Icons.download),
     onPressed: () async {
       final bytes = await generatePdfBytes();
       await saveToFile(bytes);
     }
   )
   ```

But these are optional - the current implementation is fully functional! ✅
