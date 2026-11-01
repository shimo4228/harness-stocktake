# ADR-0001: Keep notes in memory

Status: Accepted (2025-03-02)

## Context
We need a store for the prototype.

## Decision
Keep notes in a module-level dict until we pick a database. Revisit when we add PostgreSQL.

## Consequences
Notes are lost on restart.
