# Diamond Realty AI backend (development)

This folder contains the first **chat-only, owner-authenticated** Supabase Edge Function.
It does not have GitHub write tools, database mutation tools, phone calling, messaging,
deployment permissions, or autonomous code execution.

## Required secrets

Set these in Supabase Dashboard → Edge Functions → Secrets (do not commit values):

- `OPENAI_API_KEY`: OpenAI API key
- `OPENAI_MODEL`: a model ID enabled for your OpenAI API project
- `OWNER_USER_ID`: the Supabase Auth user UUID for the owner account
- `ALLOWED_ORIGIN`: exact website origin, e.g. `https://YOUR-GITHUB-USERNAME.github.io`

Supabase provides `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEYS` to hosted Edge Functions.
The function also supports the legacy `SUPABASE_ANON_KEY` environment variable.

## Before deployment

1. Confirm you can access the correct Supabase project.
2. Confirm the owner can sign in using Supabase Auth; obtain the owner's Auth user UUID from the dashboard.
3. Confirm the exact GitHub Pages origin from the browser address bar. Do not guess a custom domain.
4. Set the four secrets above in the Supabase project.
5. Deploy only this function, then test with an authenticated owner session.
6. Do not enable the chat UI until these checks pass.

## Deploy (owner-operated)

Install the Supabase CLI, authenticate locally, then from the repository root:

```sh
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy diamond-ai
```

Do not put access tokens, API keys, passwords, or `.env` files in GitHub.
Do not disable JWT verification to work around authentication errors.

## Request contract

POST to `/functions/v1/diamond-ai` with:
- `Authorization: Bearer <Supabase user access token>`
- `apikey: <Supabase publishable key>`
- JSON body: `{"message":"..."}`

Success response: `{"answer":"..."}`

The endpoint verifies the caller with Supabase Auth and compares the user UUID with
`OWNER_USER_ID`. It only accepts the exact `ALLOWED_ORIGIN`.

## Current limitations

- No persistent chat history.
- No rate-limit store yet; add a server-side rate limiter before wider use.
- No business-data queries or actions.
- No automatic code edits, GitHub commits, deployments, customer contact, or voice calls.
- OpenAI API usage may incur charges. Set budget/usage alerts in the API account.
