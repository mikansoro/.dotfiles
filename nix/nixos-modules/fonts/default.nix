{ config, lib, pkgs, ... }:

{
    fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      # hack-font
      ibm-plex
      # inconsolata
      # roboto
      # powerline-fonts
      source-code-pro
      source-sans-pro
      source-serif-pro

      noto-fonts-cjk
      source-han-sans-japanese
      source-han-sans-korean
      source-han-sans-simplified-chinese
      source-han-serif-japanese
      source-han-serif-korean
      source-han-serif-simplified-chinese
      source-han-code-jp
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "IBM Plex Mono" "Noto Sans Mono CJK JP" "Noto Sans Mono CJK KR" "Noto Sans Mono CJK SC" ];
        sansSerif = [ "Source Sans Pro" "Source Han Sans JP Medium" "Source Han Sans KR Medium" "Source Han Sans CN Medium" ];
        serif = [ "Source Serif Pro" "Source Han Serif JP Medium" "Source Han Serif KR Medium" "Source Han Serif CN Medium" ];
      };
    };
  };

}
