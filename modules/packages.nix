{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      nvtopPackages.msm
    ];
  };
}
