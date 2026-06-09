{ ... }:

{
  services.udev.extraRules = ''
    # Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTRS{idProduct}=="1969", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTRS{idProduct}=="1307", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTRS{idProduct}=="6060", GROUP="plugdev"

    # Wally flashing rules for Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[89B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]*", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE="0664"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE="0664"

    # Keymapp / Wally flashing rules for Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0666", SYMLINK+="stm32_dfu"

    # Keymapp flashing rules for Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE="0666", SYMLINK+="ignition_dfu"
  '';

  users.users.joshua.extraGroups = [ "plugdev" ];
}
