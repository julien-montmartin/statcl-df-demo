#!/bin/sh

################################################################################
#
# Tweak - sh-backslash-region (C-c C-\) est pratique !
#
################################################################################

#Validation de l'environnement et cie (commence avec un looong commentaire)	\
																			\
TCL=$(which tclsh);															\
																			\
if [ -z "${TCL}" ];															\
then																		\
																			\
	printf "Could not find a tcl interpreter" >&2;							\
	exit 1;																	\
																			\
fi > /dev/null;																\
																			\
printf "About to run '${TCL}'\n"											\
																			\
#Voir man tclsh																\
exec "${TCL}" "$0" ${1+"$@"}
################################################################################
puts "Running Tcl code !"
