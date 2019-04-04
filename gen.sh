#!/bin/sh


root=$(readlink -f .)
download="${root}"/download
build="${root}"/build
release="${root}"/release


getStatcl() {

	curlTxt=https://raw.githubusercontent.com/julien-montmartin/statcl/master/curl.txt
	curl -s ${curlTxt} | curl -sLK -
	ls -lh statcl-*
}


makeDemo() {

	cd "${download}"

	if [ ! -f appimagetool-x86_64.AppImage ] ; then

		wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
		chmod a+x appimagetool-x86_64.AppImage
	fi

	if [ ! -f statcl-files.txt ] ; then

		getStatcl
	fi

	cd "${root}"

	cp -R dfDemo.AppDir "${build}"

	cd "${build}"/dfDemo.AppDir

	tar -xf "${download}"/statcl-tcl-*.tar.gz lib
	tar -xf "${download}"/statcl-tk-*.tar.gz bin lib
	tar -xf "${download}"/statcl-tcllib-*.tar.gz lib

	rm -Rf ./lib/tk*/demos
	rm -Rf ./lib/tcllib*/docstrip ./lib/tcllib*/tcllib_doc ./lib/tcllib*/doctools*

	cp /bin/df ./bin/

	cp "${root}"/dfDemo .

	cd "${build}"

	"${download}"/appimagetool-x86_64.AppImage dfDemo.AppDir
	mv dfDemo-x86_64.AppImage "${release}"

	cd "${root}"
}


rm -Rf "${build}" "${release}"
mkdir "${build}" "${release}"
mkdir -p "${download}"


makeDemo
