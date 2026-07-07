
#!/usr/bin/env bash
set -euo pipefail

# Build script: create pmr-tracker-(VERSION).zip
# - reads `package_version` from manifest.json
# - excludes files and directories that start with a dot

cd "$(dirname "$0")" || exit 1

# Read version from manifest.json (try python3 then jq)
VERSION=""
if command -v python3 >/dev/null 2>&1; then
	VERSION=$(python3 - <<'PY'
import json,sys
try:
		with open('manifest.json') as f:
				data = json.load(f)
				v = data.get('package_version') or data.get('package_version')
				if not v:
						raise SystemExit(1)
				print(v)
except Exception:
		sys.exit(1)
PY
	) || true
fi

if [ -z "$VERSION" ] && command -v jq >/dev/null 2>&1; then
	VERSION=$(jq -r '.package_version' manifest.json 2>/dev/null || true)
fi

if [ -z "$VERSION" ]; then
	echo "Error: could not read package_version from manifest.json" >&2
	exit 1
fi

OUT="pmr-tracker-${VERSION}.zip"

# Remove any pre-existing archive with the same name
rm -f "$OUT"

if command -v zip >/dev/null 2>&1; then
	echo "Creating $OUT (excluding dotfiles, pop_version.json, build.sh) using zip..."
	# -r recurse, exclude top-level and nested dotfiles and the output archive itself, plus pop_version.json and build.sh
	zip -r "$OUT" . -x "$OUT" "*/.*" ".*" "pop_version.json" "build.sh"
else
	echo "zip not found; falling back to python3 zipfile (excluding dotfiles)"
	export OUT
	python3 - <<'PY'
import os,zipfile
out = os.environ.get('OUT')
if not out:
		raise SystemExit('OUT not set')
with zipfile.ZipFile(out, 'w', compression=zipfile.ZIP_DEFLATED) as z:
		for root, dirs, files in os.walk('.'):
				# skip dot-directories in-place so walk won't descend into them
				dirs[:] = [d for d in dirs if not d.startswith('.')]
				for f in files:
						# skip dotfiles and specified exclusions
						if f.startswith('.') or f in ('pop_version.json', 'build.sh'):
								continue
						path = os.path.join(root, f)
						# skip the output file if it's in the tree
						if os.path.normpath(path) == os.path.normpath('./' + out):
								continue
						arcname = os.path.relpath(path, '.')
						z.write(path, arcname)
print('Created', out)
PY
fi

echo "Created archive: $OUT"

# Compute SHA256 checksum
if command -v sha256sum >/dev/null 2>&1; then
	SHA=$(sha256sum "$OUT" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
	SHA=$(shasum -a 256 "$OUT" | awk '{print $1}')
else
	echo "Warning: no sha256sum or shasum available; skipping checksum" >&2
	SHA=""
fi

echo "SHA256: $SHA"

# Update pop_version.json if this version isn't present
if [ -n "$SHA" ]; then
  export VERSION OUT SHA
  python3 - <<'PY'
import os, json, subprocess, sys

version = os.environ['VERSION']
out = os.environ['OUT']
sha = os.environ['SHA']
pop_file = 'pop_version.json'

def load_pop():
	if os.path.exists(pop_file):
		with open(pop_file,'r') as f:
			return json.load(f)
	return {'versions': []}

pop = load_pop()
versions = pop.get('versions', [])
if any(v.get('package_version') == version for v in versions):
	print('Version', version, 'already present in', pop_file)
	sys.exit(0)

# Determine changelog from git history. Find commit that introduced the last recorded version
last_version = versions[-1]['package_version'] if versions else None
changelog = []
try:
	if last_version:
		# find commit where manifest.json contained last_version
		proc = subprocess.run(['git','log','-n','1','--pretty=format:%H','-S',f'"package_version": "{last_version}"','--','manifest.json'], capture_output=True, text=True)
		commit = proc.stdout.strip()
	else:
		commit = ''
	if commit:
		proc = subprocess.run(['git','log','--pretty=format:%s','--no-merges', f'{commit}..HEAD'], capture_output=True, text=True)
		changelog = [s for s in proc.stdout.splitlines() if s.strip()]
	else:
		proc = subprocess.run(['git','log','--pretty=format:%s','--no-merges','-n','50'], capture_output=True, text=True)
		changelog = [s for s in proc.stdout.splitlines() if s.strip()]
except Exception:
	changelog = []

if not changelog:
	changelog = ["No changelog available"]

download_url = f"https://github.com/boiscljo/pmr-tracker/releases/download/{version}/pmr-tracker-{version}.zip"
entry = {
	'package_version': version,
	'download_url': download_url,
	'sha256': sha,
	'changelog': changelog,
}

pop.setdefault('versions', []).append(entry)
with open(pop_file, 'w') as f:
	json.dump(pop, f, indent=4, ensure_ascii=False)
print('Appended', version, 'to', pop_file)
PY
fi

