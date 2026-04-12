{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.looking-glass-client ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;  # TPM for Windows 11
      runAsRoot = false;
      verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/kvmfr0"
        ]
      '';
    };
  };

  users.users.conor.extraGroups = [ "libvirtd" "kvm" ];

  programs.virt-manager.enable = true;

  boot.kernelModules = [ "vfio-pci" ];
  boot.kernelParams = [ "amd_iommu=on" ];
}
