# شرح `project.json`

كل مشروع جواه `projects/<name>/project.json`، والملف ده بيتعمله commit.
ممكن تعمل كمان `project.local.json` جنبه، وده متجاهل في git: أي خانة فيه بتحل محل نفس الخانة في `project.json` (الخانات اللي على المستوى الأول بس). استخدامه الأساسي إنك تحط فيه المسارات اللي على جهازك.

المسارات النسبية بتتحسب من فولدر المشروع. ممكن تكتب `/` أو `\`.

## المستوى الأول

| الخانة | النوع | الوصف |
|---|---|---|
| `name` | نص | اسم المشروع (نفس اسم الفولدر) |
| `description` | نص | وصف قصير |
| `sourceDir` | مسار | فولدر الـ assets الأصلي. **ما بيتعدلش أبدًا** |
| `outputDir` | مسار | الفولدر اللي هيطلع فيه الناتج. لازم يكون مختلف عن `sourceDir` |

## `brand`

| الخانة | الوصف |
|---|---|
| `nameAr` / `nameEn` | اسم الشركة. بيتحط في القوالب مكان `{{NAME_AR}}` و`{{NAME_EN}}` |
| `primary` / `secondary` | الألوان الجديدة. بتتحط مكان `{{PRIMARY}}` و`{{SECONDARY}}`، والـ class اللي اسمه `.lime` و`.pill` بيستخدموا `secondary` |
| `logoColor` | اللوجو الملون (PNG شفاف) |
| `logoWhite` | اللوجو للخلفيات الغامقة |

## `svg`

| الخانة | الوصف |
|---|---|
| `colorMap` | `{ "#قديم": "#جديد" }`. استبدال hex مباشر في كل ملفات SVG، ومش بيفرق بين الحروف الكبيرة والصغيرة |
| `fileOverrides` | `{ "مسار/ملف.svg": { "#قديم": "#جديد" } }`. ألوان إضافية لملف معين، أو قيم مختلفة عن `colorMap` لملف معين |
| `skip` | ملفات SVG ما يتغيرش لونها، غالبًا عشان هتتبدل بالكامل في `logos` |

- الاستبدال بيتعمل مرة واحدة بس، فمستحيل لون اتغير يتغير تاني.
- الـ regex بيتأكد إن اللون مش جزء من hex أطول (`#224182` مش هيطابق `#2241820`).

## `raster`

| الخانة | الوصف |
|---|---|
| `files` | الرسومات المسطحة اللي هيتغير لونها (**مش** الصور الفوتوغرافية) |
| `colorMap` | `{ "#قديم": "#جديد" }`. ضيف فيها درجات الظل والحواف اللي بتلاقيها بـ `Hist` |
| `tolerance` | أقصى فرق مسموح في أي قناة لونية (الافتراضي 20) |

## `logos[]`

| الخانة | القيم | الوصف |
|---|---|---|
| `file` | مسار | الملف اللي هيتكتب فيه اللوجو |
| `type` | `png-canvas` | PNG شفاف بالمقاس `width`×`height`، واللوجو في النص |
| | `svg-embed` | SVG بنفس الأبعاد، وجواه صورة PNG بدقة `renderScale`× |
| `width`, `height` | رقم | **استخدم نفس مقاس الملف الأصلي**، عشان التطبيق والأنيميشن ما يتأثروش |
| `fill` | 0..1 | نسبة المساحة اللي اللوجو ياخدها من المقاس |
| `logo` | `color` / `white` | أنهي نسخة من اللوجو |
| `whiteText` | true/false | يخلي الكتابة اللي جنب الرمز بيضا ويسيب ألوان الرمز. مفيد للخلفيات الغامقة لو مفيش نسخة بيضا كويسة |
| `textGap` | رقم | أقل عرض (بالبكسل) للفراغ اللي بين الرمز والكتابة. خليه 8 |
| `renderScale` | رقم | للـ `svg-embed` بس (الافتراضي 4) |
| | `svg-vector` | SVG بنفس الأبعاد، وجواه لوجو العميل بصيغة **vector** ([ADR 0013](decisions/0013-svg-logos-stay-vector.md)) |
| `source` | مسار | للـ `svg-vector` بس: ملف SVG اللوجو (زي `brand/logo-white.svg`) |
| `viewBox` | نص | للـ `svg-vector` بس: `"x y w h"`، يعني حدود اللوجو جوه ملف SVG بتاعه. احسبها من الـ content box اللي `Convert-SvgLogo` بيطبعه |

