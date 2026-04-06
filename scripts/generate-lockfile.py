import subprocess
import os
import glob

# Find the project directory
possible_dirs = glob.glob("/vercel/**", recursive=False) + glob.glob("/home/**", recursive=False) + ["/tmp", "/app"]
print("Searching for project...")

# Find package.json
result = subprocess.run(["find", "/", "-name", "package.json", "-not", "-path", "*/node_modules/*", "-maxdepth", "6"], 
                       capture_output=True, text=True, timeout=10)
print("package.json locations:", result.stdout[:500])

project_dir = None
for line in result.stdout.strip().split("\n"):
    if "v0-project" in line or "image-ai" in line:
        project_dir = os.path.dirname(line)
        break

if not project_dir:
    # Try common locations
    for d in ["/vercel/share/v0-project", "/app", "/workspace"]:
        if os.path.exists(d):
            project_dir = d
            break

print(f"Project dir: {project_dir}")

if project_dir:
    result2 = subprocess.run(["bun", "install"], cwd=project_dir, capture_output=True, text=True, timeout=120)
    print("stdout:", result2.stdout[:1000])
    print("stderr:", result2.stderr[:500])
    lockfile = os.path.join(project_dir, "bun.lockb")
    if os.path.exists(lockfile):
        print(f"SUCCESS: bun.lockb exists ({os.path.getsize(lockfile)} bytes)")
    else:
        print("bun.lockb not found after install")
