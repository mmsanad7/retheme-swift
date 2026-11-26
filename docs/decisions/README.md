# سجل القرارات (ADRs)

كل قرار مهم ليه بدائل بيتكتب هنا في ملف لوحده بالقالب [template.md](template.md).
القرار مش بيتمسح. لو اتغير، بنكتب قرار جديد ونعلّم على القديم إنه `اتلغى بـ ADR-xxxx`.

| # | القرار | الحالة |
|---|---|---|
| [0001](0001-tools-and-docs-only.md) | الريبو public: الأدوات والتوثيق بس، ومن غير ملفات العملاء | مقبول |
| [0002](0002-powershell-csharp-no-python.md) | PowerShell + C# (System.Drawing) من غير Python | مقبول |
| [0003](0003-svg-exact-hex-replacement.md) | ألوان SVG بالاستبدال المباشر للـ hex | مقبول |
| [0004](0004-raster-white-blend-matching.md) | الرسومات المسطحة بمطابقة بتحسب خلط اللون بالأبيض | مقبول |
| [0005](0005-keep-orange-yellow-in-illustrations.md) | البرتقالي والأصفر بيفضلوا زي ما هما في الرسومات | مقبول |
| [0006](0006-banners-via-headless-chrome.md) | البانرات تتعاد بـ hue shift + HTML + Chrome headless | مقبول |
| [0007](0007-third-party-logos-untouched.md) | لوجوهات الجهات التانية ما تتلمسش | مقبول |
| [0008](0008-preserve-names-formats-dimensions.md) | نفس الأسماء والصيغ والمقاسات | مقبول |
| [0009](0009-in-repo-memory.md) | الذاكرة جوه الريبو (CLAUDE.md + memory/) | مقبول |
| [0010](0010-non-brand-colors-unchanged.md) | الألوان اللي مش من اللوجو القديم بتتساب | مقبول |
| [0011](0011-login-logo-white-text.md) | لوجو شاشة الدخول: الكتابة بيضا من نسخة اللوجو الأعلى دقة | مقبول |
| [0012](0012-config-driven-projects.md) | كل مشروع بيتعرّف بـ project.json وقوالب، من غير كود | مقبول |
| [0013](0013-svg-logos-stay-vector.md) | لوجو العميل لو SVG يفضل vector (`Convert-SvgLogo` + `svg-vector`) | مقبول |
| [0014](0014-dark-secondary-banner-accents.md) | لو الثانوي غامق، ألوان التمييز في البانرات بتتحدد في الإعدادات | مقبول |
| [0015](0015-binding-rules-enforced.md) | القواعد والقرارات ملزمة لأي حد على الريبو، وبتتطبق أوتوماتيك (Claude Code + git hooks + CI) | مقبول |
| [0016](0016-brand-fonts-mandatory.md) | خطوط الهوية إلزامية في أي مشروع، والبانرات بتتكتب بيها | مقبول |
| [0017](0017-deliver-brand-fonts-in-assets.md) | خطوط الهوية بتتسلم جوه فولدر الـ assets (`addFiles`)، وده استثناء من 0008 | مقبول، ومستني تأكيد التيم ليد |
