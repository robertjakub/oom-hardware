{
  stdenv,
  fetchFromGitHub,
  gcc,
  device ? "/dev/deskPi",
  ...
}:
let
  pname = "deskpi4-tools";
  version = "0-unstable-20240723";

  src = fetchFromGitHub {
    owner = "DeskPi-Team";
    repo = "deskpi";
    rev = "e421d1e6bd9afb545b6bbfc6b30e306975e77e44";
    hash = "sha256-cetBXTqe8zZXpn5jjZ/g61j9y39exKWIvJH9IMgJj5c=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ gcc ];
  dontConfigure = true;

  postPatch = ''
    substituteInPlace installation/drivers/c/pwmFanControl.c --replace '/dev/ttyUSB0' '${device}'
    substituteInPlace installation/drivers/c/pwmFanControl.c --replace 'conf_info[1]=75' 'conf_info[1]=0'
    substituteInPlace installation/drivers/c/pwmFanControl.c --replace 'conf_info[3]=75' 'conf_info[3]=50'
    substituteInPlace installation/drivers/c/pwmFanControl.c --replace 'conf_info[5]=100' 'conf_info[5]=75'
    substituteInPlace installation/drivers/c/safeCutOffPower.c --replace '/dev/ttyUSB0' '${device}'
  '';

  buildPhase = ''
    runHook preBuild
    cd installation/drivers/c
    make clean all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 ./pwmFanControl64 $out/bin/pwmFanControl
    install -m755 ./safeCutOffPower64 $out/bin/safeCutOffPower
    runHook postInstall
  '';
}
