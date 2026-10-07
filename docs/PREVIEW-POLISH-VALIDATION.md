# Unpublished preview and editor polish

This follow-up remains private and unreleased. It changes editor layout and previews; the beta.4 release metadata still describes the earlier draft archive.

The native regression fixture `tests/native/MutPreviewPolishTest.uc` covers full-screen Save button spacing, enabled sorting defaults, independent duplicate names, selected-mount restore with camera preservation, exact profile weapon previews, refresh after returning from tuning, and cursor bounds. A private authenticated Xvfb runner uses real XTest pointer motion for hover evidence. Screenshots require separate inspection.

The comparison base is `5727c3df0ca578f155694c8a272a6da64ccc0f32`. Candidate commit, archive and package SHA-256 values, ignored backend inputs, test results, independent review and installation evidence are recorded in the private candidate directory. Portable CI checks public source fixtures and metadata; it does not compile private backends, validate native gameplay or authorize publication.

User gameplay confirmation remains a separate step. Native Windows and Steam/Proton support have not been validated; support for Steam/Proton is not guaranteed.
