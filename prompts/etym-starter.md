My German-verb app, Konjugieren, lives at this location: /Users/josh/Desktop/workspace/Konjugieren

Konjugieren has a feature whereby its VerbView shows an etymology for all 990 verbs in that app. The etymologies themselves live in Konjugieren/Models/Etymologies.json . I did not put the etymologies themseleves into Konjugieren's Verbs.xml because I didn't want to bloat that file.

I would like to add the same feature to Conjuguer for verbs ranked 1 to 981 in terms of usage, plus select verbs like ester and gésir. This will involve the following steps:

1. Add to Conjuguer's VerbView, below the conjugations, UI for showing etymology, if available. This UI will be powered by a new model file, Conjuguer/Models/Etymology.swift . Konjugieren has that file. For now, Conjuguer's Etymology.swift should be hard-coded with the etymology for ester .
2. Build a workflow (prompt) for gathering French etymologies and putting them into a new Conjuguer file, Conjuguer/Models/Etymologies.json . This workflow will be similar to Konjugieren/etymology-pipeline.md . The workflow should tell subagents to use ~~ to bold relevant words and to use passé simple rather than passé composé.
3. Repeatedly run Conjuguer/prompts/etymology-pipeline.md , across multiple sessions, until verbs 1-981 have etymologies.
4. Modify Etymology.swift so that it gets etymologies from Etymologies.json .