# Pull Request Details

## What issue does this PR address

- Fixes an issue where unselected "SELECT DURATION" choice chip buttons were unreadable due to low contrast. Colors are now properly adjusted for both light and dark mode themes.
- Also extracts `PremiumTextField` into its own widget to fix the `locmax` lint issue where `timer.dart` was exceeding the 300 LOC limit.

## Associated Issue

- This PR relates to issue #

## Type of Change

- [x] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] This change requires a documentation update

## How Has This Been Tested?

Verified UI locally in both light mode and dark mode. Ran unit tests via `flutter test` and verified formatting with `make prep` / `flutter analyze`.

## Checklist

- [ ] Screenshots included in linked issue #
- [x] Changes adhere to the [style and coding guidelines](https://survivor.togaware.com/gnulinux/flutter-style.html)
- [x] I have performed a self-review of my code
- [x] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] Any dependent changes have been merged and published in downstream modules
- [x] The update contains no confidential information
- [x] The update has no duplicated content
- [x] No lint check errors are related to these changes (`make prep` or `flutter analyze lib`)
- [x] Integration test `dart test` output or screenshot included in issue #
- [x] I tested the PR on these devices:
  - [ ] Android
  - [ ] iOS
  - [ ] Linux
  - [ ] MacOS
  - [x] Windows
  - [ ] Web
- [ ] I have identified reviewers
- [ ] The PR has been approved by reviewers

## Finalising

Once PR discussion is complete and reviewers have approved:

- [ ] Merge dev into the this branch
- [ ] Resolve any conflicts
- [ ] Add a one line summary into the CHANGELOG.md
- [ ] Push to the git repository and review
- [ ] Merge the PR into dev
