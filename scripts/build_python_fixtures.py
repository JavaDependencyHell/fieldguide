#!/usr/bin/env python3
"""build_python_fixtures.py — builds the deterministic fixture wheels and
PEP 503 simple indexes used by the Python demos (demos/python-demo).

Layout produced:
  target/python-repo/wheels/*.whl          all public fixture wheels
  target/python-repo/simple/...            PEP 503 index over those wheels
  target/python-private-repo/wheels/*.whl  the "private" package
  target/python-private-repo/simple/...    PEP 503 index over the private wheel

Fixture graph (mirrors the JVM demo fixtures):
  demo-lib-a 1.0.0 -> demo-lib-b==1.0.0     (+ extra [feature] -> demo-lib-d)
  demo-lib-a 2.0.0 -> demo-lib-b==2.0.0     (+ extra [feature] -> demo-lib-d)
  demo-lib-b 1.0.0 -> demo-lib-c==1.0.0
  demo-lib-b 2.0.0 -> demo-lib-c==2.0.0
  demo-lib-c 1.0.0 / 2.0.0                  leaf
  demo-lib-d 1.0.0                          leaf
  acme-internal-tool 1.0.0                  PRIVATE index only
  acme-internal-tool 9.9.9                  PUBLIC index only ("attacker" package,
                                            used by the dependency-confusion demo)
"""
import base64
import hashlib
import os
import shutil
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PUBLIC = os.path.join(ROOT, "target", "python-repo")
PRIVATE = os.path.join(ROOT, "target", "python-private-repo")

WHEELS = [
    # (name, version, requires_dist list, target repo)
    ("demo-lib-a", "1.0.0",
     ["demo-lib-b==1.0.0", 'demo-lib-d==1.0.0; extra == "feature"'], PUBLIC),
    ("demo-lib-a", "2.0.0",
     ["demo-lib-b==2.0.0", 'demo-lib-d==1.0.0; extra == "feature"'], PUBLIC),
    ("demo-lib-b", "1.0.0", ["demo-lib-c==1.0.0"], PUBLIC),
    ("demo-lib-b", "2.0.0", ["demo-lib-c==2.0.0"], PUBLIC),
    ("demo-lib-c", "1.0.0", [], PUBLIC),
    ("demo-lib-c", "2.0.0", [], PUBLIC),
    ("demo-lib-d", "1.0.0", [], PUBLIC),
    # dependency-confusion fixture: same name, wildly newer version, public
    ("acme-internal-tool", "9.9.9", [], PUBLIC),
    ("acme-internal-tool", "1.0.0", [], PRIVATE),
]

EXTRAS = {"demo-lib-a": ["feature"]}


def record_line(path, data):
    digest = base64.urlsafe_b64encode(hashlib.sha256(data).digest()).rstrip(b"=")
    return f"{path},sha256={digest.decode()},{len(data)}"


def build_wheel(name, version, requires, out_dir):
    pkg = name.replace("-", "_")
    dist_info = f"{pkg}-{version}.dist-info"
    fname = f"{pkg}-{version}-py3-none-any.whl"
    marker = "COMPROMISED (public lookalike)" if version == "9.9.9" else "genuine"

    init_py = f'"""{name} {version} — Dependency Hell demo fixture ({marker})."""\n__version__ = "{version}"\n'.encode()
    metadata_lines = [
        "Metadata-Version: 2.1",
        f"Name: {name}",
        f"Version: {version}",
        "Summary: Dependency Hell demo fixture package",
    ]
    for extra in EXTRAS.get(name, []):
        metadata_lines.append(f"Provides-Extra: {extra}")
    for req in requires:
        metadata_lines.append(f"Requires-Dist: {req}")
    metadata = ("\n".join(metadata_lines) + "\n").encode()
    wheel_meta = (
        "Wheel-Version: 1.0\nGenerator: fieldguide-fixtures\n"
        "Root-Is-Purelib: true\nTag: py3-none-any\n"
    ).encode()

    files = {
        f"{pkg}/__init__.py": init_py,
        f"{dist_info}/METADATA": metadata,
        f"{dist_info}/WHEEL": wheel_meta,
    }
    record = "\n".join(record_line(p, d) for p, d in files.items())
    record += f"\n{dist_info}/RECORD,,\n"

    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, fname)
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zf:
        for p, d in files.items():
            zf.writestr(zipfile.ZipInfo(p, (2026, 1, 1, 0, 0, 0)), d)
        zf.writestr(zipfile.ZipInfo(f"{dist_info}/RECORD", (2026, 1, 1, 0, 0, 0)), record)
    return fname


def build_index(repo):
    wheel_dir = os.path.join(repo, "wheels")
    simple = os.path.join(repo, "simple")
    shutil.rmtree(simple, ignore_errors=True)
    packages = {}
    for whl in sorted(os.listdir(wheel_dir)):
        norm = whl.split("-")[0].replace("_", "-").lower()
        packages.setdefault(norm, []).append(whl)
    for norm, whls in packages.items():
        d = os.path.join(simple, norm)
        os.makedirs(d)
        links = "\n".join(
            f'<a href="../../wheels/{w}">{w}</a><br/>' for w in whls
        )
        with open(os.path.join(d, "index.html"), "w") as f:
            f.write(f"<!DOCTYPE html><html><body>\n{links}\n</body></html>\n")
    with open(os.path.join(simple, "index.html"), "w") as f:
        rows = "\n".join(f'<a href="{n}/">{n}</a><br/>' for n in sorted(packages))
        f.write(f"<!DOCTYPE html><html><body>\n{rows}\n</body></html>\n")


def main():
    for repo in (PUBLIC, PRIVATE):
        shutil.rmtree(repo, ignore_errors=True)
    for name, version, requires, repo in WHEELS:
        fname = build_wheel(name, version, requires, os.path.join(repo, "wheels"))
        print(f"built {fname} -> {os.path.relpath(repo, ROOT)}")
    for repo in (PUBLIC, PRIVATE):
        build_index(repo)
        print(f"indexed {os.path.relpath(repo, ROOT)}/simple")


if __name__ == "__main__":
    sys.exit(main())
