{ lib, config, pkgs, ... }:
let
  sub = lib.types.submodule {
    options = with lib; {
      domain = mkOption {
        type = types.str;
        default = "localhost";
        example = "tasks.example.com";
      };
      port = mkOption {
        type = types.port;
        default = 8080;
      };
      base_path = mkOption {
        type = types.path;
        example = "/tasks";
        default = "/";
        description = ''
          basepath of the url
        '';
      };

      title = mkOption rec {
        type = types.str;
        example = "Tasks.md";
        default = example;
      };

      config_dir = mkOption {
        type = types.path;
        default = "config";
        example = "~/.config/tasks_md";
      };
      tasks_dir = mkOption {
        type = types.path;
        example = "~/tasks";
      };
      puid = mkOption {
        type = with types; nullOr int;
        default = 1000;
      };
      guid = mkOption {
        type = with types; nullOr int;
        default = 100;
      };
    };
  };
  cfg = config.services.tasks_md;

  recursiveMerge = listOfAttrsets:
    lib.fold (attrset: acc: lib.recursiveUpdate attrset acc) { } listOfAttrsets;
in {
  options.services.tasks_md = {
    enable = with lib; mkEnableOption "tasks";
    enableNginx = with lib;
      mkEnableOption "enable Nginx virtual Hosts configured using domain";
    conf = lib.mkOption {
      type = lib.types.either (lib.types.listOf sub) sub;
      apply = with lib; old: if isList old then old else [ old ];
    };

  };
  config = lib.mkIf cfg.enable (recursiveMerge
    ([ (import ./base.nix { inherit pkgs; }) ] ++ [ # lib.lists.map(item:
      (import ./foreach.nix {
        inherit lib cfg;
        item = (lib.elemAt cfg.conf 0);
      })
      (import ./foreach.nix {
        inherit lib cfg;
        item = (lib.elemAt cfg.conf 1);
      })
      (import ./foreach.nix {
        inherit lib cfg;
        item = (lib.elemAt cfg.conf 2);
      })
      (import ./foreach.nix {
        inherit lib cfg;
        item = (lib.elemAt cfg.conf 3);
      })
      #) cfg.conf #uncomment if map
    ]));
}
