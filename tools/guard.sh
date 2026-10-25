#!/usr/bin/env bash
# Clean-room & Security Guard script (Bash)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXIT_CODE=0

echo "==> Running Clean-Room & Security Guard..."

FORBIDDEN_STRINGS=("VueXR" "Trium Designs" "Fudge3d")

for term in "${FORBIDDEN_STRINGS[@]}"; do
  if grep -rnI --exclude-dir={.git,.pipeline,.terragrunt-cache,.terraform} --exclude="guard.*" "$term" "$REPO_ROOT" > /dev/null 2>&1; then
    echo "[-] VIOLATION: Forbidden client reference '$term' found in repo:"
    grep -rnI --exclude-dir={.git,.pipeline,.terragrunt-cache,.terraform} --exclude="guard.*" "$term" "$REPO_ROOT" || true
    EXIT_CODE=1
  fi
done

if grep -rnIE --exclude-dir={.git,.pipeline,.terragrunt-cache,.terraform} "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----" "$REPO_ROOT" > /dev/null 2>&1; then
  echo "[-] VIOLATION: Private key pattern detected!"
  EXIT_CODE=1
fi

if grep -rnIE --exclude-dir={.git,.pipeline,.terragrunt-cache,.terraform} "(?<![A-Z0-9])AKIA[0-9A-Z]{16}(?![A-Z0-9])" "$REPO_ROOT" > /dev/null 2>&1; then
  echo "[-] VIOLATION: Potential AWS Access Key ID detected!"
  EXIT_CODE=1
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "[+] Clean-room guard passed: 0 secrets, 0 client references."
else
  echo "[-] Clean-room guard failed with violations!"
fi

exit "$EXIT_CODE"
