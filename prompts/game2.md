This prompt is about enhancing Conjuguer's recently created minigame. Some functionality and assets will be brought from Konjugieren and its minigame. Konjugieren lives here: /Users/josh/Desktop/workspace/Konjugieren

1. Score currently increases every second, apparently. Stop doing that. Instead, increase score by five points when an enemy is destroyed.
2. Bring Konjugieren's pop sound over and play that when the player fires.
3. There should be a sound when an enemy is hit. Bring Konjugieren's robotWeapon sound over and use that. Rename the sound to chomp.mp3 and trim the last 70% off end of the sound, which is silent.
4. Play Danse Macabre on loop, fading in at the beginning and starting at a random point. Repeat when the song finishes. The file is at ~/Desktop/DanseMacabre.mp3 . Konjugieren also plays a song in the minigame. Use Konjugieren's implementation.
5. When an enemy is hit, don't just make it disappear suddenly. Instead, over .5 second, have it shrink to zero size and fade to invisible. Also, show a particle effect over the enemy using Conjuguer red and blue.
6. Implement a health mechanic and label similar to Konjugieren's. Health starts at 100%. Each time an enemy strikes the player or an enemy bullet (see below) hits the player, decrease health by 25%. When health drops to zero, show a game-over screen showing score and a button to start another game.
7. Every three seconds, the enemy in the top half of the screen that is horizontally closest to the player fires an England-flag-emoji bullet at the player. Bring Konjugieren's chime sound over and play that when an enemy fires. Trim the last 70% off the end of the sound, which is silent.
8. When the player is hit, play haptic feedback.
9. Every 20 seconds, an enemy in the top half of the screen drops a baguette emoji towards the player. If the player catches it, the player's health is increased by 25%, to a maximum of 100%.
10. Every 25 seconds, an enemy in the top half of the screen drops a grape emoji towards the player. If the player catches it, the player autofires, as in Konjugieren. Bring Konjugieren's autofire sounds and sound mechanics over.
11. Every 30 seconds, an enemy in the top half of the screen drops a cheese emoji towards the player. If the player catches it, the player gets a temporary shield, as in Konjugieren. Bring Konjugieren's shield sound over.

Ask any questions before beginning work.