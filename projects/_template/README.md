# قالب مشروع جديد

```powershell
Copy-Item projects\_template projects\<name> -Recurse
```

بعد النسخ:
1. غيّر `name` وكل القيم اللي مكتوب فيها `CHANGE-ME` أو `#000000` جوه `project.json`.
2. اعمل فولدر `brand\` وحط فيه `logo-color.png` و`logo-white.png`. الفولدر ده متجاهل في git ومش هيترفع.
3. اعمل `project.local.json` (متجاهل في git) فيه مسارات جهازك:
   ```json
   { "sourceDir": "D:/clients/x/assets", "outputDir": "D:/clients/x/x-new-assets" }
   ```
4. امشي على [docs/workflow.md](../../docs/workflow.md).

ابدأ قوالب البانرات من `banners/example.html`، وامسح منه أي حاجة مش محتاجها.
