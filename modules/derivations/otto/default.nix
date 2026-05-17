{
  lib,
  dbus,
  eudev,
  fetchFromGitHub,
  installShellFiles,
  libdisplay-info,
  libglvnd,
  libinput,
  libxkbcommon,
  libgbm,
  versionCheckHook,
  nix-update-script,
  pango,
  pipewire,
  pkg-config,
  rustPlatform,
  seatd,
  stdenv,
  systemd,
  wayland,
  withDbus ? true,
  withDinit ? false,
  withScreencastSupport ? true,
  withSystemd ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri";
  version = "25.11";

  src = fetchFromGitHub {
    owner = "YaLTeR";
    repo = "niri";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FC9eYtSmplgxllCX4/3hJq5J3sXWKLSc7at8ZUxycVw=";
  };

  outputs = [
    "out"
    "doc"
  ];

  postPatch = ''
    patchShebangs resources/niri-session
    substituteInPlace resources/niri.service \
      --replace-fail '/usr/bin' "$out/bin"
  '';

  cargoHash = "sha256-X28M0jyhUtVtMQAYdxIPQF9mJ5a77v8jw1LKaXSjy7E=";

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libdisplay-info
    libglvnd # For libEGL
    libinput
    libxkbcommon
    libgbm
    pango
    seatd
    wayland # For libwayland-client
  ]
  ++ lib.optional (withDbus || withScreencastSupport || withSystemd) dbus
  ++ lib.optional withScreencastSupport pipewire
  ++ lib.optional withSystemd systemd # Includes libudev
  ++ lib.optional (!withSystemd) eudev; # Use an alternative libudev implementation when building w/o systemd

  buildFeatures =
    lib.optional withDbus "dbus"
    ++ lib.optional withDinit "dinit"
    ++ lib.optional withScreencastSupport "xdp-gnome-screencast"
    ++ lib.optional withSystemd "systemd";

  postInstall = ''
  '';

  checkFlags = [ "--skip=::egl" ];
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  meta = {
    description = "A stacking window manager built around animation, gesture, and spatial interaction.";
    homepage = "https://github.com/nongio/otto";
    changelog = "https://github.com/nongio/otto/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ choco98 ];
    mainProgram = "otto";
    platforms = lib.platforms.linux;
  };
})
