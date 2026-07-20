# Spec: Hello export

- **Date:** 2026-07-20
- **Slug:** hello-export
- **Author:** Opus (spec)
- **Status:** approved

## Problem

Users cannot export a greeting string for demos.

## Goals

- Provide a pure function that returns a greeting for a given name.

## Non-goals

- CLI, HTTP, i18n, persistence.

## Requirements

1. Function `greet(name: string) -> string` returns `Hello, <name>!`.
2. Empty name is rejected with a clear error.

## Success criteria

- [x] Unit test covers happy path and empty name
- [x] No extra dependencies

## Open questions

- None after review.
