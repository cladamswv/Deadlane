# DEADLANE: ZOMBIE BRIDGE

A portrait, offline, fully 3D bridge-defense shooter built for **Godot 4.7.2-stable** with typed GDScript and the **Compatibility** renderer. The player drags a survivor sideways at the near end of a detailed bridge while the player aims by lateral position and holds FIRE to shoot straight down the current lane. Version 1.5.1 contains a 30-wave campaign, five regular zombie types, three boss encounters, four weapons, bullet-multiplying gates, grenades, run upgrades, checkpoint saves, settings, and an endless mode unlocked by campaign completion.

> **Build honesty:** this source package was created in a workspace that did not contain Godot or the Android SDK, and the workspace could not download the engine binary. Therefore no local Godot import, Android compilation, APK, real gameplay screenshot, or device-performance claim is included. The repository does include a pinned GitHub Actions workflow that downloads Godot 4.7.2 and matching templates, runs engine/parser tests, then builds a signed arm64 development APK. Do not call the ZIP an APK.

## Technology lock

- Engine: **Godot 4.7.2-stable** (official release date: 2026-08-18).
- Language: typed GDScript.
- Renderer: GL Compatibility (`gl_compatibility`) for broad Android support.
- Reference viewport: 720 × 1280 portrait with responsive Control anchors and safe-area margins.
- Application ID: **`com.deadlane.zombiebridge`**. Keep this unchanged if you want Android updates to install over earlier builds.
- Android CI toolchain: OpenJDK 17, Android Platform 35, Build-Tools 35.0.1, NDK 28.1.13356709 (r28b), CMake 3.10.2.4988404.
- Minimum exported architecture in this repository: arm64-v8a.

Official references:
- Godot 4.7.2 archive: https://godotengine.org/download/archive/4.7.2-stable/
- Renderer overview: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Godot MIT license: https://godotengine.org/license/
- Godot 4.7 Android export documentation: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html

## What is implemented

The gameplay scene is generated from reusable systems instead of relying on editor-only assembly. Version 1.5 expands the ruined quarantine corridor with type-specific zombie silhouettes, modeled weapon assets, six additional PBR-style surface families, emissive lighting details, and a much denser peripheral-city pass while preserving the readable central firing lane. Version 1.2 turned the bridge into a failed quarantine-evacuation corridor. Beyond the firing lane are broken guardrails, a crashed bus, abandoned ambulance, checkpoint booths, sandbag positions, container stacks, wreck fires, smoke, warning beacons, ruined signs, debris piles, exposed structure and a more damaged skyline. The survivor and zombies remain fully original but now use substantially more modeled geometry, including dedicated head, torso, arm, leg and boot assets instead of relying on capsule silhouettes. The survivor adds layered utility gear and rebuilt weapons; zombies add close-range facial damage, teeth, hair, torn clothing, exposed-rib shapes and type-specific equipment. Distant zombie detail is hidden automatically to protect crowded Android scenes.

Combat includes relative one-finger horizontal dragging, mouse dragging, A/D development controls, manual hold-to-fire with no zombie auto-targeting, unlimited ammunition, pooled swept projectile hit tests, weapon-specific spread/penetration, muzzle feedback, pooled impact flashes, hit reactions, death animation, pooled enemies, loose lane movement, local separation, a shared 100-point defense meter, telegraphed spitter/boss attacks, one-time breaches, grenade clustering, and x2/x3 bullet gates that split each projectile family once. Version 1.1 added bounded acceleration, viewport-aware drag sensitivity, procedural player footwork/body lean, eased recoil, frame-rate-stable held-fire catch-up, smoother zombie acceleration/stride animation, animated gate pulses, and a layered grenade blast.

The campaign now has **30 waves** split into three presentation phases: Evacuation (1-10), Sunset Siege (11-20), and Nightfall (21-30). Regular wave budgets use `round(12 + 3.3w + 0.20w²)`, boss waves reduce the ordinary budget, and regular HP still scales by `1 + 0.04(w - 1)` with speed capped at 135% of base. Population is capped at 110 and deferred spawns remain scheduled instead of being discarded. Wave 10 uses the Bridge Brute, wave 20 uses the Plague Giant, and wave 30 introduces the 6,200-HP Overpass Colossus. Rush waves at 5, 8, 12, 16, 20, 24, 28, and 30 arrive in larger warned packs. Campaign victory at wave 30 unlocks the standalone Endless mode, which starts a fresh run and rotates a boss every tenth wave with its spawn budget capped at 210 points.

Run upgrades are offered after waves 4, 8, 12, 16, 20, 24, and 28. Permanent progression remains intentionally limited to weapon unlocks, records, campaign completion, and settings. Checkpoints are versioned and written after completed waves, including pending upgrade choices, RNG state, health, score, weapon, run upgrades, and grenade cooldown. A force-close mid-wave restarts that wave from the prior checkpoint.

## Fastest phone-only GitHub workflow

