# سجل التغييرات

الصيغة مبنية على [Keep a Changelog](https://keepachangelog.com/ar/1.1.0/)، والإصدارات بتتبع [Semantic Versioning](https://semver.org/).

## [Unreleased]

### اتضاف ([ADR 0019](docs/decisions/0019-cumulative-client-intake.md))
- [`docs/client-intake.md`](docs/client-intake.md): أسئلة استلام أي عميل جديد في 10 أقسام (الأساسيات، المجال، الألوان، اللوجو، الخطوط، الصور، البانرات، الدارك مود، حاجات بره الـ assets، التسليم)، وكل سؤال جنبه الإجابة الافتراضية ومصدرها. Claude بيسألها أول ما ييجي عميل (قاعدة 13 في `CLAUDE.md`)، وأي قرار جديد بيتضاف كسؤال.

### اتضاف ([ADR 0018](docs/decisions/0018-workspace-layout-and-project-scaffold.md))
- **ترتيب فولدرات ثابت:** `workspace.local.json` في جذر الريبو (متجاهل في git) بيحدد الفولدر الرئيسي، و`{root}/...` في `sourceDir` و`outputDir`. الأصل في `base-assets\<baseApp>` والناتج في `clients\<name>`. خانة جديدة `baseApp`.
- [`tools/New-Project.ps1`](tools/New-Project.ps1): بيعمل أي عميل جديد بأمر واحد (الإعدادات بالهوية والخطوط، و`brand\`، وفولدر العميل، والتقرير و`handoff.md` من [القوالب](docs/projects/_template/)، وسطر في السجل وفي جدول المشاريع).
- `Test-RepoRules.ps1` بيرفض أي مشروع ناقصه `README.md` أو `handoff.md` أو سطر في السجل، وبيرفض رفع `workspace.local.json`.
- [`docs/projects/excp-swift-demo/handoff.md`](docs/projects/excp-swift-demo/handoff.md).

### اتغير
- المشروعين القدام اتنقلوا لمسارات `{root}`. أي جهاز شغال بـ `project.local.json` هيفضل شغال لحد ما ينقل ملفاته ([getting-started.md](docs/getting-started.md)).

### اتغير (ممكن يكسر مشاريع قديمة)
- **خطوط الهوية إلزامية** ([ADR 0016](docs/decisions/0016-brand-fonts-mandatory.md)): `Invoke-Retheme` بيرفض أي مشروع من غير `brand.fonts`، و`Render-Banners` بيرفض أي خط بانر مش `brandFile`، والـ pre-commit وCI بيفحصوا `brand.fonts`. خانة `brandFile` جديدة في `banners.fonts`. `excp-swift-demo` معاه استثناء (`legacyNoBrandFonts`).
- **jusur-almawared:** البانرات الخمسة اتعادت بخط Kufam (`brandFile`)، و"100%" بخط Montserrat (عيلة `En`). العناوين بوزن 800، والمسافة بين الكلمات `.14em` لأن Kufam ضيق.

### اتغير
- **المشروعين:** `icon/edit_icon.svg` و`icon/location_icon.svg` (`#1B61A0`) اتغيروا للون الأساسي عن طريق `svg.fileOverrides` ([ADR 0010](docs/decisions/0010-non-brand-colors-unchanged.md))، فبقوا 77 ملف متعدل. وكل الحاجات المفتوحة اتقفلت.

### اتضاف
- خانة `addFiles` في `project.json`: بتضيف ملفات (زي خطوط الهوية) للناتج، ومش بتكتب فوق ملف موجود. `Compare-Assets` بيعدّها تحت بند "added on purpose" ([ADR 0017](docs/decisions/0017-deliver-brand-fonts-in-assets.md)). **jusur-almawared:** Kufam وMontserrat اتضافوا في `fonts/`.
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
