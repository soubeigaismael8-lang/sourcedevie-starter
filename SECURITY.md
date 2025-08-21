# Security policy & secrets handling

## Gestion des secrets
Les secrets (API keys, JWT private keys, DB passwords, webhooks ...) **ne doivent jamais** être committés.
Utiliser GitHub Secrets → Settings → Secrets and variables → Actions.

## Procédure immédiate si un secret est exposé
1. Révoquer / régénérer la clé compromise.
2. Purger l’historique git.
3. Activer Secret Scanning et push protection.
