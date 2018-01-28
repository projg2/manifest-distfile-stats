PORTDIR = $(shell portageq get_repo_path / gentoo)
GNUPLOT_PREAMBLE = set terminal png size 800,600;

OUT_PNG = \
		  by-filename.png \
		  by-csum.png \
		  by-csum2.png
OUT_TXT = \
		  by-filename.txt \
		  by-sha512sum.txt \
		  by-sha512sum2.txt \
		  by-filename-checksum.txt \
		  by-filename-checksum2.txt
MAN_TXT = all-manifests.txt

all: $(OUT_PNG)
clean:
	rm -f $(OUT_PNG) $(OUT_TXT) $(MAN_TXT)

$(MAN_TXT):
	find $(PORTDIR) -name Manifest -print0 | xargs -n100 -0 cat | sort -u > $@.tmp && mv $@.tmp $@

%.png: %.gnuplot
	gnuplot $<

by-filename.txt: $(MAN_TXT) ./stats.py
	./stats.py filename < $< >$@.tmp && mv $@.tmp $@

by-sha512sum.txt: $(MAN_TXT)
	./stats.py sha512sum < $< > $@.tmp && mv $@.tmp $@

by-sha512sum2.txt: $(MAN_TXT)
	./stats.py sha512sum2 < $< > $@.tmp && mv $@.tmp $@

by-filename-checksum.txt: $(MAN_TXT)
	./stats.py filename_checksum < $< > $@.tmp && mv $@.tmp $@

by-filename-checksum2.txt: $(MAN_TXT)
	./stats.py filename_checksum2 < $< > $@.tmp && mv $@.tmp $@

by-filename.gnuplot: by-filename.txt Makefile
	echo  '$(GNUPLOT_PREAMBLE)' >>$@.tmp
	echo 'set logscale y' >>$@.tmp
	echo 'set output "$(@:.gnuplot=.png)"' >>$@.tmp
	echo 'nth(countCol,labelCol,n) = ((int(column(countCol)) % n == 0) ? stringcolumn(labelCol) : "")' >>$@.tmp
	echo 'plot "by-filename.txt" using 3:xticlabels(2)' >>$@.tmp
	mv $@.tmp $@

by-csum.gnuplot: by-sha512sum.txt by-filename-checksum.txt Makefile
	echo  '$(GNUPLOT_PREAMBLE)' >>$@.tmp
	echo 'set output "$(@:.gnuplot=.png)"' >>$@.tmp
	echo 'nth(countCol,labelCol,n) = ((int(column(countCol)) % n == 0) ? stringcolumn(labelCol) : "")' >>$@.tmp
	echo 'plot "by-sha512sum.txt" using 3:xticlabels(2) \' >>$@.tmp
	echo '   , "by-filename-checksum.txt" using 3:xticlabels(2)' >>$@.tmp
	mv $@.tmp $@

by-csum2.gnuplot: by-sha512sum2.txt by-filename-checksum2.txt Makefile
	echo '$(GNUPLOT_PREAMBLE)' >>$@.tmp
	echo 'set output "$(@:.gnuplot=.png)"' >>$@.tmp
	echo 'nth(countCol,labelCol,n) = ((int(column(countCol)) % n == 0) ? stringcolumn(labelCol) : "")' >>$@.tmp
	echo 'plot "by-sha512sum2.txt"         using 3:xticlabel(nth(1,2,15)) \' >>$@.tmp
	echo '   , "by-filename-checksum2.txt" using 3:xticlabel(nth(1,2,15))  ' >>$@.tmp
	mv $@.tmp $@
