# خطوات مشروع retheme

```
استلام ← تحليل ← قرارات مع العميل ← config ← بناء ← مراجعة ← بانرات ← مراجعة ← تقرير ← تسليم
```

## 0. الاستلام
اجمع من العميل:
- فولدر الـ assets الأصلي.
- اللوجو الجديد **بأعلى دقة متاحة** (SVG أحسن حاجة، وإلا PNG بخلفية شفافة عرضه 1000 بكسل أو أكتر)، ونسخة بيضا للخلفيات الغامقة.
- اللون الأساسي والثانوي (hex).
- **خطوط الهوية** (العربي والإنجليزي) وروابط تنزيلها. لو العميل عنده موقع، دوّر على `@font-face` في الـ CSS بتاعه. سجّلهم في `brand.fonts` وفي `handoff.md`.
- اسم الشركة بالعربي والإنجليزي **مكتوب بالظبط زي ما هيظهر**.

اعمل المشروع:
```powershell
Copy-Item projects\_template projects\<name> -Recurse
```

لو اللوجو SVG، اعمل منه ملفات PNG ونسخة بيضا ([ADR 0013](decisions/0013-svg-logos-stay-vector.md)):
```powershell
.\tools\Convert-SvgLogo.ps1 -Svg projects\<name>\brand\logo.svg -Out projects\<name>\brand\logo-color.png
.\tools\Convert-SvgLogo.ps1 -Svg projects\<name>\brand\logo.svg -Out projects\<name>\brand\logo-white.png -White -WhiteSvgOut projects\<name>\brand\logo-white.svg
```

**لو الثانوي الجديد غامق:** حدد `accentColor` و`pillBackground` و`pillText` في `banners`، وخلي بالك إن الخلفيات الفاتحة في الرسومات هتبقى رمادي ([ADR 0014](decisions/0014-dark-secondary-banner-accents.md)).
**لو اللوجو طولي (مربع تقريبًا):** كبّر ارتفاع `<img>` في القوالب (في جسور الموارد: 92 لحد 136 بكسل بدل 40).

## 1. التحليل
```powershell
.\tools\Get-ColorReport.ps1 -Project <name> -OldBrand <ألوان اللوجو القديم> -OutFile projects\<name>\.work\colors.md
```
- **ألوان اللوجو القديم**: افتح اللوجو القديم (غالبًا `logo.png`) واعرف ألوانه، وبعدين دوّر عليها في جدول ألوان الـ SVG.
- **الدرجات القريبة** (ظل أغمق، خلفية أفتح) من نفس اللون محسوبة من ألوان البراند القديم.
- **الصور:** لو رسمة مسطحة فيها عدد كبير من بكسلات البراند القديم، تتعدل ألوانها. لو صورة فوتوغرافية أو بانر، تروح لخطوة البانرات. ولو صورة عادية، تتساب.
- **بص بعينك** على كل صورة فيها عدد بكسلات كبير قبل ما تقرر.

## 2. قرارات مع العميل (قبل أي تنفيذ)
اعرض عليه، والأحسن في رسالة واحدة:
1. توزيع الألوان: القديم الغامق يبقى الأساسي الجديد، والقديم الفاتح يبقى الثانوي الجديد.
2. أي لون مستخدم كتير بس مش من اللوجو القديم (زي الأحمر): القاعدة إنه يتساب.
3. الصور: إيه اللي هيتعدل لونه وإيه اللي هيتساب.
4. البانرات اللي فيها اسم أو لوجو قديم: هتتعاد تصميمها.
5. لو اللوجو اللي مبعوت دقته ضعيفة، اطلب نسخة أحسن.

سجّل الإجابات في `docs/projects/<name>/README.md`.

## 3. الـ config
املأ `projects/<name>/project.json`، والشرح الكامل في [configuration.md](configuration.md).

## 4. البناء
```powershell
.\tools\Invoke-Retheme.ps1 -Project <name> -Force
```

## 5. المراجعة الأولى
- افتح **كل** صورة PNG اتعدلت وبصلها.
- دوّر على بقايا ألوان قديمة: `[Recolor]::Hist(path, 10)` بيطلّع درجات الأزرق اللي فاضلة. ضيفها في `raster.colorMap` وأعد البناء.
- اتأكد إن مفيش لون قديم فاضل في أي SVG:
  ```powershell
  Select-String -Path <output>\**\*.svg -Pattern '#(224182|1BAAE2)' -List
  ```

## 6. البانرات
- لكل بانر: حدد أماكن النص القديم واللوجو القديم بالبكسل (`[Recolor]::Crop` بيساعدك تبص على أجزاء بالحجم الحقيقي).
- اكتب قالب HTML في `projects/<name>/banners/` (ابدأ من `_template/banners/example.html`).
- حدد `hueShift` اللي هيحوّل ألوان الخلفية القديمة للألوان الجديدة.
- **أي لوجو لجهة تانية** (حكومي، سوشيال...) لازم يفضل زي ما هو: اقصّه بـ `extract` أو رجّعه من `{{SRC}}`.
```powershell
.\tools\Render-Banners.ps1 -Project <name>            # كلها
.\tools\Render-Banners.ps1 -Project <name> -Only slider1.png
```

## 7. المراجعة النهائية
امشي على [qa-checklist.md](qa-checklist.md) كلها.

## 8. التقرير والتسليم
```powershell
.\tools\Compare-Assets.ps1 -Project <name> -OutFile docs\projects\<name>\changed-files.md
```
- كمّل `docs/projects/<name>/README.md`: الأرقام، القرارات، الحاجات المفتوحة.
- اكتب `docs/projects/<name>/handoff.md` لفريق التطوير: الهوية (الاسم والألوان **والخطوط** واللوجو)، واستلموا إيه، والمطلوب منهم في الكود، والحاجات المتسابة عن قصد. مثال: [jusur-almawared/handoff.md](projects/jusur-almawared/handoff.md).
- ضيف سطر في `memory/project-log.md` وفي جدول المشاريع في `README.md`.
- لو خدت قرار جديد مهم، اكتب له ADR.
- اعمل commit للـ config والقوالب والتوثيق (**من غير** ملفات العميل).
