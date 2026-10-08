# Projectile editing without a mode checkbox

Unpublished local candidate; the repository remains private and publication is held.

The weapon rows no longer expose Custom projectiles checkboxes. Edit opens a draft
of the selected gun's current firing settings. Cancel or Escape discards edits;
Done without changes preserves the exact existing profile. Applying changed
projectiles or intervals activates the internal custom firing state. Applying
values matching the selected gun's defaults restores its native firing behavior.
Existing active custom profiles remain supported; inactive historical overrides
are retained in saved profiles but do not override defaults when opening Edit.

Use original gun appearance moves beneath each weapon selector. Its native text
width is measured so the checkbox sits beside the caption at different resolutions.
Placement auto-rotate starts enabled, with the visible checkbox synchronized to
the rendering state; users can turn it off during the editing session.

The native workflow fixture covers applying changes, unchanged Done on both
native/default and custom profiles, restoring selected-gun defaults, Cancel,
Escape, save/reopen/restart, driver/passenger and stationary runtime firing,
Motorpool preview, appearance row bounds and actual Placement rotation/toggle.
Native package hashes, final screenshots and review outcomes are recorded in the
private candidate evidence. Portable CI is not a native UI or gameplay test.
