# notes-api

Python 3.12 service. The store lives in `src/notes.py`.

## Commands

- `make test` — unit tests
- `make e2e` — end-to-end tests against a local server (run before every release)
- `make lint`

## Conventions

- Keep functions under 40 lines.
- Use type hints everywhere.
- Architecture overview: see `docs/architecture.md`.
- Decisions are recorded in `docs/adr/`.

## Style

- Use type hints everywhere.
- Prefer f-strings over `%` formatting.
- Never commit directly to main; open a PR.
