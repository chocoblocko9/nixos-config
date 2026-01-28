# Installation notes that may be important

This is where I'm going to catalogue weird imperative stuff that I did, that may be important to look at if I have to build this config again, along with a note saying why

## The list

1. LASTFM_KEY and LASTFM_SECRET home.sessionVaribales reference out of store files (~/Documents/lastfmkey and ~/Documents/lastfmsecret respectively) because both agenix and sops-nix are throwing the same really weird errors and rescrobbled doesn't support reading from files. I'm letting it slide because it's not like critical infrastructure. RIP purity :(