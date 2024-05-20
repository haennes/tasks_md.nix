# Auto-generated using compose2nix v0.1.9.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."tasks.md_one" = {
    image = "baldissaramatheus/tasks.md";
    environment = {
      PGID = "1000";
      PUID = "1000";
    };
    volumes = [
      "/var/config:/config:rw"
      "/var/tasks:/tasks:rw"
    ];
    ports = [
      "8080:8080/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=tasks.md_one"
      "--network=tasksmd_default"
    ];
  };
  systemd.services."docker-tasks.md_one" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-tasksmd_default.service"
    ];
    requires = [
      "docker-network-tasksmd_default.service"
    ];
    partOf = [
      "docker-compose-tasksmd-root.target"
    ];
    wantedBy = [
      "docker-compose-tasksmd-root.target"
    ];
  };
  virtualisation.oci-containers.containers."tasks.md_two" = {
    image = "baldissaramatheus/tasks.md";
    environment = {
      PGID = "1000";
      PUID = "1000";
    };
    volumes = [
      "/var/config2:/config:rw"
      "/var/tasks2:/tasks:rw"
    ];
    ports = [
      "8081:8080/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=tasks.md_two"
      "--network=tasksmd_default"
    ];
  };
  systemd.services."docker-tasks.md_two" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-tasksmd_default.service"
    ];
    requires = [
      "docker-network-tasksmd_default.service"
    ];
    partOf = [
      "docker-compose-tasksmd-root.target"
    ];
    wantedBy = [
      "docker-compose-tasksmd-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-tasksmd_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.docker}/bin/docker network rm -f tasksmd_default";
    };
    script = ''
      docker network inspect tasksmd_default || docker network create tasksmd_default
    '';
    partOf = [ "docker-compose-tasksmd-root.target" ];
    wantedBy = [ "docker-compose-tasksmd-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-tasksmd-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}