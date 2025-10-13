# Quick Reference: Delete, Update & PDF Features

## 🎯 New Features at a Glance

### 1. Patient Management (Profile Page)

```
┌─────────────────────────────────────────────────────┐
│  👤 Доржийн Батжаргал                                │
│  39 нас • male • 5 жор                   [▼]        │
├─────────────────────────────────────────────────────┤
│  Өвчтний мэдээлэл:                                   │
│  РД: УБ12345678                                      │
│  Утас: 99112233                                      │
│  Хаяг: СБД, 3-р хороо                                │
│                                                      │
│  Жорын түүх (5):                                     │
│  [Prescription cards with PDF + Delete buttons]     │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │       Шинэ жор бичих [+]                     │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  ┌───────────────────┐ ┌────────────────────────┐   │
│  │  Засах [✏]       │ │  Устгах [🗑] (red)     │   │
│  └───────────────────┘ └────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### 2. Prescription Card Actions

#### In Profile Page (Prescription History):
```
┌─────────────────────────────────────────────────────┐
│  [Энгийн]                          2025.10.13       │
│  Цочмог дээд амьсгалын замын халдвар                 │
│  Амоксициллин, Парацетамол                          │
│  ├───────────────────────────────────────────────┤  │
│  │ 📄 PDF харах          🗑 Устгах (red)         │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

#### In Home Page:
```
┌─────────────────────────────────────────────────────┐
│  👤 Доржийн Батжаргал        [Энгийн]  2025.10.13  │
│  39 нас • male                                      │
│                                                      │
│  Онош: Цочмог дээд амьсгалын замын халдвар          │
│  ICD: J06.9                                         │
│                                                      │
│  💊 Амоксициллин  💊 Парацетамол                    │
│  ────────────────────────────────────────────────   │
│                          📄 PDF    🗑 Устгах (red)  │
└─────────────────────────────────────────────────────┘
```

### 3. Enhanced PDF Output

```
╔═════════════════════════════════════════════════════╗
║  ЭНГИЙН ЭМИЙН ЖОР                                   ║
╠═════════════════════════════════════════════════════╣
║                                                      ║
║  Өвчтөний овог, нэр: Доржийн Батжаргал ✓            ║
║  Нас: 39  Хүйс: Эр  Онош: Цочмог дээд амьсгалын... ✓║
║  ICD-10: J06.9 ✓                                     ║
║  Регистрийн №: УБ12345678 ✓                          ║
║  Утас: 99112233  Хаяг: СБД, 3-р хороо ✓             ║
║                                                      ║
║  Rp:                                                 ║
║  Амоксициллин (Amoxicillin)                         ║
║  Тун: 500mg, Хэлбэр: Капсул, Тоо: 21                ║
║  S: Өдөрт 3 удаа 1 капсул, 7 хоног                  ║
║                                                      ║
║  ┌─────────────────────────────────────────┐        ║
║  │ Нэмэлт тайлбар: ✓                       │        ║
║  │ Хоолны дараа ууна уу. Согтууруулах      │        ║
║  │ ундаатай хэрэглэхгүй байх.              │        ║
║  └─────────────────────────────────────────┘        ║
║                                                      ║
║  Жор бичсэн эмчийн нэр, утас, тэмдэг:               ║
║  _______________________________________________     ║
║                                                      ║
╚═════════════════════════════════════════════════════╝
```

✓ = Pre-filled with actual data (NEW!)

---

## 📋 Operation Examples

### Delete Patient
```
1. Tap patient name → Expand
2. Scroll to bottom
3. Tap "Устгах" (red button)

   ┌──────────────────────────────────┐
   │  Устгах уу?                      │
   │                                   │
   │  Өвчтөн "Доржийн Батжаргал"-г    │
   │  устгах уу?                       │
   │                                   │
   │  5 жор мөн устах болно.           │
   │                                   │
   │  [Үгүй]          [Устгах] (red)  │
   └──────────────────────────────────┘

4. Confirm → Patient + All prescriptions deleted
5. Toast: "Өвчтөн устгагдлаа"
```

### Edit Patient
```
1. Tap patient name → Expand
2. Tap "Засах" button
3. Form opens with current data
4. Modify fields (name, DOB, sex)
5. Tap "Хадгалах"
6. Toast: "Өвчтөн шинэчлэгдлээ"
7. Updated info displays immediately
```

### Delete Prescription
```
From Profile Page:
1. Expand patient
2. Find prescription in history
3. Tap "Устгах" button
4. Confirm in dialog
5. Toast: "Жор устгагдлаа"

From Home Page:
1. Find prescription card
2. Tap "Устгах" at bottom
3. Confirm in dialog
4. Toast: "Жор устгагдлаа"
```

