{lib, item}:
let
    cont_name = item: builtins.replaceStrings ["/"]["_"] item.tasks_dir;
in
{
      virtualisation.oci-containers.containers."tasks.md${cont_name item}" = {
        image = "baldissaramatheus/tasks.md:2.5.3";
        environment = {
          PGID = toString item.guid;
          PUID = toString item.puid;
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
    services.nginx.virtualHosts = {
      "${item.domain}" = {
        locations."${item.base_path}" = {
          proxyPass = "http://localhost:${toString item.port}${item.base_path}";
        };
      };
    };
    }
