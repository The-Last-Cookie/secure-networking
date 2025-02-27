# Network and systems hardening

This repository works as a compendium of guidelines for securing a network and its systems.

It provides best practices for settings and contains usage guides for helpful tools.

## Nessus

Nessus is a vulnerability management system giving insight into a device's threat landscape[^landscape] and possible attack vectors.

For successfully scanning a system for vulnerabilities, the system must have certain settings. Otherwise, the scan results may not be as detailed.

However, some of these settings can leave the system more vulnerable if left unchanged. Thus, there are two scripts where one prepares the system for a scan and the other resets all settings to the system's default.

*Notice: Some queries in the script require language-specific parameters. Currently, the scan script is configured for German. I might add a language option later.*

## Pihole

Pi-hole is an open-source software application designed to block advertisements and online trackers at the network level, functioning primarily as a DNS sinkhole.

## Annotations

[^landscape]: Technically not the correct term here but does not matter too much.
