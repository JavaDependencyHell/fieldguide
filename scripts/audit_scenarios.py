#!/usr/bin/env python3
"""audit_scenarios.py — completeness audit for the JVM scenario matrix.

For every tool track (maven, gradle, sbt) and scenario 1..N, checks:
  1. scenario directory exists under demos/<tool>-demo/
  2. guide.qmd exists and has YAML frontmatter + a Tool Versions callout
  3. a build file exists (pom.xml / build.gradle[.kts] / build.sbt)
  4. README.md exists
  5. the guide is listed in _quarto.yml
  6. demos/<tool>-demo/verify.sh contains a check for the scenario
  7. every snippet="..." the guide references exists as tag::/end:: in the
     referenced file
  8. every relative Related link points at a file that exists

It then checks the RUNTIME FIXTURES the demos resolve against (these are
generated, and `make clean` deletes most of them):
  9.  target/local-repo populated with the com.demo fixture artifacts
      (including the jdk11-classified lib-a used by Maven scenario 13)
  10. demo-dependencies/private-repo with the patched-bom / 2.5.14.ACME
      artifacts used by scenarios 16/17
  11. demo-utils/target/demo-utils-1.0.0.jar (used by verify.sh checkers)

Missing fixtures are failures with the fix named (`install_deps.sh`), so
after `make clean` this audit correctly reports the demos as not runnable.

Exit code 0 = complete; 1 = gaps found. Run from the repo root:
    python3 scripts/audit_scenarios.py
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = {
    "maven": ["pom.xml"],
    "gradle": ["build.gradle", "build.gradle.kts"],
    "sbt": ["build.sbt"],
}
N_SCENARIOS = 18

problems = []
warnings = []


def note(level, msg):
    (problems if level == "FAIL" else warnings).append(msg)


quarto = open(os.path.join(ROOT, "_quarto.yml")).read()

for tool, build_files in TOOLS.items():
    demo_dir = os.path.join(ROOT, "demos", f"{tool}-demo")
    verify = ""
    vpath = os.path.join(demo_dir, "verify.sh")
    if os.path.exists(vpath):
        verify = open(vpath).read()
    else:
        note("FAIL", f"{tool}: no verify.sh")

    # map scenario number -> directory
    dirs = {}
    for d in os.listdir(demo_dir):
        m = re.match(r"scenario-(\d+)-", d)
        if m:
            dirs[int(m.group(1))] = os.path.join(demo_dir, d)

    for n in range(1, N_SCENARIOS + 1):
        tag = f"{tool} S{n}"
        if n not in dirs:
            note("FAIL", f"{tag}: scenario directory missing")
            continue
        sdir = dirs[n]
        rel = os.path.relpath(sdir, ROOT)

        # guide
        guide_path = os.path.join(sdir, "guide.qmd")
        if not os.path.exists(guide_path):
            note("FAIL", f"{tag}: guide.qmd missing")
            continue
        guide = open(guide_path).read()
        if not guide.startswith("---"):
            note("WARN", f"{tag}: guide has no YAML frontmatter")
        if 'title="Tool Versions"' not in guide:
            note("WARN", f"{tag}: guide has no Tool Versions callout")

        # build file
        if not any(os.path.exists(os.path.join(sdir, b)) for b in build_files):
            note("FAIL", f"{tag}: no build file ({'/'.join(build_files)})")

        # README
        if not os.path.exists(os.path.join(sdir, "README.md")):
            note("WARN", f"{tag}: README.md missing")

        # _quarto.yml wiring
        if f"{rel}/guide.qmd" not in quarto:
            note("FAIL", f"{tag}: guide not listed in _quarto.yml")

        # verify.sh coverage
        if verify and not re.search(rf"Scenario {n}[ :(]", verify):
            note("WARN", f"{tag}: no check in {tool} verify.sh")

        # snippet references
        for inc, snip in re.findall(r'include="([^"]+)"\s+snippet="([^"]+)"', guide):
            target = os.path.join(sdir, inc)
            if not os.path.exists(target):
                note("FAIL", f"{tag}: guide includes missing file {inc}")
            elif f"tag::{snip}[" not in open(target).read():
                note("FAIL", f"{tag}: snippet marker '{snip}' not in {inc}")

        # relative links
        for href in re.findall(r"\]\((\.\./[^)]+\.qmd)\)", guide):
            if not os.path.exists(os.path.normpath(os.path.join(sdir, href))):
                note("FAIL", f"{tag}: broken Related link {href}")

# ---- Python part (structure differs: tool subdirs, no single build file) ----
PY_DIR = os.path.join(ROOT, "demos", "python-demo")
N_PY = 12
if not os.path.isdir(PY_DIR):
    note("FAIL", "python-demo directory missing")
else:
    py_verify = ""
    pvpath = os.path.join(PY_DIR, "verify.sh")
    if os.path.exists(pvpath):
        py_verify = open(pvpath).read()
    else:
        note("FAIL", "python: no verify.sh")
    pdirs = {}
    for d in os.listdir(PY_DIR):
        m = re.match(r"scenario-(\d+)-", d)
        if m:
            pdirs[int(m.group(1))] = os.path.join(PY_DIR, d)
    for n in range(1, N_PY + 1):
        tag = f"python P{n}"
        if n not in pdirs:
            note("FAIL", f"{tag}: scenario directory missing")
            continue
        sdir = pdirs[n]
        rel = os.path.relpath(sdir, ROOT)
        gpath = os.path.join(sdir, "guide.qmd")
        if not os.path.exists(gpath):
            note("FAIL", f"{tag}: guide.qmd missing")
        else:
            guide = open(gpath).read()
            if not guide.startswith("---"):
                note("WARN", f"{tag}: guide has no YAML frontmatter")
            if 'title="Tool Versions"' not in guide:
                note("WARN", f"{tag}: guide has no Tool Versions callout")
            for inc, snip in re.findall(r'include="([^"]+)"\s+snippet="([^"]+)"', guide):
                target = os.path.join(sdir, inc)
                if not os.path.exists(target):
                    note("FAIL", f"{tag}: guide includes missing file {inc}")
                elif f"tag::{snip}[" not in open(target).read():
                    note("FAIL", f"{tag}: snippet marker '{snip}' not in {inc}")
            for href in re.findall(r"\]\((\.\./[^)]+\.qmd)\)", guide):
                if not os.path.exists(os.path.normpath(os.path.join(sdir, href))):
                    note("FAIL", f"{tag}: broken Related link {href}")
        if not os.path.exists(os.path.join(sdir, "README.md")):
            note("WARN", f"{tag}: README.md missing")
        if f"{rel}/guide.qmd" not in quarto:
            note("FAIL", f"{tag}: guide not listed in _quarto.yml")
        if py_verify and not re.search(rf"Scenario {n}[ (]", py_verify) \
                and not re.search(rf'run_scenario {n} ', py_verify):
            note("WARN", f"{tag}: no check in python verify.sh")

# ---- Runtime fixtures (generated; deleted by `make clean`) ----
LOCAL_REPO = os.path.join(ROOT, "target", "local-repo")
FIXTURES = [
    "com/demo/lib-a/1.0.0/lib-a-1.0.0.jar",
    "com/demo/lib-a/1.0.0/lib-a-1.0.0-jdk11.jar",
    "com/demo/lib-a/2.0.0/lib-a-2.0.0.jar",
    "com/demo/lib-b/1.0.0/lib-b-1.0.0.jar",
    "com/demo/lib-b/2.0.0/lib-b-2.0.0.jar",
    "com/demo/lib-c/1.0.0/lib-c-1.0.0.jar",
    "com/demo/lib-c/2.0.0/lib-c-2.0.0.jar",
    "com/demo/lib-circle-a/1.0.0/lib-circle-a-1.0.0.jar",
    "com/demo/lib-circle-b/1.0.0/lib-circle-b-1.0.0.jar",
    "com/demo/demo-bom/1.0.0/demo-bom-1.0.0.pom",
]
PRIVATE_REPO = os.path.join(ROOT, "demo-dependencies", "private-repo")
PRIVATE_FIXTURES = [
    "com/thirdparty/springboot/patched-bom/1.0.0/patched-bom-1.0.0.pom",
    "org/springframework/boot/spring-boot-starter/2.5.14.ACME/spring-boot-starter-2.5.14.ACME.jar",
    "org/springframework/boot/spring-boot-starter/2.5.14.ACME/spring-boot-starter-2.5.14.ACME.pom",
]

if not os.path.isdir(LOCAL_REPO):
    note("FAIL", "fixtures: target/local-repo missing — demos cannot resolve. Run install_deps.sh (expected after `make clean`).")
else:
    for f in FIXTURES:
        if not os.path.exists(os.path.join(LOCAL_REPO, f)):
            note("FAIL", f"fixtures: local-repo missing {f} — run install_deps.sh")

if not os.path.isdir(PRIVATE_REPO):
    note("FAIL", "fixtures: demo-dependencies/private-repo missing — scenarios 16/17 cannot resolve. Run install_private_repo.sh (or install_deps.sh).")
else:
    for f in PRIVATE_FIXTURES:
        if not os.path.exists(os.path.join(PRIVATE_REPO, f)):
            note("FAIL", f"fixtures: private-repo missing {f} — run install_private_repo.sh")

if not os.path.exists(os.path.join(ROOT, "demo-utils", "target", "demo-utils-1.0.0.jar")):
    note("FAIL", "fixtures: demo-utils/target/demo-utils-1.0.0.jar missing (verify.sh checker) — run install_deps.sh (expected after `make clean`).")

# Python fixture indexes (generated by install_python_deps.sh; under target/)
for repo, script in [("python-repo", "install_python_deps.sh"),
                     ("python-private-repo", "install_python_deps.sh")]:
    if not os.path.isdir(os.path.join(ROOT, "target", repo, "simple")):
        note("FAIL", f"fixtures: target/{repo}/simple missing — Python demos cannot resolve. Run {script} (expected after `make clean`).")

print(f"Scenario matrix audit — {N_SCENARIOS} JVM scenarios x {len(TOOLS)} tools + {N_PY} Python scenarios")
print("-" * 60)
for p in problems:
    print(f"[FAIL] {p}")
for w in warnings:
    print(f"[warn] {w}")
if not problems and not warnings:
    print("Complete: every scenario has directory, guide, build file,")
    print("README, _quarto.yml entry, verify coverage, valid references,")
    print("and all runtime fixtures are installed (demos are runnable).")
print("-" * 60)
print(f"{len(problems)} failures, {len(warnings)} warnings")
sys.exit(1 if problems else 0)
