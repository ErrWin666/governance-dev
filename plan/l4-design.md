# L4 Design — طبقة الأدوار المستقلة (8-role team)

WHY: VISION §3 — كل دور جلسة معزولة، التسليم بملفات لا محادثة،
المنفذ لا يعتمد، المدقق لا يكتب، المشكك/المهاجم يوثقان فقط.
العزل معماري (جلسات منفصلة) لا نصي — k-002/k-004.

## Roles (8)

| الدور | الواجب | ممنوع عليه | الجلسة |
|---|---|---|---|
| Supervisor | تفكيك/توزيع/قرار انتقال | اعتماد عمله | جلسة المنسق |
| Researcher | بحث عميق + أدوات + توثيق بمصادر | التنفيذ | منفصلة عند الحاجة (أُثبت) |
| Implementer | كود حسب الخطة المعتمدة + أدلة | اعتماد العمل | مشتركة حالياً (مقبول مؤقتاً) |
| Verifier | فحص ادعاءات vs أدلة، file:line | الكتابة/الإصلاح | منفصلة |
| Skeptic | تناقضات منطقية، Clever Hans | الكتابة/الإصلاح | منفصلة |
| Attacker | ثغرات + محاولات كسر | الكتابة/الإصلاح | منفصلة |
| Editor | تحرير التوثيق من الأدلة فقط | ادعاءات غير موثقة | منفصلة |
| Independent Writer | المخرج النهائي بمعزل عن المنفذ | رؤية سياق التنفيذ | منفصلة |

## Handoff contract (all file-based)

- `TASK.md` — الموجّه الوحيد (ذاتي الاكتفاء، repo-relative pointers)
- `verdict.json` — حكم موحد `{verdict|decision, findings[], feedback, evidence}`
- `findings.md` / `poc/` — مخرجات Skeptic/Attacker
- Digest sidecar — يكتشف تلاعب التسلسل fail-closed (ai-agent-handoff pattern)
- Spawn: `devin_session_create` لكل دور — VM منفصلة، لا يرى محادثة المنسق

## Role-enforcement roadmap

- الآن: عزل جلسات + ملفات فقط
- L4.3: تقييد أدوات كل دور (read-only للحُكمية) — قيد التحقق على Devin sessions
- CI يعيد حساب المزاعم (evidence manifests) — لا ثقة بالورق

## Build phases

| # | الخطوة | تثبت |
|---|---|---|
| L4.1 | جلسة Verifier تجريبية (TASK.md → verdict.json) | النمط تقنياً |
| L4.2 | قوالب موجّهات `roles/*.md` + عقد verdict | عقد التسليم |
| L4.3 | إنفاذ أدوات الدور ميكانيكياً | "المدقق لا يكتب" |
| L4.4 | دورة كاملة: Implement→3 حكم→Editor/Writer | فريق فعلي |

## Deferred / known limits

- Implementer=Supervisor مؤقتاً (الحُكم أهم فصلاً)
- tool-scoping داخل جلسة Devin غير موثق علناً — يُثبت تجريبياً
- L3-05 spec-writer: يُثبت على spec هذه الطبقة
