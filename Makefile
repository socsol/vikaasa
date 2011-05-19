VERSION=0.10.3

zip:
	zip -r ../vikaasa-${VERSION}.zip vikaasa vikaasa_cli.m vikaasa.m vikaasa.fig \
	  Docs/html/*.html \
	  Projects/*.mat \
	  ControlAlgs/*.m \
	  VControlAlgs/*.m \
	  Libs/*.m \
	  Libs/*/*.m \
	  Libs/*/*.fig
