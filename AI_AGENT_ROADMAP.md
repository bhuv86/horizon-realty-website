# Diamond Realty AI — Development Roadmap

## Goal
Build an owner-controlled AI assistant for Diamond Realty that supports chat and voice, understands Tanglish and English, helps operate the real-estate platform, and diagnoses technical problems.

## Safety and ownership rules
- The production `main` branch must not be changed by the agent.
- Work happens on a development branch and is reviewed before release.
- The agent may inspect code, diagnose errors, propose patches, and run available tests.
- The agent must show a change summary and test results before asking for approval.
- No production deployment, database migration, customer message, phone call, payment, or destructive action without explicit owner approval.
- Never request or commit passwords, Supabase service-role keys, API tokens, or other secrets.
- Keep backups and a rollback path before any approved production change.
- Treat customer-submitted text and external data as untrusted input.

## Existing repository baseline
- Static HTML/CSS/JavaScript website.
- Supabase browser client.
- Public project and plot listing.
- Enquiry/site-visit submission form.
- Admin sign-in, project creation, CSV plot upload, and site-visit listing.
- SQL schema for projects, plots, enquiries, and site visits.

## Known items to verify or improve
- Add robust Supabase query error handling and loading/empty states.
- Review Row Level Security policies and grants against least privilege.
- Add safe DOM rendering/escaping for database-sourced content.
- Add project and plot edit/delete flows with confirmation and validation.
- Add lead pipeline, follow-up history, site-visit status, and staff roles.
- Add audit logs and backups before enabling sensitive operations.
- Add tests for access control, form validation, data integrity, and recovery.

## Delivery phases
1. **Baseline and safety:** map the code, verify Supabase configuration without exposing secrets, document deployment, and establish test/backup procedures.
2. **Website reliability:** fix verified bugs, improve error handling, input validation, accessibility, and mobile behavior.
3. **Business operations:** projects/plots CRUD, lead CRM, site visits, staff permissions, reports, and bilingual Tamil/English UI.
4. **AI control centre:** authenticated owner chat interface, task planning, read-only diagnostics, proposed code changes, test results, and approval workflow.
5. **Voice interface:** add a Tanglish voice channel using a selected telephony/voice provider after account and cost approval.
6. **Monitoring and maintenance:** health checks, error alerts, dependency/security checks, backup verification, and documented rollback.

## Release gate
A change is ready for owner review only after its scope, changed files, risks, test evidence, and rollback steps are presented. Merge and production deployment remain owner-controlled.
