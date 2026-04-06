import subprocess
import sys

print("[v0] Updating pnpm lockfile...")
result = subprocess.run(
    ["pnpm", "install", "--no-frozen-lockfile"],
    cwd="/vercel/share/v0-project",
    capture_output=False,
)
if result.returncode != 0:
    print("[v0] Failed to update lockfile", file=sys.stderr)
    sys.exit(result.returncode)
print("[v0] Lockfile updated successfully.")
