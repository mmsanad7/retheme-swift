# سجل التغييرات

الصيغة مبنية على [Keep a Changelog](https://keepachangelog.com/ar/1.1.0/)، والإصدارات بتتبع [Semantic Versioning](https://semver.org/).

## [Unreleased]

### اتغير (ممكن يكسر مشاريع قديمة)
- **خطوط الهوية إلزامية** ([ADR 0016](docs/decisions/0016-brand-fonts-mandatory.md)): `Invoke-Retheme` بيرفض أي مشروع من غير `brand.fonts`، و`Render-Banners` بيرفض أي خط بانر مش `brandFile`، والـ pre-commit وCI بيفحصوا `brand.fonts`. خانة `brandFile` جديدة في `banners.fonts`. `excp-swift-demo` معاه استثناء (`legacyNoBrandFonts`).

### اتضاف
- خطوط هوية جسور الموارد (Kufam عربي وMontserrat إنجليزي) في [handoff.md](docs/projects/jusur-almawared/handoff.md) و[تقرير المشروع](docs/projects/jusur-almawared/README.md) و`project.json`، وخانة `brand.fonts` في [configuration.md](docs/configuration.md)، وخطوة الخطوط في [workflow.md](docs/workflow.md).
- [`docs/projects/jusur-almawared/handoff.md`](docs/projects/jusur-almawared/handoff.md): ملف تسليم لفريق التطوير، وخطوة الـ handoff اتضافت في [workflow.md](docs/workflow.md).
- قواعد الفريق في [memory/user-preferences.md](memory/user-preferences.md): pull قبل أي تعديل وpush بعده، والروابط في الردود.
- فرض القواعد أوتوماتيك ([ADR 0015](docs/decisions/0015-binding-rules-enforced.md)): [tools/Test-RepoRules.ps1](tools/Test-RepoRules.ps1)، و[.githooks/pre-commit](.githooks/pre-commit)، وhooks لـ Claude Code في [.claude/settings.json](.claude/settings.json)، و[GitHub Actions](.github/workflows/repo-rules.yml). `_common.ps1` بيفعّل الـ git hooks أول ما أي أداة تشتغل.

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
