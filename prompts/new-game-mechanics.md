# Five New Mechanics for the Arc de Triomphe Minigame

Design suggestions to de-blandify Conjuguer's minigame. Each mechanic is drawn
from **(a)** a mechanic already proven in the sibling app *Konjugieren*'s minigame
(so there's working reference code to port) and **(b)** a classic 1980s arcade
game. Every mechanic stays inside the existing French theme, names the exact
emojis to render, and specifies sounds — reusing what Conjuguer already bundles
wherever possible, borrowing from Konjugieren otherwise, and describing a brand‑new
sound only when neither app has a fit.

---

## Where the game is today (baseline)

So a fresh session has context without re-reading the code:

- **Type:** vertical shooter. Player = the Arc de Triomphe (`ArcDeTriompheIconPreview`),
  bottom-anchored, moves left/right via on-screen arrows (wraps around the screen
  edges), tap the right half of the screen to fire.
- **Bullet:** 🇫🇷 fired straight up (`GameState.fire()`).
- **Enemies (`Target`):** rooster (`RoosterIconPreview`), croissant
  (`CroissantIconPreview`), beret (`BeretIconPreview`). They **only fall straight
  down** at a constant `scrollSpeed`. Spawn every `spawnInterval` (0.7 s).
- **Enemy fire:** 🏴󠁧󠁢󠁥󠁮󠁧󠁿 (England flag) — the top-half enemy nearest the player aims at it every 6 s.
- **Drops (`Drop`):** 🥖 baguette (+25 % health), 🍇 grape (5 s autofire), 🧀 cheese (6 s shield).
- **Feel:** 8-particle red/blue death burst, scrolling stars, `score += 5` per kill,
  4-hit health bar, game over + high score.

The core weakness: **enemies have exactly one behavior (fall straight down).** Four
of the five mechanics below add *new kinds of motion and threat*; the fifth adds a
*climax*.

### Implementation hooks you'll reuse (all in `Conjuguer/Models/Game/`)

| You want… | Mirror this existing code |
|---|---|
| A new falling collectible | `Drop` struct + `updateDrops` / `collectDrops` / `spawnDrop` |
| A new enemy with custom motion | `Target` + `updateTargets`; add per-entity state fields |
| Anything that moves on a 2-D velocity & bounces | `EnemyBullet` (`velocityX`/`velocityY`) + the wall checks in `updateEnemyBullets` |
| A timed power-up state | `shieldTimer` / `autofireTimer` + `updateShieldAndAutofire` |
| Collision | `GameState.intersects(a:aSize:b:bSize:)` (AABB) |
| Score / sound / haptic / particles | `scorePerKill`, `Current.soundPlayer.play(_:shouldDebounce:volume:)`, `HapticPlayer.playImpact(_:)`, `DeathEffect` |

---

## 1. La Patrouille de France — dive-bombers

**80s game:** *Galaga* / *Galaxian* (enemies break formation and swoop down in arcs).
**Konjugieren lineage:** its **Dive Bomber** mechanic — every 24 s, 2–3 living
enemies peel off and fly a parabolic arc to the bottom, scaling 1.3×, worth a 2×
kill bonus.

**How it plays.** Periodically (say every ~12 s) one of the existing on-screen
enemies stops its straight fall and instead **swoops** in a sine-modulated parabola
toward the player's current column, then either exits the bottom or loops back up.
A diving enemy that grazes the player deals the normal 25 % hit, but killing one
*mid-dive* scores **double** (the Galaga captured-fighter thrill) and the diver
scales up to 1.3× so it reads as "charged." Telegraph the dive ~0.5 s early with a
warning glyph in the target column so it feels fair, not cheap.

- **Emojis / art:** keep the enemy's own asset (rooster/croissant/beret) for the
  diver. Telegraph with **⚠️** at the dive's target column. Optional flair: a short
  **🔵 ⚪ 🔴** Tricolore "smoke" trail behind the diver (three small color circles,
  fading — reuse the `DeathEffect` particle pattern).
- **Sounds:**
  - Dive launch → **`buzz`** 🟢 *(already bundled in Conjuguer)* — an angry, fast
    "charge" buzz reads well for a swoop. *Optional upgrade:* a new **`swoop.mp3`**
    🔴 — a quick 0.3–0.4 s descending whistle/whoosh (think falling dive-bomber).
  - 2× "ace" kill → **`randomGun`** (`gun1`/`gun2`) 🟢 *(bundled, currently unused
    by the game)* — a punchy report distinct from the normal `chomp` kill, so the
    bonus *sounds* special.
- **Haptics:** `.heavy` on a mid-dive kill (vs `.medium` for a normal kill).
- **Implementation note:** add `diveProgress`/`isDiving`/`homeX` fields to `Target`;
  branch in `updateTargets` between straight-fall and the dive arc
  (`x = homeX + amplitude·sin(t·π·4)`, `y` interpolated downward).

---

## 2. Le Ballon des Bleus — the bouncing ball

**80s game:** *Breakout* / *Arkanoid* (a ball ricochets and clears bricks), with a
dash of *Pong*.
**Konjugieren lineage:** its **Fussball** ⚽ special — a ball bounces off all four
walls, speeding up 1.08× per bounce, killing any enemy it touches, hurting the
player on contact, and deflectable by the player's own bullets.

**How it plays.** Every so often a **⚽** enters from the top and ricochets around
the arena. It treats the descending enemies like Breakout bricks — each enemy it
strikes is destroyed (+score, maybe drops a power-up) and the ball bounces off,
gaining speed. It **damages the player** on contact (no shield protection, to keep
it scary), and the player can **re-aim it** by shooting it (a bullet hit randomizes
its horizontal velocity ±80). It self-expires after ~15 s or when it leaves the
field. This single entity injects fast, unpredictable motion the current game
completely lacks.

- **Emojis / art:** **⚽** (Les Bleus / World-Cup ball). *French alt skin:* a
  **pétanque boule** rendered as **⚪** (a steel ball), if you prefer *boules* over
  football.
- **Sounds:**
  - Kick / bounce off an enemy or wall → **`soccerKick`** 🟡 *(port the mp3 from
    Konjugieren; add a `soccerKick` enum case)*. *Boule alt:* a new **`clang.mp3`**
    🔴 — a short metallic "tonk" for steel-on-steel.
  - Ball strikes the player → **`playerHit`** 🟡 *(port from Konjugieren)*, or reuse
    Conjuguer's **`enemyFire`** 🟢 as a stand-in thud.
- **Haptics:** `.medium` on each bounce, `.heavy` when it hits the player.
- **Implementation note:** it's an `EnemyBullet` that *reflects* instead of being
  removed at the walls — copy `updateEnemyBullets`' bounds checks but negate the
  velocity component and multiply speed by 1.08 instead of `removeAll`.

---

## 3. Le Fantôme de l'Opéra — the ghost hunt

**80s game:** *Pac-Man* (chasing ghosts + a power pellet that flips them to edible
and fleeing).
**Konjugieren lineage:** its **Geisterstunde** ("ghost hour") — ghosts descend
dropping golden dots and chasing the player; shooting a 🔮 crystal ball triggers
"Geisterjagd," turning every ghost frightened (😱) and fleeing, so the player can
devour them (💨) for big points.

**How it plays.** 2–3 **👻** drift down from the Palais Garnier, dropping a trail of
**musical-note dots 🎵** (collect for small points — the Pac-Man maze dots). On
reaching the player's row they switch to **chasing** horizontally. Floating among
them is the Opéra's **chandelier 🔮** (or a theatre **🎭** mask): shoot it to flip
every ghost to **😱 fright mode** for 5 s — now they flee, and touching one
**devours** it (**💨**) for a fat bonus. Ignored ghosts eventually exit the top.
This adds a risk/reward inversion (hunter ↔ hunted) the game has never had.

- **Emojis / art:** **👻** (descending/chasing), **😱** (frightened/fleeing),
  **💨** (devoured), **🔮** power item *(or **🎭** for stronger Opéra flavor)*,
  **🎵** dropped dots.
- **Sounds** — *this one is cheap, because Conjuguer already owns three of the four:*
  - Ghosts appear → **`ghostSpooky`** 🟡 *(port from Konjugieren)*.
  - Dot pickup → **`chirp`** 🟢 *(bundled, unused by the game)* — a perfect short
    "blip."
  - Fright mode activates → **`magicActivate`** 🟡 *(port)*, or reuse
    **`shieldActivate`** 🟢 as a stand-in.
  - Devour a fleeing ghost → **`chomp`** 🟢 *(already bundled & used for kills)* —
    on-the-nose for eating a ghost.
- **Haptics:** `.light` per dot, `.medium` on activating fright mode, `.medium` on
  a devour.
- **Implementation note:** ghosts are `Target`s with a `phase` enum (descending /
  chasing / fleeing / devoured); the dots and the 🔮 are `Drop`-like fallers; fright
  mode is a `shieldTimer`-style countdown that swaps the collision outcome.

---

## 4. La Basse-Cour — eggs & hatchlings

**80s game:** *Frogger* / *Joust* (threats that cross horizontally and that *hatch*
into new pursuers).
**Konjugieren lineage:** its **Zigzagger** chain — a farm animal traverses the
screen dropping coins, and a shot one leaves an **egg 🥚** that bounces, then
**hatches 🐣** into a hatchling that chases the player.

**How it plays.** A **hen 🐔** waddles across the screen horizontally (distinct from
the vertical **rooster 🐓** enemy — *la poule* vs *le coq*), zig-zagging and laying
**🥚 eggs** that fall and bounce with gravity. Each egg, if not shot, **hatches into
a 🐣 poussin** that chases the player along the ground and costs health on contact —
so the player must clear eggs *before* they hatch. Shooting the hen, an egg, or a
chick all score. This introduces a threat that approaches **from the side and below**,
breaking the "everything comes from the top" monotony.

- **Emojis / art:** **🐔** (hen, horizontal crosser), **🥚** (bouncing egg),
  **🐣** (chasing hatchling).
- **Sounds:**
  - Hen lays / clucks → a new **`cluck.mp3`** 🔴 — a single hen cluck/squawk.
    *(Note: Konjugieren has horse/pig/sheep/goat/cow sounds but **no chicken**, so
    this is a genuine gap. Cheap fallback: reuse **`chirp`** 🟢 for the chick instead.)*
  - Egg hatches → **`eggCrack`** 🟡 *(port from Konjugieren)*.
  - Shoot hen/egg/chick → existing **`pop`**/**`chomp`** 🟢.
  - Egg or hen collected/cleared cleanly → **`chime`** 🟢 *(bundled, unused by the game)*.
- **Haptics:** `.light` on a clear, `.heavy` when a hatchling reaches the player.
- **Implementation note:** the hen is a horizontally-moving `Target`; eggs reuse the
  `Drop` faller plus a bounce (restitution ~0.6) and a `hatchTimer`; a hatched chick
  is a ground-level chaser that lerps its `x` toward `playerX`.

---

## 5. Goldorak — the converter robot mini-boss

**80s game:** the **mothership / boss fight** (the *Space Invaders* UFO, *Galaga*
boss-Galaga). The French hook: **Goldorak** (*UFO Robot Grendizer*) was a colossal
1980s French-TV phenomenon — an instantly-recognizable giant robot, so the
robot-head emoji lands as both an 80s *and* a French reference.
**Konjugieren lineage:** its **Robot** special — a brain **🧠** ascends, locks onto
an enemy (**⚡** targeting bolt), and **converts** it into an armored robot minion
**🤖** flanked by destructible arms **🦾**, firing high-speed colored-rectangle
bullets.

**How it plays.** Once the player crosses a score threshold, a **🧠 brain-core**
appears and drifts, then **locks onto** one of the on-screen enemies (telegraphed by
a charging **⚡**) and **converts** it into a **🤖 robot minion** with two **🦾**
arms. The arms must be shot off (left/right hit zones) before the body is
vulnerable; the minion periodically dive-bombs and fires fast **colored-rectangle
bullets** (not emoji — alternate red/yellow, 2× bullet speed). Defeating the whole
unit is a genuine climax that ends with a reward shower of drops. This is the
multi-hit, multi-phase **boss** the game currently lacks.

- **Emojis / art:** **🧠** (brain-core), **⚡** (lock-on bolt), **🤖** (robot minion
  body), **🦾** (its two arms). The robot's bullets are drawn as small red/yellow
  rectangles, not emoji.
- **Sounds** — *all already exist in Konjugieren; port the four mp3s:*
  - Lock-on / dive start → **`brainLockOn`** 🟡.
  - Conversion completes → **`brainConvert`** 🟡.
  - Robot fires → **`robotWeapon`** 🟡.
  - **Boss defeated** → **`randomApplause`** (`applause1`–`applause3`) 🟢 *(bundled
    in Conjuguer, currently unused by the game)* — the perfect victory payoff, and
    it costs zero new assets.
- **Haptics:** `.heavy` on conversion and on the final kill; `.medium` per arm shot off.
- **Implementation note:** a new `RobotBoss` struct with `hitsRemaining` and a
  `phase` (ascending / lockedOn / converting / fighting); reuse the dive arc from
  Mechanic 1 for its bombing runs. Because there's no wave system yet, gate it on a
  score threshold rather than a wave number.

---

## Mix-and-match extras (cheap, classic, optional)

Small 80s touches that layer onto any of the above using sounds already on hand:

- **Combo multiplier.** Chain kills within a short window for ×2/×3 score; pitch the
  pickup blip up each step. (Reuse `chirp`/`chime` 🟢.)
- **Bonus UFO.** A *Space Invaders*–style mystery saucer streaks across the very top
  every so often for big points if you tag it. Skin it as a **🎈 Montgolfière**
  (the Montgolfier brothers — French ballooning) for theme. Sound: `randomGun` 🟢.
- **Screen shake** on the Mechanic-5 boss conversion/defeat (offset the `ZStack` a
  few points for ~0.2 s) — huge perceived-impact for ~5 lines.
- **"Encore!" wave clear.** When the field is briefly emptied, flash a banner and
  play `randomApplause` 🟢 before the next swarm.

---

## Sound sourcing appendix

Legend for the per-mechanic markers above:

- 🟢 **In Conjuguer already** — the mp3 is bundled (some are used elsewhere, e.g. the
  quiz uses `chime`/`buzz`/`applause`); reusing it in the game costs **zero new
  assets**. *Currently unused by the minigame:* `buzz`, `chirp`, `chime`, `gun1`,
  `gun2` (`randomGun`), `applause1`–`applause3` (`randomApplause`). *Already used by
  the minigame and freely reusable:* `pop`, `chomp`, `enemyFire`, `shieldActivate`,
  `longFire1`–`3` (`randomLongFire`).
- 🟡 **Port from Konjugieren** — the mp3 exists in
  `Konjugieren/Konjugieren/Assets/Sounds/`; copy the file into
  `Conjuguer/Assets/Sounds/` and add the matching `case` to `Sound.swift`. Needed:
  `soccerKick`, `playerHit`, `ghostSpooky`, `magicActivate`, `eggCrack`,
  `brainLockOn`, `brainConvert`, `robotWeapon`. *(Konjugieren also has `coin`,
  `sizzle`, and animal sounds `horse`/`pig`/`sheep`/`goat`/`cow` if you extend these
  ideas.)*
- 🔴 **New sound to source** — neither app has it; description for you to find/record:
  - **`swoop.mp3`** *(Mechanic 1, optional)* — a quick 0.3–0.4 s descending
    whistle/whoosh, like a falling dive-bomber.
  - **`clang.mp3`** *(Mechanic 2, only for the pétanque-boule skin)* — a short,
    bright metallic "tonk" of steel ball on steel ball.
  - **`cluck.mp3`** *(Mechanic 4)* — a single hen cluck/squawk (fallback: reuse the
    bundled `chirp` 🟢 for the chick instead, and skip this).

## Emoji caveats

- There is **no Eiffel Tower emoji** — 🗼 is Tokyo Tower. For French-flag color
  accents use the circle trio **🔵 ⚪ 🔴** (the actual flag is the existing 🇫🇷
  bullet).
- 🐓 (rooster, *le coq*) and 🐔 (hen, *la poule*) are deliberately used as **two
  different** entities — keep them visually distinct.
- The robot set 🧠 / 🤖 / 🦾 and the ghost set 👻 / 😱 / 💨 each render consistently
  across iOS versions; the chick lifecycle 🥚 → 🐣 reads clearly at the game's sprite size.
