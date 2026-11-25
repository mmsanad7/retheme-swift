# مشاكل معروفة وحلولها

## النص العربي طالع رموز زي `Ù…Ø`
**السبب:** Windows PowerShell 5.1 بيقرا ملف `.ps1` اللي من غير BOM بترميز ANSI.
**الحل:** ما تكتبش عربي في `.ps1`. حط النص في القالب (HTML) أو في `project.json`، والأدوات بتقراهم UTF-8. ولو لازم يبقى فيه عربي في سكريبت، احفظه UTF-8 **with BOM**.

## `Chrome produced no screenshot` أو `ERR_FILE_NOT_FOUND`
- اتأكد إن Chrome أو Edge متسطب، أو حط مساره في `banners.chrome` جوه `project.local.json`.
- ما تمررش رابط `file:///` لـ `Start-Process`. الأداة بتستخدم `& $chrome @args` ومسار الملف العادي.
- لو Chrome مفتوح بنفس الـ profile، الأداة بتستخدم profile منفصل في `.work/banners/chrome-profile`، فده مش هيعمل مشكلة.

## الخط ما ظهرش في البانر (طلع خط افتراضي)
- اتأكد من مسار الخط في `banners.fonts`. المسار بيتحسب من `sourceDir`.
- اسم العائلة في `fonts` لازم يكون نفس الاسم اللي في الـ CSS (`Neo` و`Cairo`).

## `outputDir already exists`
الأداة مش هتمسح ناتج موجود إلا لو طلبت ده صراحة. شغّلها بـ `-Force`.

## `Logo file missing`
`brand/` متجاهل في git، فلازم تحط فيه `logo-color.png` و`logo-white.png` على كل جهاز.

## `No gap found ... for whiteText`
اللوجو مفيهوش فراغ شفاف بين الرمز والكتابة (أو الخلفية مش شفافة). ممكن تحل ده بطريقتين:
- استخدم نسخة بيضا جاهزة من العميل (`"logo": "white"`)، وشيل `whiteText`.
- أو صغّر `textGap` لحد ما يلاقي الفراغ الصح (اتأكد بالمعاينة).

## بقايا لون قديم في رسمة
```powershell
. .\tools\_common.ps1; Import-Recolor
[Recolor]::Hist('<output>\images\x.png', 10)
```
ضيف الدرجات اللي طلعت في `raster.colorMap` بدرجة جديدة مقابلة ليها (أغمق أو أفتح بنفس النسبة).

## الصورة شكلها رمادي في المعاينة
غالبًا فيها مساحات بيضا شبه شفافة في الأصل نفسه، والمعاينة بتعرضها على خلفية تانية. قارن الأصل بالناتج بـ `[Recolor]::Px` قبل ما تعتبرها مشكلة.

## `Set-ExecutionPolicy` / السكريبت ممنوع
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```
