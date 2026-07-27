# Script and Playbook for iOS App Store Previews

Ensure that videos are exactly 32 seconds *without* transitions. There are 5 clips, so 4 half-second transitions between them shrink the length by two seconds, to 30. (FCP's default transition duration is 1 second; this assumes it has been set to 0.5 second in Settings ▸ Editing.)

## App Store preview specifications

Sizes, which are **not** the screenshot sizes — conflating the two got all four of
Conjuguer's 2.0 previews rejected with *"The app preview dimensions should be:
886 × 1920px or 1920 × 886px"*:

| Device | Preview size | Notes |
|---|---|---|
| iPhone | **886 × 1920** | One file serves *every* current iPhone class (6.9″, 6.5″, 6.3″, 6.1″). |
| iPad | **1200 × 1600** | Covers 13″, 12.9″, 11″, 10.5″. |

Record at native simulator resolution and let the Final Cut project scale down; the project resolution is what gets
delivered.

Verify before uploading:

```bash
scripts/verify_store_media.sh ~/Desktop/Final/Conjuguer
```

First Clip - six seconds
Starts out at top of VerbBrowseView. Sort by frequency. Slowly scroll down for five seconds.
Label:
6,320 French verbs — from abaisser to zyeuter, sorted alphabetically or by frequency.
6 320 verbes français — d’abaisser à zyeuter, classés par ordre alphabétique ou par fréquence.

Second Clip - six seconds
"Show Compound Tenses" is selected. Starts out at top of être's VerbView. Slowly scroll down for five seconds.
Label:
Every conjugation of every verb — seventeen tenses at a glance.
Toutes les conjugaisons de chaque verbe — dix-sept temps d’un seul coup d’œil.

Third Clip - six seconds
Starts out on ModelBrowseView. Wait two seconds. Tap avoir. Wait one second. Slowly scroll down for three seconds.
Label:
All 95 French conjugation models.
Les 95 modèles de conjugaison du français.

Fourth Clip - seven seconds
Starts out on QuizView. Start. Type answer. Submit. Repeat once.
Label:
Quiz mode: Thirty timed questions to sharpen your conjugation skills.
Mode quiz : trente questions chronométrées pour aiguiser vos talents de conjugaison.

Fifth Clip - seven seconds
Starts out at top of InfoBrowseView. Scroll down so that Indicatif Présent is centered. Tap it. Slowly scroll down.
Label:
Everything you need to know about every tense.
Tout ce qu’il faut savoir sur chaque temps.
