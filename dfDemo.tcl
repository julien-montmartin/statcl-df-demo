#!/usr/bin/env tclsh


################################################################################
#
# Import des packages nécéssaires, dont les modules colors et logger
#
###############################################################################

package require Tk
package require tile
package require struct::list

tcl::tm::add ..

package require modules::colors
package require modules::logger


################################################################################
#
# Création de la fenêtre principale
#
################################################################################

set w {}

wm title .$w "Disk Free GUI"

#Il y aura un -setgrid dans le logger, donc on exprime la taille en caractères
wm minsize .$w 80 20


################################################################################
#
# Création de la toolbar avec le bouton run et les options
#
################################################################################

set toolbar [ttk::frame $w.toolbar]

set run [ttk::button $toolbar.run -width 0 -text "Lancer df"]
set lb1 [ttk::label $toolbar.lb1 -text "taille en multiple de "]

set hOpt {-h}
set rb1 [ttk::radiobutton $toolbar.rb1 -text "1024 " -variable hOpt -value {-h}]
set rb2 [ttk::radiobutton $toolbar.rb2 -text "1000 " -variable hOpt -value {-H}]

set localOpt {}
set cb1 [ttk::checkbutton $toolbar.cb1 -text "limiter aux FS locaux " \
			 -variable localOpt -onvalue {-l} -offvalue {} ]


################################################################################
#
# Création de deux panneaux redimensionnables pour le contenu
#	- la sortie de df, en colonne, va en haut
#	- la zone de log va en bas
#
################################################################################

set separator [ttk::separator $w.separator -orient horizontal]

set outer [ttk::panedwindow $w.outer -orient vertical -width 480 -height 320]

set top [ttk::frame $outer.top]
set bottom [ttk::frame $outer.bottom]


################################################################################
#
# Création de la zone d'affichage à 3 colonnes pour la sortie de df
#
################################################################################

#Bug ? - Le "é" de Utilsé passe mal !
set colLabels {"Point de montage" "Utilis\u00e9" "Disponible" "Pourcentage"}
set colIds {mount used free percent}
set colWidths {120 100 100 100}

set cols [ttk::treeview $top.cols -columns  $colIds\
			  -show headings -yscroll [list $top.sb set]]

foreach id $colIds label $colLabels width $colWidths {

	$cols heading $id -text $label -anchor w
	$cols column $id -minwidth $width -width $width -stretch 0
}

$cols column mount -stretch 1

set sb [ttk::scrollbar $top.sb -orient vertical -command [list $cols yview]]


################################################################################
#
# Création de la zone de log
#
################################################################################

set log [logger::createFrame $bottom]

lassign [colors::palette Rabbit] \
	infoClr stepClr errClr accentClr outClr verbClr

logger::createStyle $log Step linefg $stepClr accentfg $accentClr spacing 12
logger::createStyle $log Info linefg $infoClr accentfg $accentClr margin 24
logger::createStyle $log Verbose linefg $verbClr accentfg $accentClr margin 24
logger::createStyle $log Cmd linefg $infoClr accentfg $accentClr margin 24
logger::createStyle $log Out linefg $outClr accentfg $accentClr margin 24
logger::createStyle $log Err linefg $errClr accentfg $accentClr margin 24

namespace import logger::log*

logStep "Import commands"
logInfo "Found [lmap p [namespace import] {list <!${p}!>}]"


################################################################################
#
# Placement des éléments de l'interface
#
################################################################################

$outer add $top -weight 1
$outer add $bottom

grid columnconfigure . 0 -weight 1
grid rowconfigure . 2 -weight 1

grid $toolbar -column 0 -row 0 -sticky news
pack $run -side left

#Comme on empile par la droite on commence par le dernier widget (ordre inverse)
pack $cb1 -side right
pack $rb2 -side right
pack $rb1 -side right
pack $lb1 -side right

grid columnconfigure $top 0 -weight 1
grid rowconfigure $top 0 -weight 1

grid columnconfigure $bottom 0 -weight 1
grid rowconfigure $bottom 0 -weight 1

grid $separator -column 0 -row 1 -sticky news
grid $outer -column 0 -row 2 -sticky news

grid $cols -column 0 -row 0 -sticky news
grid $sb -column 1 -row 0 -sticky nes

grid $log -column 0 -row 0 -sticky news


################################################################################
#
# Pour finir, on lie le bouton au code qui lance df et parse sa sortie
#
################################################################################

bind $run <Button-1> {

	$cols delete [$cols children {}]

	logStep "Run df"

	set cmd [subst {exec df $hOpt $localOpt --output=target,used,avail,pcent}]

	logCmd $cmd

	set cmdOut {}
	set cmdErr {}

	if {[catch {set cmdOut [eval $cmd]} cmdErr]} {

		logErr $cmdErr

	} else {

		logOut $cmdOut

		logStep "Parse output"

		set lines [split $cmdOut "\n"]

		set header [::struct::list shift lines]

		logVerbose "Header $header"

		foreach line $lines {

			#On est dans un gestionnaire d'évènement, les % sont substitués !
			#%d par exemple correspond au champ détail d'un ev. On écrit donc
			#%%, qui est une substitution valide, remplacée par un seul %.
			set fields [scan $line "%%s %%s %%s %%d" mount used free percent]

			logVerbose [list Parse mount=<!$mount!> \
							used=<!$used!> free=<!$free!> percent=<!$percent!>]

			if { $fields == 4 } {

				set id [$cols insert {} end -values \
							[list $mount $used $free "$percent %%"]]

			} else {

				logErr "Could not parse line <!$line!>"
			}
		}
	}
}
