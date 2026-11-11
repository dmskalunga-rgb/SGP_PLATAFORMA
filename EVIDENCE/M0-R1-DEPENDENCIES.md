# M0-R1 dependency decisions

Fresh npm audit: all severity counts zero in artifacts/npm-audit.json (raw report retained by CI). Original seven MODERATE findings originated from minimatch glob amplification (GHSA-g3hv-75wg-m249) and its development-only TypeScript ESLint dependency chain. They were not seven independent runtime exploits.

| Package occurrence | Initial version evidence | Final version | Kind / runtime | Exposure and fixed-version analysis | Action / decision |
|---|---|---|---|---|---|
| minimatch | original exact resolved version was not retained; reported vulnerable range 7.0.0–11.0.0 | 11.0.8 | transitive / dev | lint glob processing; no application endpoint or production runtime. Patched major available; major override requires compatibility verification. | pin override; lint and SCA verification; FIXED |
| @typescript-eslint/typescript-estree | baseline group 8.48.0 | 8.72.2 | transitive / dev | carries minimatch to lint parser; not shipped in runtime | update and override; FIXED |
| @typescript-eslint/parser | baseline group 8.48.0 | 8.72.2 | transitive / dev | inherited dependency finding | update and override; FIXED |
| typescript-eslint | 8.48.0 in baseline manifest | 8.72.2 | direct / dev | inherited dependency finding | update and override; FIXED |
| @typescript-eslint/type-utils | baseline group 8.48.0 | 8.72.2 | transitive / dev | inherited dependency finding | update and override; FIXED |
| @typescript-eslint/utils | baseline group 8.48.0 | 8.72.2 | transitive / dev | inherited dependency finding | update and override; FIXED |
| @typescript-eslint/eslint-plugin | baseline group 8.48.0 | 8.72.2 | transitive / dev | inherited dependency finding | update and override; FIXED |

The TypeScript ESLint update stays in major 8; the minimatch override changes major and is limited to development tools. No risk acceptance or blanket advisory ignore is used. Re-run npm audit, lint, types and build after dependency changes; review this override when upstream adopts the fixed dependency. Initial subpackage versions are baseline group references, not a preserved historical audit artifact. Current resolved versions are verifiable in package-lock.json.
