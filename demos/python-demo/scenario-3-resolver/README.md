### Python Scenario 3: Resolver Strategies & History

demo-lib-a unpinned, demo-lib-c pinned 1.0.0. A backtracking resolver must fall back to demo-lib-a 1.0.0 (2.0.0 would force demo-lib-c 2.0.0). pip < 20.3 (greedy) would have installed a broken env instead.

Verify: resolved demo-lib-a is 1.0.0, not 2.0.0.
