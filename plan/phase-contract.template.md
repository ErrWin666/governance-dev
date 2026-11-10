# Phase Contract — <اسم المرحلة>
# WHY: rule 12 + rule 19 — no phase transition without a contract, and
# every contract MUST declare `size:`. CI (A10) fails plan/phase-*.md
# files missing the field. Copy this file to plan/phase-<n>-<name>.md.

## size:
- functions: <عدد الدوال المتوقع>
- files: <عدد الملفات>
- max_lines_per_file: <الحد>
- complexity: <S|M|L — يحدد عمق الحوكمة المطلوبة>

## scope
- in: <ما يشمله>
- out: <ما لا يشمله>

## evidence_to_produce
- [ ] plan/phase-<n>-contract.md (هذا الملف)
- [ ] evidence/P<n>/manifest.json
- [ ] test coverage report
- [ ] owner approval at phase end (M8)

## done_when
- <معايير قياسية قابلة للفحص — لا "يعمل" بل "الاختبار الفلاني يمر">
