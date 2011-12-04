# This should give the most recent version
VERSION?=$(shell git tag | grep version- | grep -Eo '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$$' | tail -n 1)

RELEASETAG?=version-${VERSION}
ZIP=release/vikaasa-${VERSION}.zip
BZ2=release/vikaasa-${VERSION}.tar.bz2
PREFIX=vikaasa-${VERSION}/

# Make achives for the given version, and then clean up.
all:		archives clean

# Make zip and bz2 files of the given version
archives:	${ZIP} ${BZ2} versioncheck

${ZIP}:
		git archive --format=zip --prefix=${PREFIX} --output=${ZIP} ${RELEASETAG} 

${BZ2}:
		git archive --format=tar --prefix=${PREFIX} ${RELEASETAG} | bzip2 -9 > ${BZ2}

# Checking the version markers of the ZIP archive just created
versioncheck:	${ZIP} cleantmp
		unzip -q -x ${ZIP} -d tmp
		cd tmp/${PREFIX} && ../../bin/versioncheck

cleantmp:
		rm -rf tmp
		mkdir tmp

clean:		cleantmp

# This is the old method.
zip:
		bin/versioncheck
		zip -r ../vikaasa-${VERSION}.zip \
		  vikaasa vikaasa_cli.m vikaasa.m vikaasa.fig \
		  README LICENSE NOTICE \
		  Docs/html/*.html \
		  Projects/*.mat \
		  ControlAlgs/*.m \
		  VControlAlgs/*.m \
		  Libs/*.m \
		  Libs/*/*.m \
		  Libs/*/*.fig
