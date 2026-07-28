## R CMD check results

0 errors | 0 warnings | 1 note

- `checking CRAN incoming feasibility ... NOTE`
  This is an initial CRAN submission.

## Test environments

- Local Windows 11, R 4.5.1
- macOS latest, R release (GitHub Actions)
- Windows latest, R release (GitHub Actions)
- Ubuntu latest, R devel (GitHub Actions)
- Ubuntu latest, R release (GitHub Actions)
- Ubuntu latest, R oldrel-1 (GitHub Actions)

## Submission notes

This is an initial CRAN submission.

Remote COG retrieval tests are opt-in because they depend on network access and KNB data availability. The standard test suite skips those tests unless `FIREX_RUN_REMOTE_TESTS=true`.
