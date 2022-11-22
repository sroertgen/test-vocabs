# Test SKOS-Vocabs with GitHub Action

Whenever you push a .ttl-file the GitHub-Action will be triggered and validate it against this [SKOS SHACL Shape](https://github.com/skohub-io/shapes/blob/main/skos.shacl.ttl).
If the validation fails, check the output from GitHub action to get further information on what was not correct.

You can also try the script which get used in the action locally:

`scripts/validate-skos.sh -f YOUR_TTL_FILE`

The script makes use of [docker](https://www.docker.com/). So make sure to have it installed.

