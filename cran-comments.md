## Test environments

* local OS MS install, R 3.6.0
* Continuous Integration
  * Ubuntu Trusty 14.04 on travis-ci (devel and release)
  * macOS on travis-ci (devel and release)
  * Windows Server 2012 on appveyor (devel and release)
* Rhub
  * Windows Server 2008 R2 SP1, R-devel, 32/64 bit
  * Debian Linux, R-devel, GCC ASAN/UBSAN
  * Fedora Linux, R-devel, clang, gfortran
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

# Problem solved

 * Replaced numerical indexing to regexp for excel file selection.
