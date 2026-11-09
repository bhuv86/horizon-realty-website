# Diamond Realty AI backend (development)

This backend is being prepared for the existing **horizon-realty-website** repository and its existing Supabase project. All work in this branch is development-only.

## Current components

- `supabase/functions/diamond-ai/index.ts`: chat-only Edge Function. It validates the Supabase access token, checks the caller against `OWNER_USER_ID`, restricts the request origin, and calls the OpenAI Responses API.
- `ai-control.html`: owner sign-in and chat interface for the development preview.
- `supabase/migrations/20261110_owner_only_rls.sql`: proposed owner-only database policy migration and foreign-key indexes.

## Important deployment status

**Nothing in this folder has been deployed or applied to the production Supabase project.** The migration is a reviewed proposal file only. The Edge Function is not deployed. The GitHub Pages production site is not changed by this branch.

Do not apply the migration or deploy the function until the owner separately approves the production release.

## Required Edge Function secrets

Set these in Supabase Dashboard → Edge Functions → Secrets. Never commit secret values:

- `OPENAI_API_KEY`: API key for the OpenAI API project
- `OPENAI_MODEL`: a model ID enabled for that API project
- `OWNER_USER_ID`: UUID of the owner's Supabase Auth user
- `ALLOWED_ORIGIN`: exact website origin (scheme + host only), e.g. `https://bhuv86.github.io` only if that is the actual Pages origin

Supabase provides the project URL and publishable/anon key to hosted Edge Functions. The function supports `SUPABASE_PUBLISHABLE_KEYS` (JSON map with a `default` entry) and the legacy `SUPABASE_ANON_KEY`.

The publishable key used by the static page is not a secret. Never put an OpenAI key, service-role key, personal access token or database password in browser code.

## Database migration review and owner bootstrap

The migration file is intentionally **not applied**. Before any production application:

1. Download and verify a current database backup.
2. Review the migration SQL and confirm the exact owner Auth user UUID.
3. Apply the migration in a controlled maintenance window only after separate owner approval.
4. In the Supabase SQL Editor, add the owner's Auth UUID to the private owner registry (replace the placeholder with the real UUID; do not leave angle brackets):

```sql
insert into private.owner_accounts (user_id)
values ('REPLACE_WITH_OWNER_AUTH_USER_UUID');
```

5. Verify the owner can manage projects/plots and read enquiries/site visits, while a different authenticated user cannot.
6. Verify anonymous visitors can still read the public project/plot catalogue and submit enquiry/site-visit forms.
7. Re-run Supabase security, performance and health advisors.

The migration does not delete existing business rows or alter table definitions. It removes broad authenticated-write policies, adds a private owner registry and owner-check function, adds owner-scoped policies, and creates indexes for the three flagged foreign keys. The owner registry starts empty by design; until the owner UUID is inserted, no authenticated user is treated as owner.

## Chat setup and deployment (owner-operated)

Before deployment:

1. Confirm the owner can sign in using Supabase Auth.
2. Obtain the owner's Auth user UUID from Authentication → Users.
3. Confirm the exact GitHub Pages origin from the deployed site's address bar. Do not guess a custom domain.
4. Set the four Edge Function secrets listed above.
5. Deploy only the `diamond-ai` function after separate approval.
6. Test with the owner account and confirm a different authenticated account is rejected.
7. Only then publish the control-centre page.

Example CLI steps (run locally from the repository root after approval):

```sh
supabase login
supabase link --project-ref jpbujomdlyoqjeledjlm
supabase functions deploy diamond-ai
```

Do not disable JWT verification to work around authentication errors.

## Request contract

The browser uses Supabase Auth and invokes `/functions/v1/diamond-ai` with the current user session and JSON body `{"message":"..."}`. Success response: `{"answer":"..."}`.

The Edge Function checks the Supabase user UUID against `OWNER_USER_ID`. It only accepts the exact `ALLOWED_ORIGIN`.

## Current limitations

- No persistent chat history.
- No durable server-side rate limiter yet; add one before broader use.
- No business-data queries or actions.
- No automatic code edits, GitHub commits, deployments, customer contact, payments or voice calls.
- The chat page is a development preview and cannot work until the Edge Function secrets are configured and the function is deployed.
- OpenAI API usage may incur charges. Set usage budgets and alerts in the API account.
