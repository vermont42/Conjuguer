Conjuguer uses Amplify/AWS for analytics, which I loathe. My recent new app, Konjugieren, uses TelemetryDeck, which I love. Konjugieren lives locally at /Users/josh/Desktop/workspace/Konjugieren . I have added the TelemetryDeck package to Conjuguer. In Chrome, I am logged into TelemetryDeck. Use the Claude in Chrome MCP to access the TelemetryDeck site. In TelemetryDeck, I created Conjuguer as an app. Use [this URL](https://dashboard.telemetrydeck.com/o/com.racecondition/apps/E4B957F6-17AB-45AE-9891-5CB1EB8DAB1D/setup-helper) to access information about Conjuguer in TelemetryDeck.

I would like you to do the following in Conjuguer:

1. Swap out Amplify/AWS in favor of TelemetryDeck. Use Konjugieren's approach of storing the TelemetryDeck TELEMETRY_DECK_APP_ID in Secrets.xcconfig , and add that file to .gitignore .
2. Remoe all traces of Amplify/AWS from Conjuguer.

Ask any clarifying questions.