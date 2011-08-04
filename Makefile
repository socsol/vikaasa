VERSION=0.12.0

zip:
	bin/versioncheck
	zip -r ../vikaasa-${VERSION}.zip vikaasa vikaasa_cli.m vikaasa.m vikaasa.fig \
	  README LICENSE NOTICE \
	  Docs/html/*.html \
	  Projects/*.mat \
	  ControlAlgs/*.m \
	  VControlAlgs/*.m \
	  Libs/*.m \
	  Libs/*/*.m \
	  Libs/*/*.fig
