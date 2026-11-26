# البداية: تجهيز جهاز جديد

## 1. المتطلبات

- Windows 10 أو 11، وعليه **Windows PowerShell 5.1** (موجود مع الويندوز).
- **Google Chrome** أو **Microsoft Edge**، عشان البانرات بس.
- **Git**.

مش محتاج تسطب Python ولا Node ولا ImageMagick. الكود اللي بيعالج الصور (`tools/Recolor.cs`) PowerShell بيعمله compile لوحده وقت التشغيل.

## 2. هات الريبو

```powershell
git clone https://github.com/mmsanad7/retheme-swift.git
cd retheme-swift
```

لو PowerShell منع تشغيل السكريبتات:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## 3. رتّب فولدرات الشغل ([ADR 0018](decisions/0018-workspace-layout-and-project-scaffold.md))

كل الشغل في فولدر واحد، والريبو جواه. الـ assets والناتج **جنب** الريبو مش جواه، فـ git مش بيشوفهم:

```
D:\retheme-swift-project\
├── retheme-swift\                 ← الريبو
├── base-assets\aber-alqarat\      ← الـ assets الأصلية (مش بتتعدل)
└── clients\<name>\                ← ناتج كل عميل (الـ assets نفسها). متحطش فيه حاجة تانية، لأن البناء بـ -Force بيمسحه
```

1. اعمل ملف **`workspace.local.json`** في جذر الريبو (متجاهل في git)، وفيه الفولدر الرئيسي على جهازك:
   ```json
   { "root": "D:/retheme-swift-project" }
   ```
2. **الـ assets الأصلية** (من رنا أو من فريق التطوير) → `base-assets\aber-alqarat\`.
3. **ملفات الهوية** لكل عميل (اللوجو والخطوط) → `projects/<name>/brand/` (متجاهل في git، فلازم تجيبها بنفسك، [ADR 0001](decisions/0001-tools-and-docs-only.md)).
   - `logo-color.png`: اللوجو الملون بخلفية شفافة.
   - `logo-white.png`: نسخة للخلفيات الغامقة.

المسارات في `project.json` مكتوبة بـ `{root}/...`، فالأدوات بتلاقي كل حاجة لوحدها. لو جهاز معين محتاج مسار مختلف لمشروع، اعمل `projects/<name>/project.local.json` فيه `sourceDir` أو `outputDir`، وده ليه الأولوية.

### نقل جهاز عليه مشاريع قديمة (مرة واحدة)
لو كنت شغال قبل الترتيب ده بـ `project.local.json`:
1. انقل الـ assets الأصلية لـ `base-assets\aber-alqarat\`.
2. حط ناتج كل مشروع **جوه** `clients\<name>\` على طول، من غير فولدر جواه: `clients\jusur-almawared\` (206 ملف) و`clients\excp-swift-demo\` (204 ملف).
3. اعمل `workspace.local.json`، وامسح `project.local.json` القديم من كل مشروع.
4. اتأكد: `.\tools\Compare-Assets.ps1 -Project jusur-almawared` لازم يطلع `missing 0 | extra 0`.

## 4. جرّب

```powershell
.\tools\Invoke-Retheme.ps1 -Project excp-swift-demo -Force
.\tools\Render-Banners.ps1 -Project excp-swift-demo
.\tools\Compare-Assets.ps1 -Project excp-swift-demo
```

المفروض الخطوة الأخيرة تطبع: `Total 204 | changed 77 | unchanged 127 | missing 0 | extra 0`

## 5. لو بتستخدم Claude Code

افتح الريبو في Claude Code. ملف `CLAUDE.md` وملفات `memory/` بيتقروا لوحدهم، فهيعرف القواعد والتاريخ من غير ما تشرح من الأول.

أول مرة هيطلب موافقة على الـ hooks اللي في [.claude/settings.json](../.claude/settings.json). **وافق**، لأنها بتعمل `git pull` أول كل جلسة، وبتفعّل الـ git hooks، ومش بتخلّي الجلسة تخلص من غير push ([ADR 0015](decisions/0015-binding-rules-enforced.md)).

## 6. القواعد ملزمة

كل القواعد والقرارات ملزمة من أول سحب ([CONTRIBUTING.md](../CONTRIBUTING.md)). لو بتشتغل من غير Claude Code، الـ git hooks بتتفعّل أول ما تشغّل أي أداة من `tools/`. ولو عايز تفعّلها على طول:

```powershell
git config core.hooksPath .githooks
```
