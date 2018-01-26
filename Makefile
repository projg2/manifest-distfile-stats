PORTDIR = $(shell portageq get_repo_path / gentoo)
GNUPLOT_PREAMBLE = set terminal png size 800,600;

OUT_PNG = by-filename.png by-csum.png by-csum2.png
OUT_TXT = by-filename.txt by-sha512sum.txt by-sha512sum2.txt \
	by-filename-checksum.txt by-filename-checksum2.txt
MAN_TXT = all-manifests.txt

all: $(OUT_PNG)
clean:
	rm -f $(OUT_PNG) $(OUT_TXT) $(MAN_TXT)

$(MAN_TXT):
	find $(PORTDIR) -name Manifest -exec cat {} + | sort -u > $@.tmp && mv $@.tmp $@

by-filename.txt: $(MAN_TXT)
	./stats.py filename < $< >$@.tmp && mv $@.tmp $@

by-filename.png: by-filename.txt
	gnuplot -e '$(GNUPLOT_PREAMBLE) set output "$@"; plot "$<" using 2:xticlabels(1)'

by-sha512sum.txt: $(MAN_TXT)
	./stats.py sha512sum < $< > $@.tmp && mv $@.tmp $@

by-sha512sum2.txt: $(MAN_TXT)
	./stats.py sha512sum2 < $< > $@.tmp && mv $@.tmp $@

by-filename-checksum.txt: $(MAN_TXT)
	./stats.py filename_checksum < $< > $@.tmp && mv $@.tmp $@

by-filename-checksum2.txt: $(MAN_TXT)
	./stats.py filename_checksum2 < $< > $@.tmp && mv $@.tmp $@

by-csum.png: by-sha512sum.txt by-filename-checksum.txt
	gnuplot -e '$(GNUPLOT_PREAMBLE) set output "$@"; plot "by-sha512sum.txt" using 2:xticlabels(1), "by-filename-checksum.txt" using 2:xticlabels(1)'

by-csum2.png: by-sha512sum2.txt by-filename-checksum2.txt
	gnuplot -e '$(GNUPLOT_PREAMBLE) set output "$@"; plot "by-sha512sum2.txt" using 2:xticlabels(1), "by-filename-checksum2.txt" using 2:xticlabels(1)'
