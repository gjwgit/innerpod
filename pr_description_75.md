## Pull Request Details

### Title
feat: add explicit login/logout and key buttons in app bar (#75)

### Description
This PR addresses issue #75 by replacing the `SolidDynamicAuthButton` in the main app bar with dedicated, explicit buttons for user authentication and security key management.

#### Key Enhancements:
- **Authentication Toggle**: Replaced the dynamic button with conditional `IconButton`s:
  - `Icons.login` appears when the user is not authenticated.
  - `Icons.logout` appears when the user is logged into their Solid server.
- **Reactive State Management**: Implemented a `FutureBuilder` to efficiently handle the asynchronous check of `isUserLoggedIn()`, ensuring the UI reflects the current session status immediately.
- **Key Management**: Added a persistent `Icons.key` button in the AppBar actions. This button triggers the `SolidSecurityKeyManager` popup, allowing users to view or change their pod encryption keys easily.
- **Improved UX**: Integrated `SolidPopupLogin` for a streamlined login experience and `logoutPopup` for a safe logout flow, providing users with clear visual feedback for their session status.

### Related Issues
Closes #75

### Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [x] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] This change requires a documentation update

### How To Test?
1. Open InnerPod.
2. Observe the Login icon button in the AppBar.
3. Tap Login and complete the Solid Auth flow.
4. Verify the icon changes to Logout.
5. Tap the Key icon to verify the Security Key Manager popup appears.
6. Tap Logout to verify the session ends and the icon reverts to Login.

### Checklist
- [x] Changes adhere to the [style and coding guidelines](https://survivor.togaware.com/gnulinux/flutter-style.html)
- [x] I have performed a self-review of my code
- [x] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [x] No lint check errors are related to these changes (`flutter analyze`)
- [x] All tests passed (`flutter test`)
- [x] Verified on Windows and verified logic consistency for other platforms.
