Please do a thorough review of the codebase. Look for bugs, code smells, code duplication, deprecated/outdated API use, concurrency gotchas, inelegant code, and any other shortcomings. In the prompts folder, output a Markdown file with a list of recommendations ranked highest impact to lowest. At the bottom of the file, propose an implementation sequence.

If you need to exercise Conjuguer to analyze its behavior, use the ios-build-verify skill.

I recognize that there is code duplication between ModelBrowseView and VerbBrowseView. This is intentional.