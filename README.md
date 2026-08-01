# Controlled GitHub Pages Marshal proof

This fixture contains only one command-execution oracle: `touch` creates
`PAGES_MARSHAL_RCE_CANARY_8E91C4A7` inside the researcher-owned checkout.
Jekyll then copies that harmless marker into the generated Pages artifact.

The fixture performs no network callback and does not read environment
variables, credentials, system files, or third-party data.
