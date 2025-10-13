# Quick Start Guide: New Patient Registration Flow

## Overview
Patients can now be registered with just 4 basic fields. Complete information is collected when creating their first prescription.

---

## Step 1: Register New Patient (Quick & Simple)

**Location**: Profile Page → "Шинэ өвчтөн" button

**Required Fields (4 only)**:
```
✓ Овог (Family Name)          Example: "Доржийн"
✓ Нэр (Given Name)             Example: "Батжаргал"
✓ Төрсөн огноо (Birth Date)    Example: "1985-03-15"
✓ Хүйс (Sex)                   Example: "Эр" or "Эм"
```

**Info Message**:
> "Бусад мэдээлэл (РД, утас, хаяг, онош) жор бичихэд асуугдана"
> (Other info will be collected when creating prescription)

**Result**: Patient saved with basic information only

---

## Step 2: Create First Prescription (Complete Information)

**Location**: Profile Page → Expand Patient → "Шинэ жор бичих" button

**Patient Info Card Shows**:
```
Доржийн Батжаргал • 39 настай • male
РД: —
Утас: —
Хаяг: —
```

**⚠️ Warning Box Appears** (Orange):
```
"Өвчтний бүрэн мэдээллийг оруулна уу"

Required Fields:
✓ Регистрийн дугаар (РД)       Example: "УБ12345678"
✓ Утасны дугаар                Example: "99112233"
✓ Хаяг                         Example: "СБД, 3-р хороо"
```

**Prescription Fields**:
```
✓ Онош (Diagnosis)             Example: "Цочмог дээд амьсгалын замын халдвар"
✓ ICD-10 код                   Example: "J06.9"
✓ Жорын төрөл                  Choice: Энгийн/Сэтгэц/Мансуурах
✓ Эмийн жагсаалт               Add drugs with + button
```

**Save Result**:
- ✅ Patient record updated with complete information
- ✅ Prescription created and saved
- ✅ PDF generated and displayed

---

## Step 3: Subsequent Prescriptions (Fast)

**Location**: Same as Step 2

**Patient Info Card Now Shows**:
```
Доржийн Батжаргал • 39 настай • male
РД: УБ12345678 • Утас: 99112233
Хаяг: СБД, 3-р хороо
```

**⚠️ Warning Box**: Does NOT appear (info already complete)

**Only Need**:
```
✓ Онош (for this prescription)
✓ ICD-10 код
✓ Жорын төрөл
✓ Эмийн жагсаалт
```

**Save Result**:
- ✅ Prescription created instantly
- ✅ PDF generated
- ⏩ Much faster workflow

---

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  PROFILE PAGE: Шинэ өвчтөн                                  │
│  ────────────────────────────────────────────────────────   │
│  Quick Form (4 fields):                                      │
│  • Овог         • Нэр                                        │
│  • Төрсөн огноо • Хүйс                                       │
│                                                               │
│  [Хадгалах] ──────────────────────────┐                      │
└───────────────────────────────────────┼──────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Patient Saved ✓                                             │
│  Basic info only: Доржийн Батжаргал, 39 нас, male           │
└─────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────┐
│  PROFILE PAGE: Expand Patient → Шинэ жор бичих              │
│  ────────────────────────────────────────────────────────   │
│  ⚠️ WARNING: Complete patient info required                 │
│                                                               │
│  Patient Details:                                            │
│  • РД        • Утас       • Хаяг                            │
│                                                               │
│  Prescription Details:                                       │
│  • Онош      • ICD        • Төрөл      • Эмүүд              │
│                                                               │
│  [Хадгалах] ──────────────────────────┐                      │
└───────────────────────────────────────┼──────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────┐
│  ✓ Patient Updated (complete info)                           │
│  ✓ Prescription Created                                      │
│  ✓ PDF Generated                                             │
└─────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────┐
│  SUBSEQUENT PRESCRIPTIONS                                    │
│  ────────────────────────────────────────────────────────   │
│  ✓ Patient info already complete (no warning)                │
│  ✓ Only prescription fields needed                           │
│  ✓ Faster workflow                                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Features

### 1. **Progressive Information Collection**
- Start with minimal data
- Complete details when needed
- Natural workflow for doctors

### 2. **Visual Indicators**
- Orange warning box when patient info incomplete
- Gray "—" symbol for empty fields in profile
- Clear messaging about what's needed

### 3. **Automatic Updates**
- Patient record updated when saving first prescription
- No separate "edit patient" step needed
- Information flows naturally

### 4. **Data Validation**
- Required fields enforced at prescription stage
- Phone number format validation
- ICD-10 code format validation
- Registration number required

### 5. **Flexible Search**
- Can search patients even with partial information
- Search by name always works
- РД and phone search work once filled

---

## Common Scenarios

### Scenario A: Emergency Patient
```
1. Quick register: Name + Age + Sex (30 seconds)
2. Create prescription: Complete info + Rx (2 minutes)
Total: ~2.5 minutes
```

### Scenario B: Known Patient Return Visit
```
1. Find patient in profile (10 seconds)
2. Create new prescription (1 minute)
Total: ~1 minute
```

### Scenario C: Batch Registration
```
1. Register 10 patients quickly (5 minutes)
2. Create prescriptions as they're seen (per visit)
Total: Flexible, supports any workflow
```

---

## Tips for Best Practice

1. **Register patients immediately** when they arrive
2. **Complete full details** during consultation
3. **Review patient card** before creating prescription
4. **Update address/phone** if patient mentions changes (via copyWith)

---

## Technical Notes

- Empty strings used as defaults for optional fields
- Patient copyWith() properly updates partial information
- Validation occurs at prescription creation time
- Both patient and prescription saved atomically
