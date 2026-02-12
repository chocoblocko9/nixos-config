let
  conor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMwm8ProRmeY+Ucxf51jqSN8HGfntdBZ65cc1JNIn1B";
  users = [ conor ];
in
{
  "secret1.age".publicKeys = [ conor ];
}
