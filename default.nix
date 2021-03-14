{ stdenv
, python3
, linuxPackages
, kmod
, toybox
, bzip2
}:

stdenv.mkDerivation rec {
  pname = "oom-enospc-notify";
  version = "0.1-${linuxPackages.kernel.version}";

  src = ./.;
  nativeBuildInputs = [ python3.pkgs.wrapPython ];
  propagatedBuildInputs = [ linuxPackages.bcc kmod toybox bzip2 ];

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
