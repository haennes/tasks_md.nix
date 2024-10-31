{ ... }: {
  services.tasks_md = {
    enable = true;
    conf = [
      {
        config_dir = "/home/hannses/tasks1/config";
        tasks_dir = "/home/hannses/tasks1/tasks";
      }

      {
        config_dir = "/home/hannses/tasks2/config";
        tasks_dir = "/home/hannses/tasks2/tasks";
      }

      {
        config_dir = "/home/hannses/tasks3/config";
        tasks_dir = "/home/hannses/tasks3/tasks";
      }

      {
        config_dir = "/home/hannses/tasks4/config";
        tasks_dir = "/home/hannses/tasks4/tasks";
      }
    ];
  };
}
