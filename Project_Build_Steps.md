# Project Build Steps

## What Has Happened So Far

- Created a shared Skill Brick structure: two A5 landscape sides, a Discover side, a Build side, use examples, code examples, component area, and wiring area.
- Added a shared stylesheet and a separate Pete template set.
- Built out the Pete brick folders using the `-Pete` suffix.
- Added an index page for the Pete bricks.
- Simplified the category model to two types: `Detect` and `Do`.
- Added two colour-theme hooks for the Pete bricks: `theme-detect` and `theme-do`.
- Added first-use images for the Pete bricks.
- Added second-use images for the Pete bricks.
- Merged the Pete branch back with `master`, keeping both the original files and the Pete-suffixed versions.
- Removed merge conflicts caused by renamed folders, renamed templates, and renamed example assets.
- Identified that `skill-brick.css` now uses a Code Club brand-token styling approach.
- Moved the Pete-specific index styles and Detect/Do theme hooks into `skill-brick.css` so all bricks can use one stylesheet.
- Agreed not to edit files in `microbit/` while that folder is being worked on separately.
- Checked the Raspberry Pi Learning component image repo at commit `0102235420fd8b9f07a66c6a7e30db89a6d34a50`.
- Added current component-repo PNGs where there was a clear match: LED, button, buzzer, LDR, ultrasonic distance sensor, temperature probe, motor controller, PIR, NeoPixel, and speaker.
- Added local component SVGs where the component repo did not have a matching image: capacitive touch sensor, RGB LED, potentiometer, stepper motor, tilt switch, toggle switch, and line sensor.
- Checked and tightened the labels under the component images so they describe the component shown, not unrelated circuit or code details.
- Checked the notes under the code examples and wrapped method, property, variable, and code-value references in inline code formatting.

## What Needs To Happen Next

- Create Fritzing files for each wiring diagram, then use those files to create screenshots for the bricks.
- Check that each `Decide` box contains the decision that needs to be made for that specific example.
- Review the Pete pages after switching them to the shared `skill-brick.css`, especially the index cards and Detect/Do category cues.
