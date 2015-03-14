#!/bin/sh
perl qc.pl in.txt > out.tex
platex out.tex
dvipdfmx out.dvi
