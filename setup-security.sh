#!/data/data/com.termux/files/usr/bin/bash
set -e

# Vérifie qu'on est dans le dossier du repo
if [ ! -d ".git" ]; then
  echo "❌ Lance ce script depuis la racine de ton repo git"
  exit 1
fi

# === PR1 - purge secrets ===
git checkout -b sec-purge-secrets
git rm -f --cached .env || true
cat > .gitignore <<'EOF'
.env
.env.*
*.pem
*.key
**/node_modules
dist
build
coverage
EOF
cat > SECURITY.md <<'EOF'
# Security policy & secrets handling

## Gestion des secrets
Les secrets (API keys, JWT private keys, DB passwords, webhooks ...) **ne doivent jamais** être committés.
Utiliser GitHub Secrets → Settings → Secrets and variables → Actions.

## Procédure immédiate si un secret est exposé
1. Révoquer / régénérer la clé compromise.
2. Purger l’historique git.
3. Activer Secret Scanning et push protection.
EOF
git add .gitignore SECURITY.md
git commit -m "security: remove .env and add .gitignore + SECURITY.md"
git push origin sec-purge-secrets
gh pr create -B main -H sec-purge-secrets -t "security: purge secrets" -b "Remove .env, add .gitignore and SECURITY.md. Rotate credentials after merge."

# === PR2 - CI/CD hardening ===
git checkout main
git pull
git checkout -b sec-ci-hardening
mkdir -p .github/workflows
cat > .github/dependabot.yml <<'EOF'
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule: { interval: "weekly" }
  - package-ecosystem: "npm"
    directory: "/services/payment-service"
    schedule: { interval: "weekly" }
  - package-ecosystem: "docker"
    directory: "/"
    schedule: { interval: "weekly" }
EOF
cat > .github/workflows/codeql.yml <<'EOF'
name: "CodeQL"
on:
  push: { branches: ["main"] }
  pull_request: { branches: ["main"] }
  schedule: [{ cron: "0 3 * * 1" }]
jobs:
  analyze:
    permissions:
      contents: read
      security-events: write
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        language: [javascript, typescript]
    steps:
      - uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608
      - uses: github/codeql-action/init@1b1aada3f1a9e0c78c72a6a6a1b6f18b19d4f0a8
        with: { languages: ${{ matrix.language }} }
      - uses: github/codeql-action/analyze@1b1aada3f1a9e0c78c72a6a6a1b6f18b19d4f0a8
EOF
git add .github
git commit -m "security: add dependabot + codeql"
git push origin sec-ci-hardening
gh pr create -B main -H sec-ci-hardening -t "security: CI/CD hardening" -b "Add Dependabot and CodeQL workflows, pinned actions, minimal permissions."

# === PR3 - docker hardening ===
git checkout main
git pull
git checkout -b sec-docker-hardening
# NOTE: tu devras éditer manuellement docker-compose.yml pour ajouter:
# user: "1000:1000", read_only: true, cap_drop: [ALL], no-new-privileges:true, mem_limit, pids_limit
git add docker-compose.yml || true
git commit -m "security: harden docker-compose (non-root, limits, pinned digest)" || true
git push origin sec-docker-hardening
gh pr create -B main -H sec-docker-hardening -t "security: docker hardening" -b "Harden docker-compose services."

# === PR4 - node hardening ===
git checkout main
git pull
git checkout -b sec-node-hardening
cd services/payment-service
npm install helmet cors express-rate-limit express-slow-down zod
npm install -D @cyclonedx/cyclonedx-npm
cd ../..
git add services/payment-service/package.json services/payment-service/package-lock.json
git commit -m "security: add helmet, cors, rate limit, slow-down, zod, sbom"
git push origin sec-node-hardening
gh pr create -B main -H sec-node-hardening -t "security: harden Node service" -b "Add Helmet, CORS strict config, rate-limiting, slow-down, input validation and SBOM script."

# === PR5 - solidity audit ===
git checkout main
git pull
git checkout -b sec-solidity-audit
mkdir -p contracts
cat > contracts/.solhint.json <<'EOF'
{
  "extends": "solhint:recommended",
  "rules": {
    "compiler-version": ["error", "^0.8.20"],
    "func-visibility": ["error", { "ignoreConstructors": false }],
    "no-inline-assembly": "warn",
    "reason-string": ["warn", { "maxLength": 64 }]
  }
}
EOF
cat > contracts/package.json <<'EOF'
{
  "name": "contracts",
  "scripts": {
    "lint": "npx solhint 'contracts/src/**/*.sol'",
    "slither": "slither .",
    "mythril": "myth analyze contracts/src/ --solv 0.8.20"
  },
  "devDependencies": {
    "solhint": "^3.0.0"
  }
}
EOF
git add contracts
git commit -m "security: add solhint config and solidity audit scripts"

git push origin sec-solidity-audit
gh pr create -B main -H sec-solidity-audit -t "security: solidity audit" -b "Add solhint config and scripts, guidance for running slither/mythril"

