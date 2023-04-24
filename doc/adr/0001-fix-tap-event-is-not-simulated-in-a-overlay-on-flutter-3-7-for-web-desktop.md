# 1. Fix tap event is not simulated in a overlay on Flutter 3.7 for Web/Desktop

Date: 2023-04-24

## Status

Accepted

## Context

Tap events are not being simulated to overlay on the `Web/Desktop` but work fine on mobile devices. This worked fine until the previous release stable 3.3.

## Root causes

Because the thing that the overlay is attached to is a `TextField`, so in order to keep from unfocused the text field when tapping outside of it, you need to tell the overlay widget that it's part of the TextField for purposes of the `tap outside` behavior by adding the `TextFieldTapRegion` around it, so that when the tap arrives, it's considered `inside` of the text field.

## Decision

Try wrapping a `TextFieldTapRegion` around the `Material` in the overlay.

## Consequences

This worked fine
