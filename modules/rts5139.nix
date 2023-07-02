{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
	pname = "rts5139";
	version = "1.06";

	src = fetchFromGitHub {
		owner = "ljmf00";
		repo = "rts5139";
		rev = "v1.06";
		sha256 = "sha256-GYuGTyOR3dT/20D+ko/YIzEwfMLbG2jKD/wyaYTULA8=";
	};

	setSourceRoot = ''
		export sourceRoot=$(pwd)/source
	'';

	nativeBuildInputs = kernel.moduleBuildDependencies;

	makeFlags = kernel.makeFlags ++ [
		"-C"
		"${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
		"M=$(sourceRoot)"
	];

	buildFlags = [ "modules" ];
	installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
	installTargets = [ "modules_install" ];

	meta = with lib; {
		description = "Linux kernel drivers module for RTS5129/RTS5139 USB MMC card reader";
		homepage = "https://github.com/ljmf00/rts5139";
		license = licenses.gpl2Only;
		platforms = platforms.linux;
	};
}
