# المساهمة

## إضافة مشروع (عميل) جديد
1. اعمل branch جديد: `git checkout -b project/<name>`
2. `Copy-Item projects\_template projects\<name> -Recurse`
3. امشي على [docs/workflow.md](docs/workflow.md) خطوة بخطوة.
4. اعمل commit لـ: `project.json`، و`banners/*.html`، و`docs/projects/<name>/`، وتحديث `memory/project-log.md` وجدول المشاريع في `README.md`.
5. افتح Pull Request بالقالب.

> ⚠️ **ممنوع** ترفع صور العميل أو خطوطه أو لوجوهاته. `.gitignore` بيمنع أغلبها، بس راجع `git status` قبل أي commit.

## تعديل الأدوات
- ملفات `.ps1` تفضل **ASCII بس**، وأي نص عربي يتحط في JSON أو HTML.
- أي إمكانية جديدة تبقى عامة وتتحكم فيها من `project.json`، ومفيش أي حاجة خاصة بعميل جوه `tools/`.
- بعد أي تعديل في الأدوات، **تأكد إن الناتج ما اتغيرش**: أعد بناء `excp-swift-demo` وقارن الـ hash بالناتج اللي اتسلم. المفروض يطلع 0 فرق، إلا لو التغيير مقصود ومكتوب في CHANGELOG.
- حدّث [docs/configuration.md](docs/configuration.md) لو ضفت خانة جديدة، و[docs/how-it-works.md](docs/how-it-works.md) لو غيرت خوارزمية.
- أي قرار ليه بدائل يتكتب ADR في `docs/decisions/`.

## أسماء الـ branches والـ commits
- **الـ branches:** `project/<name>`، `tool/<feature>`، `docs/<topic>`، `fix/<issue>`
- **الـ commits:** بصيغة [Conventional Commits](https://www.conventionalcommits.org/)، زي `feat(tools): ...` و`fix(banners): ...` و`docs: ...` و`chore(project-x): ...`

## الإصدارات
- اتبع SemVer: تغيير في `project.json` ما بيشتغلش مع القديم = major، وإمكانية جديدة = minor، وإصلاح = patch.
- حدّث `CHANGELOG.md` تحت `[Unreleased]`.
