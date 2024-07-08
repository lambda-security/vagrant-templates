# vagrant-templates

Repository to build and run vagrant templates.

Associated technical blog post and details at [https://pentest.lambda-security.com/posts/automated-active-directory-attack-range](https://pentest.lambda-security.com/posts/automated-active-directory-attack-range)

## packer-templates

Collection of packer templates to build VirtualBox virtual machine Vagrant boxes for environment deployments.

## active-directory

Vulnerable Active Directory environment to use as for testing various attack scenarios.

# Notes and credits

This vulnerable environment is designed for local testing purposes; it isn't configured to specifically test for AV/EDR bypasses, as such Defender isn't configured in any way and is disabled during the initial build; Sysmon is installed and configured, and provides some tradecraft telemetry that can inspected for further use.

Credits to [Orange Cyberdefense's GOAD](https://github.com/Orange-Cyberdefense/GOAD) for a similar set up that inspired us to create our own environment and that provided example configurations for specific scenarios (e.g., ADCS). Additional credits to SwiftOnSecurity's Sysmon config at [https://github.com/SwiftOnSecurity/sysmon-config](https://github.com/SwiftOnSecurity/sysmon-config).
