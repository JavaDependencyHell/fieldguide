# Welcome To the sample of the Dependency Management Troubleshooting Guide{.unnumbered} 

---

### This sample is rough and ready. We reserve every right to correct any mistakes  {.unnumbered}

This QR code takes you to the HeroDevs website where you get the latest version of this sample and register for the complete book when available.

![QR Code](book/content/sample-qr.png){height=100px}


---

### Who This Book Is For {.unnumbered}

Dependency management often behaves as you would guess enough times to earn your trust. Until it doesn’t. 

Most trouble stems not from misunderstanding Maven or Gradle syntax, but from making assumptions that conflict with how build tools actually operate. This book is about the mechanical rules that govern those operations.

If you have stared at a dependency tree and thought, “that doesn’t make sense,” this book is for you.

It is written for

- **Experienced Developers:** Who know how to use exclusions and BOMs, but have learned that today’s fix can become tomorrow’s mystery.
- **Tech Leads & Build Owners:** who are responsible for build stability and must explain why a version changed or why "just upgrade it" isn't a strategy.
- **Platform & Security Engineers:** who recognize failure modes as consequences of real-world dependency resolution, not just developer mistakes.
- **Junior Developers:** This guide will help you avoid persistent misconceptions early in your career.

--- 

### How to Use This Guide  {.unnumbered}

This guide is designed for reactive use. When a version changes unexpectedly or a class disappears at runtime, scan the scenario titles. Each scenario provides rapid orientation: expected intuition, actual results, the underlying mechanism, and safe resolutions.

Alternatively, read several scenarios to understand the system's shape. You will notice recurring patterns—these represent the core mechanics of dependency resolution.

This is not a reference manual or a replacement for official documentation. It does not provide exhaustive command sequences. 

Instead, it explains the "why." Dependency resolution is not intuitive or opinionated; it is mechanical, structural, and remarkably consistent. Once you understand the rules, the behavior becomes predictable.

### How to Read This Guide {.unnumbered}

This book is intentionally structured as a field guide rather than a traditional narrative text. Each scenario is broken into consistent, repeatable sections so that you can scan quickly, compare behaviours across tools, and jump directly to the part that matters for your current problem.

If you are reading linearly, the structure will feel familiar after the first few scenarios. If you are dipping in to diagnose a specific dependency issue, the visual markers and badges are designed to help you orient yourself quickly.

### Scenario References ( S1, S2, …) {.unnumbered}

Throughout the book you will see compact badges such as S1 or S12. These are scenario identifiers.

Each scenario in the guide is numbered sequentially. When a badge appears in the text, it is pointing you to the scenario where that behaviour is demonstrated in full.

For example, if a section mentions S3, it is indicating that the behaviour being discussed is explored in detail in Scenario 3. The badges are purely navigational — they do not indicate severity or importance.

### The Callout Sections {.unnumbered}

Each scenario is composed of clearly marked callout blocks. These blocks always use the same vocabulary so that you can quickly locate the information you need.

**SCENARIO**
Describes the situation being explored and why it matters. This is the starting point if you are trying to recognise whether a scenario applies to your system.

**EXAMPLE**
Shows the dependency shape or graph involved and any related config . If you are a visual reader, this is often the fastest way to understand what is happening.

**EXPECT**
Captures the mental model most developers have when approaching the situation. This is intentionally written from the reader’s point of view.

**ACTUAL**
Shows what the build tool or runtime actually does. Differences between EXPECT and ACTUAL are where most surprises live.

**REALITY**
Summarises the effective classpath or resolution state, often comparing Maven, Gradle, and SBT behaviour.

**WHY**
Explains the underlying mechanism that produces the observed behaviour. If you want the root cause rather than the symptom, start here.

**FIX**
Describes common remediation steps teams attempt in the wild. These are not always the recommended long-term approach.

**RISK**
Assesses the operational impact if the situation is left unresolved. Not every scenario is catastrophic, but many are more subtle than they first appear.

**CONTROL**
Presents safer, more deterministic ways to manage the situation. If you are looking for the “do this in production” guidance, this is usually the section you want.

**CHECK**
Provides fast, mechanical ways to verify what your build or runtime is actually doing.

**LOOK**
Highlights specific strings or patterns to search for in logs, dependency trees, or reports.

**SCALES**
Explains how the problem behaves as dependency graphs grow larger or more complex.

**TAKEAWAY**
A short, practical summary of what to remember from the scenario.

**WILD**
Real-world context showing where this pattern appears outside of controlled examples.

**RELATED**
Pointers to other scenarios that exhibit similar or adjacent behaviour.

### Colour and Visual Cues {.unnumbered}
 
The colour palette in this guide is intentionally restrained. Colour is used sparingly to reinforce meaning rather than decorate the page.

In particular:

* Red-tinted blocks indicate operational risk.
* Green-tinted blocks indicate safer or more controlled approaches.
* Neutral tones are used for explanatory and structural sections.

If you are scanning quickly, the colour cues can help you jump directly to risk or remediation guidance.

### Reading Strategies {.unnumbered}

Different readers use this guide in different ways.

If you are diagnosing a live issue, start with the SCENARIO description and jump directly to CHECK and CONTROL.

If you are building mental models, read EXPECT → ACTUAL → WHY in sequence. This is where most of the conceptual value sits.

If you are assessing production impact, go straight to RISK and TAKEAWAY.

There is no single correct reading order. The structure is designed so that you can enter at the point of highest relevance and still recover the full context when needed.
