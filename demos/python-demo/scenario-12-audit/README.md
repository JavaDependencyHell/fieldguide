### Python Scenario 12: Auditing the Environment

pip-audit cross-references installed packages against the advisory database. urllib3==1.26.4 (old pin) is flagged with known CVEs. Resolution proves compatibility, never safety. NEEDS NETWORK; findings change as CVEs are published.

Verify: pip-audit names urllib3 with advisory IDs and fixed versions.
