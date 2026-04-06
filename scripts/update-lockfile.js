import { execSync } from "child_process";

console.log("[v0] Updating pnpm lockfile...");
execSync("pnpm install --no-frozen-lockfile", { stdio: "inherit", cwd: "/vercel/share/v0-project" });
console.log("[v0] Lockfile updated.");
