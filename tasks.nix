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
        #default =
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

  recursiveMerge= listOfAttrsets:
        lib.fold (attrset: acc: lib.recursiveUpdate attrset acc) { }
        listOfAttrsets;
    cont_name = item: builtins.replaceStrings ["/"]["_"] item.tasks_dir;
  app = lis: map
    (item: {
      virtualisation.oci-containers.containers."tasks.md${cont_name item}" = {
        image = "baldissaramatheus/tasks.md";
        environment = {
          PGID = item.guid;
          PUID = item.guid;
          TITLE = item.title;
          BASE_PATH = item.base_path;
        };
        volumes = [ "${item.config_dir}:/config:rw" "${item.tasks_dir}:/tasks:rw" ];
        ports = [ "${toString item.port}:8080/tcp" ];
        log-driver = "journald";
        extraOptions =
          [ "--network-alias=tasks.md${cont_name item}" "--network=tasksmd_default" ];
      };
      systemd.services."docker-tasks.md${cont_name item}" = {
        serviceConfig = {
          Restart = lib.mkOverride 500 "always";
          RestartMaxDelaySec = lib.mkOverride 500 "1m";
          RestartSec = lib.mkOverride 500 "100ms";
          RestartSteps = lib.mkOverride 500 9;
        };
        after = [ "docker-network-tasksmd_default.service" ];
        requires = [ "docker-network-tasksmd_default.service" ];
        partOf = [ "docker-compose-tasksmd-root.target" ];
        wantedBy = [ "docker-compose-tasksmd-root.target" ];
      };
    }) lis;
in {
  options.services.tasks_md = {
    enable = with lib; mkEnableOption "tasks";
    conf = lib.mkOption {
      type = lib.types.either (lib.types.listOf sub) sub;
      apply = with lib; old: if isList old then old else [ old ];
    };

  };
  config = lib.mkIf cfg.enable (
  recursiveMerge ([(import ./base.nix{inherit pkgs;})] ++
  [  #lib.lists.map(item:
  (import ./foreach.nix{inherit lib; item = (lib.elemAt cfg.conf 0);})
  (import ./foreach.nix{inherit lib; item = (lib.elemAt cfg.conf 1);})
  (import ./foreach.nix{inherit lib; item = (lib.elemAt cfg.conf 2);})
  (import ./foreach.nix{inherit lib; item = (lib.elemAt cfg.conf 3);})
    #) cfg.conf #uncomment if map
  ])
    );
}