### View Enhanced PDF
```
Any prescription tap → PDF opens with:
- ✅ Patient info filled
- ✅ Diagnosis filled
- ✅ All drug details
- ✅ Notes box (if notes exist)
- Can print/share immediately
```

---

## 🎨 Color Coding

```
Primary Actions:
- Create/Add:    Blue elevated button
- Edit:          Blue outlined button

Destructive Actions:
- Delete:        Red text + red icon
                 Red outlined button
                 Red confirm button

Prescription Types:
- Энгийн:        Blue badge
- Сэтгэц:        Orange badge
- Мансуурах:     Red badge
```

---

## ⚡ Keyboard Shortcuts & Quick Actions

### Profile Page
- Tap patient → Expand/Collapse
- Tap prescription → View PDF
- Swipe? No (use buttons for clarity)

### Home Page
- Tap card → View PDF
- Search: Type in search bar
- Filter: Tap filter chips

---

## 🔒 Safety Features

### Confirmation Required For:
✓ Delete patient
✓ Delete prescription

### Automatic Actions:
✓ Delete patient → Auto-delete all prescriptions
✓ Edit patient → Auto-save
✓ PDF generation → Auto-fill data

### No Confirmation For:
✓ View PDF
✓ Edit patient (can cancel)
✓ Create prescription (can cancel)

---

## 📊 Data Flow

```
Delete Patient Flow:
┌─────────────┐
│ User clicks │
│  "Устгах"   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Confirm Dialog  │
└──────┬──────────┘
       │ Yes
       ▼
┌───────────────────────────┐
│ Delete prescriptions by   │
│ patientId                 │
└──────┬────────────────────┘
       │
       ▼
┌───────────────────────────┐
│ Delete patient            │
└──────┬────────────────────┘
       │
       ▼
┌───────────────────────────┐
│ Save to SharedPreferences │
└──────┬────────────────────┘
       │
       ▼
┌───────────────────────────┐
│ notifyListeners()         │
└──────┬────────────────────┘
       │
       ▼
┌───────────────────────────┐
│ UI updates automatically  │
└───────────────────────────┘


Edit Patient Flow:
┌─────────────┐
│ User clicks │
│   "Засах"   │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ Form opens with     │
│ existing data       │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ User modifies       │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Saves (copyWith)    │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ PatientService      │
│ .savePatient()      │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ UI updates          │
└─────────────────────┘


PDF Generation Flow:
┌─────────────────────┐
│ User taps           │
│ prescription        │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Get patient &       │
│ prescription data   │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Generate PDF with   │
│ - Patient info ✓    │
│ - Diagnosis ✓       │
│ - Drugs ✓           │
│ - Notes ✓ (if any)  │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Display PDF viewer  │
│ (can print/share)   │
└─────────────────────┘
```

---

## 💡 Pro Tips

1. **Batch Operations**: Delete patient removes all prescriptions automatically
2. **Quick PDF**: Tap anywhere on prescription card to view PDF
3. **Edit Anytime**: Can edit patient info even after prescriptions created
4. **Notes in PDF**: Add notes in prescription form → Shows in PDF
5. **Search Power**: Search patients by name, РД, or phone
6. **Filter Fast**: Use chips on home page to filter by prescription type

---

## 🚨 Important Notes

- **Delete is permanent** - No undo functionality
- **Always confirm** - Red buttons show confirmation dialogs
- **Auto-save** - All changes persist immediately
- **PDF fills automatically** - No manual data entry needed
- **Cascade delete** - Patient deletion removes all related prescriptions
- **State management** - UI updates automatically via Provider

---

## 📱 Screen-by-Screen Guide

### Home Page Actions:
- ✅ View prescription (tap card)
- ✅ Delete prescription (button)
- ✅ Search prescriptions
- ✅ Filter by type
- ✅ Create new prescription (FAB)

### Profile Page Actions:
- ✅ View patient list
- ✅ Search patients
- ✅ Create new patient (FAB)
- ✅ Edit patient (button)
- ✅ Delete patient (button)
- ✅ View prescription history
- ✅ Delete individual prescriptions
- ✅ Create prescription for patient

### Patient Form Actions:
- ✅ Create new patient
- ✅ Edit existing patient
- ✅ Cancel (back button)

### Prescription Form Actions:
- ✅ Create prescription
- ✅ Auto-update patient info
- ✅ Add notes
- ✅ Cancel (back button)

---

## 🎓 Training Checklist

For new users, practice these operations:

- [ ] Create a test patient
- [ ] Create a prescription for that patient
- [ ] View the PDF (check filled data)
- [ ] Add notes to a prescription
- [ ] View PDF with notes
- [ ] Edit patient information
- [ ] Delete a single prescription
- [ ] Delete a patient (with prescriptions)
- [ ] Search for patients
- [ ] Filter prescriptions by type
- [ ] Create all three prescription types
