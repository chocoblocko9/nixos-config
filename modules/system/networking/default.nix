{
  services.openssh.enable = true;
  networking = {
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 2234 ];
      allowedUDPPorts = [ 2234 ];
    };
  };
}
