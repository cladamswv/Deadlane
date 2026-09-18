# DEADLANE v1.5.1 Fresh Install (Codespaces)

Use this for a brand-new GitHub repository or when you want to replace the project completely.

1. Create a new empty GitHub repository and open a Codespace.
2. Upload `DEADLANE-ZOMBIE-BRIDGE-1.5.1-DEBUG-FRESH-INSTALL.zip` into the Codespace root.
3. Run:

```bash
unzip -o DEADLANE-ZOMBIE-BRIDGE-1.5.1-DEBUG-FRESH-INSTALL.zip
rm DEADLANE-ZOMBIE-BRIDGE-1.5.1-DEBUG-FRESH-INSTALL.zip

git add -A
git commit -m "Fresh install DEADLANE v1.5.1 debug fix"
git push origin main
```

The push starts the Android GitHub Actions workflow. Current Android SDK/CI fixes are already included. Do not apply older parser/SDK/CI patch ZIPs afterward.

See `docs/DEBUG_CHECK_1_5_1.md` for the debug changes and validation boundary.
