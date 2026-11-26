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

## 3. حط ملفات المشروع على جهازك

ملفات العملاء مش على GitHub (شوف [ADR 0001](decisions/0001-tools-and-docs-only.md))، فلازم تجيبها بنفسك:

1. **اللوجوهات** → `projects/<name>/brand/`
   - `logo-color.png`: اللوجو الملون بخلفية شفافة.
   - `logo-white.png`: نسخة للخلفيات الغامقة.
2. **الـ assets الأصلية**: سيبها في أي مكان على جهازك.
3. اعمل ملف **`projects/<name>/project.local.json`**. الملف ده متجاهل في git، وفيه المسارات اللي على جهازك:

```json
{
  "sourceDir": "D:/clients/excp/assets",
  "outputDir": "D:/clients/excp/excp swift demo assets"
}
```

لو ما عملتش الملف ده، المسارات الافتراضية هي `projects/<name>/input` و`projects/<name>/output`، والاتنين متجاهلين في git.

## 4. جرّب

```powershell
.\tools\Invoke-Retheme.ps1 -Project excp-swift-demo -Force
.\tools\Render-Banners.ps1 -Project excp-swift-demo
.\tools\Compare-Assets.ps1 -Project excp-swift-demo
```

المفروض الخطوة الأخيرة تطبع: `Total 204 | changed 75 | unchanged 129 | missing 0 | extra 0`

## 5. لو بتستخدم Claude Code

افتح الريبو في Claude Code. ملف `CLAUDE.md` وملفات `memory/` بيتقروا لوحدهم، فهيعرف القواعد والتاريخ من غير ما تشرح من الأول.

أول مرة هيطلب موافقة على الـ hooks اللي في [.claude/settings.json](../.claude/settings.json). **وافق**، لأنها بتعمل `git pull` أول كل جلسة، وبتفعّل الـ git hooks، ومش بتخلّي الجلسة تخلص من غير push ([ADR 0015](decisions/0015-binding-rules-enforced.md)).

## 6. القواعد ملزمة

كل القواعد والقرارات ملزمة من أول سحب ([CONTRIBUTING.md](../CONTRIBUTING.md)). لو بتشتغل من غير Claude Code، الـ git hooks بتتفعّل أول ما تشغّل أي أداة من `tools/`. ولو عايز تفعّلها على طول:

```powershell
git config core.hooksPath .githooks
```
