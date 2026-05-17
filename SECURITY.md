# Security Policy

## Reporting a vulnerability

Report security issues privately via GitHub's
[private vulnerability reporting](https://github.com/guilhermegsr/my_tokens/security/advisories/new).
Do not open a public issue for security reports.

Please include reproduction steps and affected versions. Expect an
initial response within a few days; fixes are shipped as a new tagged
release with the advisory published once users can update.

## Scope

MyTokens runs entirely offline with no backend, so the relevant attack
surface is local: the AES-256-GCM vault, the Android Keystore-held key,
Argon2id backup encryption, and the app lock. Reports demonstrating
secret disclosure, weakened cryptography, or app-lock bypass are in
scope.

## Supported versions

Only the latest released version receives security fixes.
