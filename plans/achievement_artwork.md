# Achievement Artwork Prompts

**For:** the `gpt-image` skill (`gpt-image-2.5-sunburst`, high quality, 1:1 at 1K, so 1024 × 1024,
opaque, two drafts each). **Written:** 2026-11-24, for the nine Game Center achievements that
pedagogy Phase 23 built ([`pedagogy_implementation.md`](pedagogy_implementation.md#phase-23-personal-bests-and-achievements)).
The achievements, their IDs, and their names are in
[`../docs/game_center_setup.md`](../docs/game_center_setup.md#the-achievements).

Every prompt is the shared preamble followed by its motif. The preamble names Conjuguer's palette,
the color sets of `Conjuguer/Assets/Assets.xcassets`, by their hex values, as Josh decided for
Konjugieren on 2026-11-13: `customBackground` #0A080C (dark) and #F4FFFD (light), `customSurface`
#1D1C1F and #E8F3F1, `customBlue` and `AccentColor` #304D6D and #7FA2C7, `customRed` #ED254E and
#F36884, `customGray` #726C89 and #9490A8. `customForeground` is the background's opposite, and
`customGreen` (#2E7D4F, #6FBF8E) is left out, since it means "right answer" in the app. The red is
the app's mark for an irregular letter, so the badges use it for what is irregular or crowning.

The themes follow Konjugieren's: the patterns build a stone arch, here a French Gothic one, course
by course to its keystone (la clé de voûte); the irregular verbs are columns and numbered shields;
the être verbs are the maison d'être that French schools draw.

## Preamble

> A Game Center achievement badge on a square 1024 × 1024 canvas, opaque. One round medallion,
> centered, filling about 90% of the canvas, with everything important inside the middle 80%,
> because Game Center crops the image to a circle. Refined flat vector illustration with subtle
> bevels and soft shading, like a minted enamel medal. No words or letters anywhere. Use only this
> palette: the canvas outside the medallion near-black #0A080C; the medallion's face deep charcoal
> #1D1C1F; its rim slate blue #304D6D with a thin inner ring of light slate #7FA2C7; stone and line
> work in light slate #7FA2C7 and gray-violet #726C89 and #9490A8; highlights and glints mint white
> #F4FFFD; a single accent of rose red #ED254E, with #F36884 for its highlight. No other hues, no
> gold, no green. Motif:

## Motifs

1. **Premières pierres** (`patterns.beginner`): three dressed stone blocks laid side by side as
   the first course of a foundation, on a thin line of ground, a mason's chisel resting beside
   them. Calm and simple.
2. **Les murs** (`patterns.elementary`): a stone wall of five or six courses rising from the same
   foundation, with a narrow pointed window opening in it, the courses neatly offset.
3. **La voûte** (`patterns.intermediate`): a tall pointed Gothic arch of fitted voussoirs springing
   from two piers, complete except for the single stone at its crown, which is missing and leaves
   a small gap at the top.
4. **La clé de voûte** (`patterns.advanced`): the same pointed Gothic arch, now complete, its
   keystone at the crown in rose red #ED254E with a #F36884 glint, a few rays of mint white light
   behind it.
5. **Les piliers** (`verbs.pillars`): eight slender stone columns in a row, carrying a plain
   entablature, seen from the front, the middle two a little taller. One rose red band at each
   column's capital.
6. **Dix irréguliers** (`verbs.core10`): a heraldic shield in light slate stone with the numeral
   10 in rose red #ED254E at its center, one column on either side of the shield.
7. **Vingt-cinq irréguliers** (`verbs.core25`): the same shield with the numeral 25 in rose red,
   framed by two columns and an arch over the shield.
8. **Cinquante irréguliers** (`verbs.core50`): the same shield with the numeral 50 in rose red,
   framed by columns and an arch, and encircled by a laurel wreath in light slate and mint white.
9. **La maison d'être** (`etre`): a small French townhouse facade, two stories, a mansard roof, a
   flight of steps up to its door, which stands open and is rose red #ED254E. A curved arrow goes
   up the steps into the door and another comes out and down, in mint white.

## Drafts

`generate_image.py --api -m gpt-image-2.5-sunburst -q high -a 1:1 -s 1K -b opaque -n 2 --file
<preamble + motif> -o achievement_<n>.png`. The eighteen drafts, `achievement_<n>-<1|2>.png`, and
two contact sheets are in [`achievement_artwork_drafts/`](achievement_artwork_drafts/), which git
ignores. Josh left the pick to Claude on 2026-11-24, which took draft 1 of each; those became
JPEGs at quality 92 in `Images/achievements/` and went to App Store Connect.
