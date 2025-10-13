# 0.4.0

- Fixed GitHub Actions test report workflow failing on forked PRs due to permission and authentication restrictions.

### BREAKING CHANGES
- Compatible with flutter version `v3.32.8`

# 0.3.3

- Fix for _scrollToVisible throwing error [#51](https://github.com/dab246/super_tag_editor/pull/51)
- Support previous/next arrow key for change focus tags
- Upgrade flutter version to v3.27.4
- Update to `actions/download-artifact@v4` to fix deprecation error

# 0.3.2

- Fix the suggestion list always displays on top when there is still space below
- Compatible with flutter version `v3.24.5`
- Upgrade kotlin version to `v1.7.10`
- Bumped versions of deprecated actions

# 0.3.1

- Support `LoadMore` for `SuggestionsBox` by mouse or keyboard

# 0.3.0

- Compatible with flutter version `v3.22.2`

# 0.2.0

- Compatible with flutter version `v3.10.6`

# 0.1.3

- Support RTL mode

# 0.1.2

- Fix tap event is not simulated in a overlay on Flutter `3.7.x` for Web/Desktop (Regression)

# 0.1.1

- Tap event is not simulated in a overlay on Flutter version `3.7.x`

# 0.1.0

- Fix bugs
- Auto focus latest tag after `delete` tag
- Added `border radius` for suggestion box

### BREAKING CHANGES
- Support `validation` 
- Compatible with flutter version `v3.7.5` 

# 0.0.3+4

- Support press `keyboard` to `Delete` tag and `Move`, `Select` suggestion item

# 0.0.3+3

- Enable/Disable auto dispose `FocusNode`

# 0.0.3+2

- Add `margin` for suggestion box

# 0.0.3+1

- Add `padding` for suggestion box

# 0.0.3

- Customize style tag input: `background`, `border`, `cursor`

# 0.0.2

- Support `activated/deactivated` for suggestion box
- Format code to match the Dart formatter

# 0.0.1

- First release