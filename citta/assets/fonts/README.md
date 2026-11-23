## Fonts

No font files are bundled at present. The `fonts:` block in `pubspec.yaml` is
commented out, and Flutter falls back to system fonts.

To bundle fonts for rendering Sanskrit/Devanagari text in the quotes, place
these here and uncomment the `pubspec.yaml` block:

### NotoSans (Latin)
- NotoSans-Regular.ttf
- NotoSans-Medium.ttf
- NotoSans-SemiBold.ttf
- NotoSans-Bold.ttf

### NotoSansDevanagari (Sanskrit/Hindi)
- NotoSansDevanagari-Regular.ttf
- NotoSansDevanagari-Medium.ttf

Download from: https://fonts.google.com/noto

Noto fonts are licensed under the SIL Open Font License 1.1 (`OFL-1.1`).
When adding them, also ship the OFL license text and add a row for each `.ttf`
to [`ASSETS_LICENSES.md`](../../ASSETS_LICENSES.md). The asset license test
fails otherwise.
