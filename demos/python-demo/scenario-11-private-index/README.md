### Python Scenario 11: Private Index & Dependency Confusion

acme-internal-tool is 1.0.0 (private index) and 9.9.9 (public). pip --extra-index-url MERGES indexes and picks the highest version — installing the public 9.9.9 impostor (the Birsan 2021 attack). A single index, or uv first-index / Poetry source priority, installs the genuine 1.0.0.

Verify: vulnerable config -> 9.9.9; safe configs -> 1.0.0.
