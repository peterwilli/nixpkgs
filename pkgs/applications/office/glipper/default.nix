{ stdenv, fetchurl, itstool, python2Packages, intltool, wrapGAppsHook
, libxml2, gobjectIntrospection, gtk2, cairo, file, gconf, vte, gnome2, dbus, glib
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
    intltool wrapGAppsHook file
  ];
  propagatedBuildInputs = with python2Packages;
  [ pyxdg pygobject2 distutils_extra pygtk gnome2.gnome_python dbus
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
    patchShebangs .
  '';

  meta = with stdenv.lib; {
    description = "Visual diff and merge tool";
    homepage = http://meldmerge.org/;
    license = stdenv.lib.licenses.gpl2;
    platforms = platforms.linux ++ stdenv.lib.platforms.darwin;
    maintainers = [ maintainers.mimadrid ];
  };
}
