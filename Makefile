VERSION=0.9.1

zip:
	zip -r ../vikaasa-${VERSION}.zip vikaasa.m vikaasa.fig Docs Cli/*.m ControlAlgs/*.m Gui/*.m Gui/*.fig Projects Tools/*.m VControlAlgs/*.m
