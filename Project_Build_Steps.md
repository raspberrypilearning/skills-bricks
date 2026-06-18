# Project Build Steps

## What Has Happened So Far

- Created a shared Skill Brick structure: two A5 landscape sides, a Discover side, a Build side, use examples, code examples, component area, and wiring area.
- Added a shared stylesheet for the original bricks and a separate Pete stylesheet/template set.
- Built out the Pete brick folders using the `-Pete` suffix.
- Added an index page for the Pete bricks.
- Simplified the category model to two types: `Detect` and `Do`.
- Added two colour-theme hooks for the Pete bricks: `theme-detect` and `theme-do`.
- Added first-use images for the Pete bricks.
- Added second-use images for the Pete bricks.
- Merged the Pete branch back with `master`, keeping both the original files and the Pete-suffixed versions.
- Removed merge conflicts caused by renamed folders, renamed templates, and renamed example assets.
- Identified that `skill-brick.css` now uses a Code Club brand-token styling approach.
- Checked that `skill-brick-Pete.css` should use the same brand approach, but must keep the Pete-specific index styles and Detect/Do theme hooks.

## What Needs To Happen Next

- Create Fritzing files for each wiring diagram, then use those files to create screenshots for the bricks.
- Add an image of each component to the component image area.
- Use the component images already in this repo where possible, but first check they are up to date against: <https://github.com/raspberrypilearning/components/tree/master/components>.
- Check that the labels and information under each component image actually match that component.
- Check that each `Decide` box contains the decision that needs to be made for that specific example.
- Update `skill-brick-Pete.css` to match the Code Club brand styling approach used in `skill-brick.css`, while preserving Pete-specific index styles and `theme-detect` / `theme-do`.
- Check that the text under the code examples uses inline code snippet formatting for references to methods, properties, variables, and code values.
