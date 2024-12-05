{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;
    policies = lib.mkForce {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxScreenshots = false;

      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      PasswordManagerEnabled = false;

      #DNSOverHTTPS.Enabled = false;

      PictureInPicture.Enabled = false;
      PromptForDownloadLocation = false;

      # what's this?
      TranslateEnabled = true;

      Homepage.StartPage = "previous-session";

      UserMessaging = {
        UrlbarInterventions = false;
        SkipOnboarding = true;
      };

      FirefoxSuggestions = {
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };

      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
      };
    };
    #profiles = {
    #  default = {
    #    id = 0;
    #    isDefault = true;
    #    settings = {

    #    };
    #  };
    #};
  };
}
