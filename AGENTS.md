# Skill Brick Authoring Notes

Use these notes when creating or updating skill brick HTML files in this repo.

- Keep each brick consistent with `skill_brick_template-Pete.html`: two A5 landscape sides, a Discover side, and a Build side.
- Put each brick in its own top-level folder, using the component name with a `-Pete` suffix, such as `Temp_Sensor-Pete`.
- Use the shared `skill-brick-Pete.css` stylesheet for layout, print sizing, cards, placeholders, code blocks, and wiring sections.
- Link component-folder HTML files to `../skill-brick-Pete.css`; link root-level files to `skill-brick-Pete.css`.
- Use `theme-detect` for Detect bricks and `theme-do` for Do bricks. Do not create extra colour schemes unless the set needs a new category.
- In the Uses section, make the first use a standard, well-known real-world use of the component.
- Make the second use more creative, wacky, fun, silly, or deliberately pointless so it inspires kids to imagine their own projects.
- Keep each use in the Detect -> Decide -> Do pattern.
- Keep visible wording maker-led and playful. Avoid introducing bricks with formal curriculum language such as "review", "learning objective", "lesson", or "activity".
- In code notes, avoid phrases like "Do code" or "Decide code". For Do bricks, it is fine to say the command can be used "after a Detect brick spots something".
- Use image placeholders until a use image is ready. First-use images can be added when available; second-use placeholders are fine for now.
- Do not worry about final Fritzing-style wiring diagrams at this stage. Placeholder boxes are fine.
- Keep wording short, concrete, and friendly for young learners.
