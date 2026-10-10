#!/usr/bin/env bash
# Weekly check: is there a newer stable LiteLLM release, and any new security advisory?
# Read-only. Uses GitHub's public API (no login needed) and Node.js to read the JSON.
#
#   bash scripts/check-updates.sh            # advisories from the last 14 days
#   DAYS=30 bash scripts/check-updates.sh    # look further back

set -u
cd "$(dirname "$0")/.."
DAYS="${DAYS:-14}"

PINNED=$(grep -oE 'litellm:v[0-9]+\.[0-9]+\.[0-9]+' Dockerfile | head -1 | cut -d: -f2)
echo "Pinned version (Dockerfile): ${PINNED:-unknown}"
echo

api() { curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/BerriAI/litellm/$1"; }

echo "== Newest stable releases (no -rc / -dev) =="
api "releases?per_page=60" | PINNED="$PINNED" node -e '
let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{
  let r; try { r = JSON.parse(d); } catch { console.log("Could not read GitHub releases (rate limit?)"); return; }
  if (!Array.isArray(r)) { console.log("GitHub said:", r.message || "unexpected response"); return; }
  const v = s => s.replace(/^v/,"").split(".").map(Number);
  const newer = (a,b) => { for (let i=0;i<3;i++) { if (a[i]!==b[i]) return a[i]>b[i]; } return false; };
  const pinned = v(process.env.PINNED || "v0.0.0");
  const stable = r.filter(x => !x.prerelease && !x.draft && /^v\d+\.\d+\.\d+$/.test(x.tag_name));
  stable.slice(0, 8).forEach(x => {
    const mark = newer(v(x.tag_name), pinned) ? "  <- newer than pinned" : (x.tag_name === process.env.PINNED ? "  <- pinned" : "");
    console.log(`  ${x.tag_name.padEnd(10)} ${x.published_at.slice(0,10)}${mark}`);
  });
});'
echo

echo "== Security advisories published in the last ${DAYS} days =="
api "security-advisories?per_page=50&sort=published&direction=desc" | DAYS="$DAYS" node -e '
let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{
  let a; try { a = JSON.parse(d); } catch { console.log("Could not read advisories (rate limit?)"); return; }
  if (!Array.isArray(a)) { console.log("GitHub said:", a.message || "unexpected response"); return; }
  const since = Date.now() - Number(process.env.DAYS) * 864e5;
  const recent = a.filter(x => x.published_at && Date.parse(x.published_at) >= since);
  if (!recent.length) { console.log("  none"); return; }
  recent.forEach(x => {
    console.log(`  [${(x.severity||"?").toUpperCase()}] ${x.published_at.slice(0,10)} ${x.ghsa_id}: ${x.summary}`);
    (x.vulnerabilities||[]).forEach(v => console.log(`      affected: ${v.vulnerable_version_range || "?"}  fixed in: ${v.patched_versions || "?"}`));
    console.log(`      ${x.html_url}`);
  });
});'
echo
echo "If an advisory's 'affected' range includes the pinned version, follow MAINTENANCE.md section 2."