> **لوجو العميل SVG؟** اعمل منه `logo-color.png` و`logo-white.png` و`logo-white.svg` الأول:
> ```powershell
> .\tools\Convert-SvgLogo.ps1 -Svg brand\logo.svg -Out brand\logo-color.png
> .\tools\Convert-SvgLogo.ps1 -Svg brand\logo.svg -Out brand\logo-white.png -White -WhiteSvgOut brand\logo-white.svg
> ```

## `banners`

| الخانة | الوصف |
|---|---|
| `darkColor` | لون غامق من نفس عيلة الأساسي، للخلفيات وكتابة الـ pill. بيتحط مكان `{{DARK}}` |
| `fonts` | `{ "اسم-العائلة": { "file": "مسار جوه sourceDir", "weight": "200 1000" } }`. الخطوط بتتحط جوه الصفحة كـ base64 |
| `chrome` | (اختياري) مسار Chrome أو Edge لو مش في المكان المعتاد |
| `accentColor` | (اختياري) لون الكلام المميز (`.lime` و`{{ACCENT}}`). الافتراضي: `secondary` |
| `pillBackground` / `pillText` | (اختياري) لون الشريط (`.pill`) ولون الكتابة عليه. الافتراضي: `secondary` / `darkColor`. استخدمهم لو الثانوي غامق ([ADR 0014](decisions/0014-dark-secondary-banner-accents.md)) |
| `items[]` | بانر لكل عنصر، والخانات بتاعته في الجدول اللي تحت |

### `banners.items[]`

| الخانة | الوصف |
|---|---|
| `file` | مسار البانر جوه الـ assets، والناتج بيتحفظ بنفس الاسم والصيغة |
| `width`, `height` | نفس مقاس الأصل |
| `template` | قالب HTML (UTF-8) جوه فولدر المشروع |
| `jpegQuality` | للـ jpeg بس (الافتراضي 92) |
| `hueShift[]` | خطوات بتتنفذ ورا بعض على الصورة الأصلية: `{from,to}` نطاق الـ hue بالدرجات، `soft` عرض الحافة المتدرجة، `minSat` أقل تشبّع، `target` الـ hue الجديد، `satMul` مضاعف التشبع |
| `extract[]` | `{name,x,y,w,h,lo,hi}`. بيقص رسمة فاتحة (زي لوجو أبيض) من الصورة الأصلية، ويحوّلها لـ PNG شفاف تقدر تستخدمه في القالب بـ `{{EXTRACT:name}}` |

### placeholders في القالب

| placeholder | القيمة |
|---|---|
| `{{BG}}` | الصورة بعد الـ hue shift |
| `{{SRC}}` | الصورة الأصلية، ومفيدة عشان ترجّع منطقة زي ما كانت |
| `{{LOGO_WHITE}}` / `{{LOGO_COLOR}}` | اللوجوهات |
| `{{EXTRACT:name}}` | القصاصة اللي في `extract` |
| `{{NAME_AR}}` / `{{NAME_EN}}` | اسم الشركة |
| `{{PRIMARY}}` / `{{SECONDARY}}` / `{{DARK}}` / `{{ACCENT}}` | الألوان |

### classes جاهزة في القالب
`.abs` (position absolute)، `.center` (عرض كامل والنص في النص)، `.neo` (خط Neo أبيض)، `.cai` (خط Cairo أبيض)، `.lime` (لون الـ secondary)، `.pill` (شريط بلون الـ secondary والكتابة بالـ `darkColor`).
