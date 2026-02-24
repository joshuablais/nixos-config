# ~/nixos-config/modules/desktop/blocklist.nix
{
  config,
  lib,
  pkgs,
  ...
}:

# Blocklist of domains
let
  distractionDomains = [
    "reddit.com"
    "old.reddit.com"
    "www.reddit.com"
    "twitter.com"
    "x.com"
    "www.twitter.com"
    "facebook.com"
    "www.facebook.com"
    "instagram.com"
    "www.instagram.com"
    "tiktok.com"
    "www.tiktok.com"
    "linkedin.com"
    "www.linkedin.com"
    "news.ycombinator.com"
    "lobste.rs"
    "netflix.com"
    "www.netflix.com"
    "twitch.tv"
    "www.twitch.tv"
    "christisking.cc"
    "www.christisking.cc"
    "studio.youtube.com"
    "forum.agoraroad.com"
    "cbc.ca"
    "www.cbc.ca"
    "www.brutalist.report"
    "brutalist.report"
    "4chan.org"
    "www.4chan.org"
  ];

in
{
  networking.extraHosts = lib.concatMapStringsSep "\n" (
    domain: "0.0.0.0 ${domain}"
  ) distractionDomains;
}
