{ stdenv, fetchurl, itstool, python2Packages, intltool
, libxml2, gobjectIntrospection, gtk2, gconf, gnome2, dbus, glib, keybinder
}:


let
inherit (python2Packages) python buildPythonApplication;
  version = "2.4";
in buildPythonApplication rec {
  name = "glipper-${version}";

  src = fetchurl {
    url = "https://launchpad.net/glipper/trunk/${version}/+download/glipper-${version}.tar.gz";
    sha256 = "11px6ddmrfdn7lgdhba7sds905df91lm5w2y2adl1ls2ndvlnjy8";
  };

  inputs = [ glib ];
  propagatedUserEnvPkgs = [ gconf.out ];
  buildInputs = [
    intltool
  ];
  propagatedBuildInputs = with python2Packages;
  [ pyxdg pygobject2 distutils_extra pygtk gnome2.gnome_python dbus keybinder appindicator
  ];

  postInstall = ''
    mkdir -p $out/share/gconf/schemas
    cp data/glipper.schemas $out/share/gconf/schemas
    ${glib.dev}/bin/glib-compile-schemas $out/share/gconf/schemas
  '';

  installPhase = ''
    substituteInPlace setup.py --replace /etc/xdg $out/etc/xdg
    mkdir -p "$out/lib/${python.libPrefix}/site-packages"

    export PYTHONPATH="$out/lib/${python.libPrefix}/site-packages:$PYTHONPATH"

    ${python}/bin/${python.executable} setup.py install \
      --install-lib=$out/lib/${python.libPrefix}/site-packages \
      --prefix="$out"
  '';

  patchPhase = ''
    patchShebangs scripts/glipper
  '';

  meta = with stdenv.lib; {
    description = "Glipper is a clipboardmanager for GNOME.";
    homepage = https://launchpad.net/glipper;
    license = stdenv.lib.licenses.gpl2;
    platforms = platforms.linux ++ stdenv.lib.platforms.darwin;
    maintainers = [  ];
  };
}
