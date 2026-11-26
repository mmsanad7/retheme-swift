# retheme-swift

أدوات وتوثيق لتغيير هوية (Retheme / Rebrand) ملفات الـ assets في تطبيقات الموبايل بسرعة وبشكل يتكرر بنفس الجودة:
تغيير ألوان الأيقونات والرسومات، استبدال اللوجو، وإعادة تصميم البانرات، **من غير ما يتغير اسم أي ملف أو مكانه** — فالتطبيق يشتغل بالهوية الجديدة من غير أي تعديل في الكود.

> الريبو ده عام (public)، وفيه **الأدوات والتوثيق بس**. ملفات العملاء (الصور، الخطوط، اللوجوهات) ما بتترفعش أبدًا — شوف [القرار 0001](docs/decisions/0001-tools-and-docs-only.md).

> ⚖️ **كل القواعد والقرارات ملزمة لأي حد بيشتغل على الريبو، وبتتطبق أوتوماتيك من أول سحب.** اقرا [CONTRIBUTING.md](CONTRIBUTING.md) و[ADR 0015](docs/decisions/0015-binding-rules-enforced.md) قبل أي تعديل.

---

## البداية السريعة

```powershell
# 0) مرة واحدة على كل جهاز: workspace.local.json فيه { "root": "D:/retheme-swift-project" }
#    والـ assets الأصلية في D:\retheme-swift-project\base-assets\aber-alqarat\  (ADR 0018)
# 1) اعمل العميل وتوثيقه بأمر واحد
.\tools\New-Project.ps1 -Name my-client -NameAr "..." -NameEn "My Client" -Primary "#123456" -Secondary "#ABCDEF" `
    -FontAr Kufam -FontArSource https://... -FontEn Montserrat -FontEnSource https://...

# 2) حط اللوجوهات وملفات الخطوط في projects\my-client\brand\
# 3) حلّل الألوان
.\tools\Get-ColorReport.ps1 -Project my-client -OldBrand 224182,1BAAE2

# 4) املأ project.json، وبعدين شغّل
.\tools\Invoke-Retheme.ps1  -Project my-client -Force
.\tools\Render-Banners.ps1  -Project my-client
.\tools\Compare-Assets.ps1  -Project my-client -OutFile docs\projects\my-client\changed-files.md
```

التفاصيل الكاملة في [دليل البداية](docs/getting-started.md) و[خطوات العمل](docs/workflow.md).

## المتطلبات

| المتطلب | ليه |
|---|---|
| Windows 10/11 + Windows PowerShell 5.1 | تشغيل السكريبتات |
| .NET Framework (موجود مع Windows) | مكتبة `System.Drawing` لمعالجة الصور |
| Google Chrome أو Microsoft Edge | رسم البانرات بخط عربي صحيح (headless) |

**مش محتاج** Python ولا Node ولا ImageMagick — شوف [القرار 0002](docs/decisions/0002-powershell-csharp-no-python.md).

## محتويات الريبو

```
retheme-swift/
├── README.md                 ← انت هنا
├── CLAUDE.md                 ← تعليمات وذاكرة لـ Claude Code (بتتحمل تلقائي)
├── CHANGELOG.md              ← سجل التغييرات
├── CONTRIBUTING.md           ← إزاي تساهم / تضيف مشروع
├── memory/                   ← ذاكرة المشروع اللي بتتنقل مع الريبو بين الأجهزة
├── tools/                    ← الأدوات (PowerShell + C#)
│   ├── Recolor.cs            ← معالجة الصور (بيتعمله compile وقت التشغيل)
│   ├── _common.ps1           ← دوال مشتركة
│   ├── New-Project.ps1       ← البداية: عميل جديد (الإعدادات + الفولدرات + التوثيق)
│   ├── Convert-SvgLogo.ps1   ← الخطوة 0: لوجو SVG ← PNG شفاف ونسخة بيضا
│   ├── Get-ColorReport.ps1   ← الخطوة 1: تحليل الألوان
│   ├── Invoke-Retheme.ps1    ← الخطوة 2: نسخ + ألوان SVG + صور + لوجوهات
│   ├── Render-Banners.ps1    ← الخطوة 3: إعادة تصميم البانرات
│   └── Compare-Assets.ps1    ← الخطوة 4: تقرير الملفات المتغيرة
├── projects/
│   ├── _template/            ← قالب لأي مشروع جديد
│   ├── excp-swift-demo/      ← الحماية المتميزة
│   └── jusur-almawared/      ← جسور الموارد
├── docs/                     ← التوثيق الكامل
│   ├── decisions/            ← سجل القرارات (ADRs)
│   └── projects/             ← تقرير لكل مشروع اتعمل
└── .github/                  ← قوالب الـ Issues والـ Pull Requests
```

## التوثيق

| الملف | المحتوى |
|---|---|
| [docs/getting-started.md](docs/getting-started.md) | التجهيز على جهاز جديد |
| [docs/client-intake.md](docs/client-intake.md) | أسئلة استلام أي عميل جديد (تراكمية، بتكبر مع كل مشروع) |
| [docs/workflow.md](docs/workflow.md) | خطوات أي مشروع retheme من الأول للآخر |
| [docs/configuration.md](docs/configuration.md) | شرح كل خانة في `project.json` |
| [docs/how-it-works.md](docs/how-it-works.md) | الخوارزميات من جوه |
| [docs/principles.md](docs/principles.md) | المبادئ والقواعد الثابتة |
| [docs/qa-checklist.md](docs/qa-checklist.md) | قائمة المراجعة قبل التسليم |
| [docs/troubleshooting.md](docs/troubleshooting.md) | مشاكل حصلت وحلها |
| [docs/decisions/](docs/decisions/) | كل قرار اتاخد وليه |
| [docs/projects/](docs/projects/) | تقارير المشاريع |

## المشاريع اللي اتعملت

| المشروع | العميل / الهوية | التاريخ | التقرير |
|---|---|---|---|
| `excp-swift-demo` | الحماية المتميزة (Excellent Protection) | 2026-11-25 | [التقرير](docs/projects/excp-swift-demo/README.md) |
| `jusur-almawared` | جسور الموارد (Jusur) | 2026-11-25 | [التقرير](docs/projects/jusur-almawared/README.md) |

## الترخيص

مفيش ترخيص مفتوح حاليًا: الكود ملك أصحابه وكل الحقوق محفوظة. لو عايزين تسمحوا لحد يستخدمه أضيفوا ملف `LICENSE`.
