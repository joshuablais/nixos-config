{ ... }:
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = false;
      # sync_address = "https://atuin.yourdomain.com";
      sync_frequency = "0";
      search_mode = "fuzzy";
      filter_mode = "host";
      filter_mode_shell_up_arrow = "global";
      style = "compact";
      inline_height = 20;
      show_preview = true;
      enter_accept = true;
      secrets_filter = true;
    };
  };
}