1. On your Android phone, create a **new empty GitHub repository**. Do not add a README or `.gitignore` because both are already in this project.
2. Download and extract `DEADLANE-ZOMBIE-BRIDGE-1.5.1-DEBUG-FRESH-INSTALL.zip`. The extracted folder itself contains `project.godot` and `.github/workflows/android.yml` at the top level.
3. Upload **the contents of that folder**, including the hidden `.github` folder, to the repository. GitHub's web interface may be awkward with folders; a Codespace is usually easier for the first upload.
4. In a Codespace terminal, after the project ZIP is uploaded, use: `unzip -q DEADLANE-ZOMBIE-BRIDGE-1.5.1-DEBUG-FRESH-INSTALL.zip -d /tmp/deadlane && cp -a /tmp/deadlane/. . && git add -A && git commit -m "Fresh install DEADLANE v1.5.1 debug fix" && git push`.
5. Open the repository's **Actions** tab, select **Build Android APK**, and tap **Run workflow**. A push to `main` also starts the workflow.
6. The workflow verifies SHA-256 hashes for the pinned Godot binary/templates, imports the project, runs targeted engine tests and the deterministic balance simulation, captures reference screens when the virtual display succeeds, exports the arm64 debug APK, and uploads an artifact named **DEADLANE-Android-Debug**.
7. Open the completed workflow run, download that artifact, extract it on Android, and install `DEADLANE-Zombie-Bridge-debug.apk`. Android may ask you to allow installs from your browser/files app.
8. Future CI debug builds use the same committed **development-only** signing key, so they can install as updates over earlier development builds as long as `com.deadlane.zombiebridge` stays unchanged.

### Important signing note

`ci/deadlane-development.keystore` is deliberately a **public development key** committed only to make sideloaded test APK updates painless. Its password is visible in the workflow. It must **never** be used for a Play Store release. A future store AAB should use a private release/upload key stored outside the repository (for example GitHub encrypted secrets) and should be treated as a separate release process.

## Desktop/editor run

With Godot 4.7.2 installed, open the folder containing `project.godot` and press Run Project. Development controls are A/D or mouse drag; touch drag is used on Android. Hold Space to fire, G triggers a grenade, and Escape pauses on desktop.

For a command-line import/parser check:

```bash
godot --headless --editor --path . --quit
```

For the targeted engine test suite:

```bash
godot --headless --path . --script res://tests/test_runner.gd
```

For the deterministic balance report (this is **not** human playtesting):

```bash
python3 tests/balance_simulation.py
```

## Project layout

```text
project.godot
export_presets.cfg
.github/workflows/android.yml
assets/audio/                 original generated WAV files
assets/models/                original modeled OBJ character/prop assets
assets/textures/              original albedo/normal/roughness PBR maps
assets/icons/                 project icon
data/balance.json             editable balance constants
scenes/main.tscn              minimal scene entry point
scripts/core/                 state, save, audio, orchestration
scripts/gameplay/             player, weapons, zombies, waves, gates, grenade, upgrades
scripts/world/                bridge and character mesh factories
scripts/ui/                   menus, HUD, pause/settings, upgrades, results, credits
tests/                        engine tests and deterministic balance simulation
tools/                        CI helpers + deterministic original model generator
ci/                           public development-only signing keystore
docs/                         architecture, licenses, verification notes
```

## Tuning notes

The numeric weapon/enemy values in `data/balance.json` are deliberately easy to edit together. The included deterministic simulation is a sanity check only. It does not prove campaign duration, boss fight duration, touch usability, camera composition, or real Android frame rate. Those items require the APK to run on actual hardware and should be tuned from real play.

A useful first hardware pass is: complete waves 1–6 at 60 FPS, stress wave 16 with a shotgun gate and grenade, stress the denser Nightfall waves 22–30, fight all three bosses, background/resume the app, force-close mid-wave and Continue, then run a second full campaign to look for stale pooled state or memory growth.

## Licenses

Godot is MIT licensed and has no engine subscription or royalties. `docs/THIRD_PARTY_NOTICES.md` contains the required Godot license notice and third-party guidance. All runtime game art and audio shipped in this repository is generated specifically for this project; there are no downloaded third-party models, textures, fonts, or sounds in this package.


## Version update notes

See `docs/UPDATE_1_1.md`, `docs/UPDATE_1_2.md`, `docs/UPDATE_1_3.md`, `docs/UPDATE_1_4.md`, and `docs/UPDATE_1_5.md` for the campaign, atmosphere, manual-fire, horde, audio, and art upgrades. `docs/TEST_REPORT_1_5.md` records the v1.5 art validation; `docs/DEBUG_CHECK_1_5_1.md` records the latest runtime/CI debug pass.


## Android SDK CI fix (September 2026)

GitHub's Ubuntu 24.04 runner currently includes Android command-line tools 12.0. An earlier workflow used `android-actions/setup-android@v3`, which attempted to replace those tools with command-line tools 16.0 and failed during `sdkmanager --licenses` before Godot was installed. The workflow no longer uses that action. It downloads Google's current Linux command-line tools package directly, verifies its official SHA-256 checksum, and uses that `sdkmanager` against the runner SDK root to install the exact packages required by this project.

The pinned CLI download is `commandlinetools-linux-15859902_latest.zip`, SHA-256 `4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583`. The project still requests Android Platform 35, Build-Tools 35.0.1, CMake 3.10.2.4988404, and NDK 28.1.13356709.


## Version 1.5 graphics polish

v1.5 adds dedicated survivor backpack/gloves, zombie hand/jaw meshes, road skid/oil/blood/scorch decals, police-SUV and fire-engine wrecks, rubble/rebar clusters, anisotropic material filtering, emissive tracers/muzzle flashes and improved impact sparks. See `docs/UPDATE_1_5.md`.


## v1.5.1 debug pass
See `docs/DEBUG_CHECK_1_5_1.md` for the lifecycle, deterministic RNG, Android Back-button, held-fire, and save validation fixes.
