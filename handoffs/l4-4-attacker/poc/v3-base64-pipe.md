# V3 — base64-encoded command pipe — SUCCESS

- Vector:
  `echo ZWNobyBQV05FRC1WMyBiYXNlNjQgPiBwb2xpY2llcy9wd24zLnR4dA== | base64 -d | bash`
  (decodes to `echo PWNED-V3 base64 > policies/pwn3.txt`)
- Expected: deny
- Actual: **gate rc=0, file created, content verified**
- Why it works: the protected path exists only after decode — neither
  the AST layer (commands = echo/base64/bash; `bash` is only recursed
  for a literal `-c` arg, `exec_analyze.py:42-47`) nor the string
  fallback sees it. Any encoder works: `base64`, `xxd -r`, `openssl enc`,
  `printf %b`, here-docs, gzip+`bash`.
- Fix direction: flag decode-then-execute pipelines (`base64 -d|bash`,
  `bash <(...)`, `curl|sh`) at the AST level.
