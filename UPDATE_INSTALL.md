# DEADLANE v1.5.1 Update (Codespaces)

Use this update **over DEADLANE v1.5 Graphics Polish**.

1. Upload `DEADLANE-ZOMBIE-BRIDGE-1.5.1-DEBUG-UPDATE.zip` beside `project.godot`.
2. Run:

```bash
unzip -o DEADLANE-ZOMBIE-BRIDGE-1.5.1-DEBUG-UPDATE.zip
rm DEADLANE-ZOMBIE-BRIDGE-1.5.1-DEBUG-UPDATE.zip

git add -A
git commit -m "Update DEADLANE to v1.5.1 debug fix"
git push origin main
```

This update carries only files changed/new relative to the released v1.5 fresh install. It includes the current GitHub workflow state indirectly by retaining the already-correct v1.5 workflow; no older patch ZIPs are required.

See `docs/DEBUG_CHECK_1_5_1.md` for details.
