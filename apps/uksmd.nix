{ lib, stdenv, fetchurl, pkgs, pkg-config, meson, cmake, procps, libcap_ng }:

stdenv.mkDerivation rec {
  pname = "uksmd";
  version = "6.4";
  src = fetchurl {
    url = "https://codeberg.org/pf-kernel/uksmd/archive/v${version}.tar.gz";
    sha256 = "sha256-EhhNgA32jRRxhhJPVVqH8+v89t5aqZBunoK714wcgSk=";
  };
  nativeBuildInputs = [ meson pkg-config ];
  buildInputs = [ procps libcap_ng ];
  propagatedBuildInputs = [ procps libcap_ng ];
  buildPhase = ''
    meson . build
    meson compile -C build
  '';
  installPhase = ''
    meson install -C build --destdir "$out"
  '';
  meta = with lib; {
    description = "Userspace KSM helper daemon.";
    homepage = "https://codeberg.org/pf-kernel/uksmd";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
