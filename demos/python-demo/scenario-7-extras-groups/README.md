### Python Scenario 7: Extras & Dependency Groups

Extras = optional runtime features (demo-lib-a[feature] pulls demo-lib-d). Groups = optional dev sets (Poetry group / uv [dependency-groups]; pip uses separate requirements files).

Verify: demo-lib-d absent by default, present only when the extra/group is requested.
