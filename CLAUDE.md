# CLAUDE.md — تعليمات لـ Claude Code في الريبو ده

الملف ده بيتحمل تلقائي في أي جلسة Claude Code جوه الريبو، على أي جهاز.
هو والملفات اللي في `memory/` هما **الذاكرة الداخلية للمشروع**. حدّثهم في آخر أي شغل مهم.

@memory/README.md
@memory/user-preferences.md
@memory/lessons-learned.md
@memory/project-log.md

## الريبو بيعمل إيه

بيعمل retheme لفولدر assets بتاع تطبيق موبايل: ألوان SVG، صور مسطحة، لوجوهات، بانرات.
النتيجة فولدر جديد بنفس الأسماء ونفس الترتيب. التفاصيل في `README.md` و`docs/`.

## الأوامر

```powershell
.\tools\New-Project.ps1 -Name <name> -NameAr .. -NameEn .. -Primary .. -Secondary .. -FontAr .. -FontArSource .. -FontEn .. -FontEnSource ..   # عميل جديد + توثيقه
.\tools\Convert-SvgLogo.ps1 -Svg brand\logo.svg -Out brand\logo-white.png -White   # لوجو SVG
.\tools\Get-ColorReport.ps1 -Project <name> -OldBrand <hex,hex>   # تحليل
.\tools\Invoke-Retheme.ps1  -Project <name> -Force                # بناء
.\tools\Render-Banners.ps1  -Project <name> [-Only slider1.png]   # بانرات
.\tools\Compare-Assets.ps1  -Project <name> -OutFile docs\projects\<name>\changed-files.md
```

## قواعد ما تتكسرش

1. **ما تعدلش الفولدر الأصلي أبدًا.** الشغل كله بيطلع في `outputDir`.
2. **اسم الملف ومكانه ما يتغيروش** — بنعدل المحتوى بس، والصيغة تفضل زي ما هي (jpeg يفضل jpeg).
3. **غيّر ألوان اللوجو القديم بس.** الألوان المحايدة وأي لون مش من اللوجو القديم (زي أحمر الأخطاء) تفضل زي ما هي.
4. **ما تلمسش لوجوهات الجهات التانية** (مساند، واتساب، تيك توك، X، إنستجرام...). اللوجو اللي بيتغير هو لوجو العميل القديم واسمه بس.
5. **ملفات العملاء ما بتترفعش على git** (الريبو public). `projects/*/brand/` و`input/` و`output/` و`.work/` كلهم في `.gitignore`.
6. **ملفات `.ps1` لازم تكون ASCII بس.** أي نص عربي يتحط في JSON أو HTML ويتقري كـ UTF-8 (PowerShell 5.1 بيقرا السكريبت اللي من غير BOM على إنه ANSI).
7. **راجع كل صورة اتعدلت بعينك** (اقرا الـ PNG) قبل ما تقول إن الشغل خلص.
8. أي قرار جديد يتسجل في `docs/decisions/` بالقالب، وأي درس جديد يتكتب في `memory/lessons-learned.md`.
9. **`git pull` قبل أي تعديل، و`git push` بعده.** الريبو مشترك بين التيم ليد ورنا. الـ hooks في `.claude/settings.json` بتفرض ده ([ADR 0015](docs/decisions/0015-binding-rules-enforced.md)). لو الـ Stop hook وقفك، اعمل commit وpush أو قول للمستخدم ليه لازم يستنى.
10. **أي اسم ملف أو عنصر في الرد يكون رابط** (markdown link)، مش اسم بس.
11. **خطوط الهوية إلزامية:** ممنوع تبدأ مشروع من غير الخط العربي والإنجليزي (`brand.fonts` + ملف الخط في `brand/`)، وأي نص على الصور يتكتب بيهم ([ADR 0016](docs/decisions/0016-brand-fonts-mandatory.md)).
12. **ترتيب الفولدرات ثابت:** الأصل في `{root}\base-assets\<baseApp>`، والناتج في `{root}\clients\<name>`، و`{root}` متحدد في `workspace.local.json` على كل جهاز. أي عميل جديد بيبدأ بـ `New-Project.ps1`، وأي مشروع لازم يكون ليه `README.md` و`handoff.md` وسطر في السجل ([ADR 0018](docs/decisions/0018-workspace-layout-and-project-scaffold.md)).
13. **أول ما ييجي عميل جديد، اسأل أسئلة [docs/client-intake.md](docs/client-intake.md) كلها في رسالة واحدة**، وجنب كل سؤال الإجابة الافتراضية. ما تستناش المستخدم يفتكر هو، وما تبدأش من غير القسم "أ". وأي قرار جديد في أي مشروع ملهوش سؤال هناك، ضيفه كسؤال في نفس الـ commit ([ADR 0019](docs/decisions/0019-cumulative-client-intake.md)).

## طريقة التعامل مع المستخدم

- الكلام بالعامية المصرية، والتوثيق بالعربي.
- اسأل قبل أي قرار تصميم مش واضح (توزيع الألوان، شيل نص، اسم الشركة بالعربي).
- لما تسلّم شغل: قول اتعدل إيه بالأرقام، اتساب إيه وليه، وإيه اللي محتاج قرار منه.
