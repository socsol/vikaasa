# This should give the most recent version
VERSION?=$(shell git tag | grep version- | grep -Eo '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$$' | tail -n 1)

RELEASETAG?=version-${VERSION}
ZIP=release/vikaasa-${VERSION}.zip
TAR=release/vikaasa-${VERSION}.tar
BZ2=${TAR}.bz2
PREFIX=vikaasa-${VERSION}/

# This is just the current ISS checkout, so this won't work for making old archives
ISS_VERSON=$(shell git submodule status Libs/InfSOCSol | grep -Eo "[a-f0-9]{40}")

# Make achives for the given version, and then clean up.
all:		archives clean

# Make zip and bz2 files of the given version
archives:	${ZIP} ${BZ2} versioncheck

${ZIP}:		${TAR} cleantmp
		tar -x -C tmp -f ${TAR}
		cd tmp && zip -q -r ../${ZIP} vikaasa-${VERSION}

${BZ2}:		${TAR}
		bzip2 -9 ${TAR} -c > ${BZ2}


${TAR}:
		git archive --format=tar --prefix=${PREFIX} ${RELEASETAG} --output=${TAR}
		git --git-dir=Libs/InfSOCSol/.git archive --format=tar --prefix=${PREFIX}Libs/InfSOCSol/ ${ISS_VERSION} --output=${TAR}.1
		tar -A -f ${TAR} ${TAR}.1
		rm ${TAR}.1

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
