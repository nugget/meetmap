#!/usr/bin/env tclsh8.5

package require Pgtcl

proc main {} {
	set filename "../webroot/meetmap.dat"
	set fh [open $filename r]
	while {[gets $fh buf] >= 0} {
		if {[regexp {(.*) -- (.*);} $buf _ meeter meetee]} {
			puts "-- $meeter met $meetee"
			puts "INSERT INTO meetings (meeter,meetee,comments,active) SELECT (SELECT id FROM users WHERE username = [pg_quote $meeter]),(SELECT id FROM users WHERE username = [pg_quote $meetee]),'Imported from Ry data',TRUE;"
			puts "INSERT INTO meetings (meetee,meeter,comments,active) SELECT (SELECT id FROM users WHERE username = [pg_quote $meeter]),(SELECT id FROM users WHERE username = [pg_quote $meetee]),'Imported from Ry data',TRUE;"
		}
	}
	close $fh
}

if !$tcl_interactive main
