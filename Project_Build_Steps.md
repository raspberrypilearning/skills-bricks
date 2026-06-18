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
- Replaced the separate Pete index with the main `index.html` catalogue for non-`microbit` bricks.
- Updated `index.html` to link all non-`microbit` brick pages, with a `Current Set` section and an `Other Versions To Compare` section.
- Added shared index section styling to `skill-brick.css` so the catalogue can show current and comparison cards clearly.
- Checked the `Decide` boxes and tightened the ones that did not clearly state the choice needed for the example.

## What Needs To Happen Next

- Create Fritzing files for each wiring diagram, then use those files to create screenshots for the bricks.
- Check through any duplicates with the team to decide which alternate approaches should stay, change, or be removed.
