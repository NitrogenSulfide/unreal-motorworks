# Weapon selection and projectile defaults

Unpublished local candidate; the repository remains private and publication is held.

Each supported mount offers its vehicle's original gun as a named Default choice,
then None and a visual divider before the other guns. The divider cannot select a
weapon. Choosing None clears the driver, passenger or stationary gun actor and
its preview. Choosing a different gun clears the former gun's projectile and
interval overrides. No original gun appearance checkbox remains; the selected
gun supplies its appearance and muzzle. Legacy appearance flags are normalized
off in memory, while the serialized field remains compatible with old configs.

Edit opens the selected gun's draft. A new gun starts with its native projectile
classes and intervals. Existing custom edits for the same gun remain available.
Restore Defaults resets only the draft to that selected gun's native settings.
Done applies changed values; Cancel and Escape discard edits and draft resets.
Done without changes preserves the exact existing parent profile.

The native regression checks cover None through the dropdown callback, both
preview tabs, driver/passenger/stationary runtime removal, restoring gun actors,
per-mount Default choices, separator rejection, switching gun defaults, physical
Restore Defaults input, Cancel, save/reopen/restart and custom runtime firing.
Final screenshots and exact package identities are recorded in private evidence.
Portable CI is not a native UI or gameplay test.
