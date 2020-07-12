# ihpdr 1.2.1

* Minor changes to accommodate the new format in 2020-Q1 from the IHPD.

# ihpdr 1.2.0

* `ihpd_get()`: now prints the url of the file that is accessing. It can be opted 
out by `verbose = FALSE`.
* `ihpd_get()` has the option to fetch an older version. Note that prior to 
`1201` (2012: Q1) the files are backward compatible, thus output has different format.
* Accessing internet files fail errors have been demoted to messages to comply with
CRAN guidelines and gracefully fail.


# ihpdr 1.1.0

* `ihpd_browse()`: new function that takes you to various webpages associated with international house price database.
* Bug Fix: Replaced numerical indexing to regexp for excel file selection.

# ihpdr 1.0.0.9000

* Added a `NEWS.md` file to track changes to the package.

# ihpdr 1.0.0

* CRAN Release
