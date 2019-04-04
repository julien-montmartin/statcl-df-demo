header := ./header.sh
modules := ../modules/colors-0.1.tm ../modules/logger-0.1.tm
sources := ./dfDemo.tcl

all : #dfDemo
	@./gen.sh

clean :
	@rm -Rf release build download

dfDemo : $(header) $(modules) $(sources)
	@cat $(^) > ./$(@)
	@chmod +x $(@)
