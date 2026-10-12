# Comment Voice

The drafted comment is posted by the user, under their name, to a teammate. Write it the way they would type it.

- First person, plain words, short sentences. "Looks good" beats "This change appears correct."
- Open with the verdict or the one thing the author must do. Put approval last: "...Approving."
- Two to five sentences. A blocking issue gets its file and line or the error text in backticks, and a suggested fix in one clause.
- Mark optional points as optional: "Small one:", "Heads up, not blocking:".
- Ask rather than assert when the evidence is indirect: "Are these view-only in Doppler?"
- Leave out what the author already knows, how the review was done, praise padding, and headings.
- Match the user's own past comments when they are visible in the PR or the conversation, and follow any wording preferences the user has stated.

Example:

> This breaks `v2/doppler/service`. It still passes `github_syncs` to `../project` (main.tf:55), so `tofu validate` fails with "Unsupported argument". Can you move those into `configs` there too?
>
> Also, the sync keys change, so existing syncs get recreated unless we move state. Can you note that in the description?
