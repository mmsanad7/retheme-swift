# سجل التغييرات

الصيغة مبنية على [Keep a Changelog](https://keepachangelog.com/ar/1.1.0/)، والإصدارات بتتبع [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-11-25

### اتضاف
- `tools/Convert-SvgLogo.ps1`: بيحوّل لوجو SVG لـ PNG شفاف مقصوص بدقة عالية، ونسخة بيضا (PNG وSVG).
- `Recolor.Trim`: قص الصورة على حدود المحتوى.
- نوع لوجو `svg-vector` في `Invoke-Retheme.ps1`، عشان اللوجو يفضل vector ([ADR 0013](docs/decisions/0013-svg-logos-stay-vector.md)).
- `banners.accentColor` و`pillBackground` و`pillText`، وplaceholder `{{ACCENT}}`، للبراندات اللي الثانوي فيها غامق ([ADR 0014](docs/decisions/0014-dark-secondary-banner-accents.md)).
- مشروع `jusur-almawared` (جسور الموارد): 75 ملف اتعدل من 204.

### اتأكدنا
- excp-swift-demo لسه بيطلع نفس الملفات بالـ byte بعد التعديلات (0 فرق).

## [1.0.0] - 2026-11-25

### اتضاف
- `tools/Recolor.cs`: معالجة الصور (مطابقة بتحسب الخلط بالأبيض، hue shift انتقائي، لوجو جوه مساحة، كتابة بيضا، قص لوجو فاتح، أدوات تشخيص).
- `tools/Invoke-Retheme.ps1`: نسخ الملفات، وألوان SVG، والصور، واللوجوهات، وكله من `project.json`.
- `tools/Render-Banners.ps1`: البانرات عن طريق قوالب HTML وChrome headless.
- `tools/Compare-Assets.ps1`: تقرير بالملفات اللي اتغيرت، وبيتأكد إن الأسماء والترتيب زي ما هم.
- `tools/Get-ColorReport.ps1`: تحليل الألوان في بداية أي مشروع.
- `projects/_template/`: قالب لأي مشروع جديد.
- `projects/excp-swift-demo/`: أول مشروع (الحماية المتميزة). 75 ملف اتعدل من 204.
- التوثيق كامل بالعربي، و12 قرار (ADR)، والذاكرة الداخلية (`CLAUDE.md` و`memory/`).
