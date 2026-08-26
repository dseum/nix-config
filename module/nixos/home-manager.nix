{
  user,
  targetDir,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = {
      inherit targetDir;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          ../shared/home-manager.nix
        ];
        home = {
          homeDirectory = "/home/${user}";
          packages = import ./packages.nix { inherit pkgs; };
          username = "${user}";
        };
        programs.ghostty.settings.keybind = lib.mkAfter [
          "super+c=copy_to_clipboard:mixed"
          "super+v=paste_from_clipboard"
          "super+t=new_tab"
          "super+w=close_tab:this"
          "super+n=new_window"
          "super+q=quit"
          "super+f=start_search"
          "super+k=clear_screen"
          "super+,=open_config"
          "super+==increase_font_size:1"
          "super+-=decrease_font_size:1"
          "super+0=reset_font_size"
          "super+[=previous_tab"
          "super+]=next_tab"
        ];
      };
  };
}
