{pkgs, ...}:
let
in
{  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";
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
