{ pkgs ? import <nixpkgs> {}
, stdenv ? pkgs.stdenv
, python ? pkgs.python3
, linuxPackages ? pkgs.linuxPackages
}:

stdenv.mkDerivation rec {
  pname = "oom-enospc-notify";
  version = "0.1-${linuxPackages.kernel.version}";

  src = ./.;
  nativeBuildInputs = [ python.pkgs.wrapPython ];
  propagatedBuildInputs = [ linuxPackages.bcc ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install oom-enospc-notify $out/bin/
    runHook postInstall
  '';
  postFixup = ''
    wrapPythonPrograms
  '';
}
