{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.kmonad ];

  # Loads uinput, creates the uinput group, installs the one udev rule for it.
  hardware.uinput.enable = true;

  # input: read the physical keyboard. uinput: write the virtual one.
  users.users.joshua.extraGroups = [
    "input"
    "uinput"
  ];
}
