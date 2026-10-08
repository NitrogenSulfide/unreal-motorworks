# Weapon slot availability after tab switching

Unpublished local fix; repository remains private and beta publication is on hold.

The previous build reproduced Driver Weapon #2 becoming active on a Goliath,
which has only one driver mount, after both Vehicle → Weapons and Placement →
Weapons transitions. A physical click could open the absent mount's dropdown.
The native combo's invalidation callback focuses its edit child without checking
whether the combo is disabled. The parent and arrow can therefore remain disabled
while the edit field and label reactivate.

The weapon dropdown now preserves disabled focus state during invalidation and
focus traversal. Showing Weapons restores absent mount controls to disabled state.
Selection callbacks and profile setters also reject mounts absent from the
vehicle's class defaults. Existing saved profiles are not rewritten by navigation.

The native regression uses real tab-button and absent-field mouse input on a
private authenticated virtual display, checks both tab routes and repeated focus,
compares the full profile, and exercises a fixture with a genuine second driver
mount to ensure valid mounts still work. It also checks passenger availability.
Exact commits, package hashes, test outcomes and independent review are recorded
in the private candidate evidence; portable CI does not validate native UI state.
