build_site:
	Rscript -e "pkgdown::build_site()"

check:
	Rscript -e "devtools::check()"

cran_check:
	Rscript -e "devtools::check_win_devel(quiet = TRUE)"
	Rscript -e "devtools::check_rhub(interactive = FALSE)"
