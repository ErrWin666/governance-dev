# PoC: interpreter-script channel — the exec gate sees "python3 file.py"
# (verb + path, zero writes) while the script writes to a protected path.
# Evidence artifact only; writes one benign marker file into logs/.
import io, os
p = "/mnt/c/governance-dev/logs/.poc-chan.txt"
try:
    with io.open(p, "w") as f:
        f.write("poc: wrote into protected logs/ via python3-script channel\n")
    print("WROTE", p)
except Exception as e:
    print("BLOCKED-AT-OS:", type(e).__name__, e)
