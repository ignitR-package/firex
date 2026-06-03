## R CMD check results

Local Windows check:

0 errors | 0 warnings | 1 note

- `checking CRAN incoming feasibility ... NOTE`
  This is an initial CRAN submission.

Update this section with the final GitHub Actions results before submission.

## Test environments

- Local Windows 11, R 4.5.1
- GitHub Actions:
  - macOS latest, R release
  - Windows latest, R release
  - Ubuntu latest, R devel
  - Ubuntu latest, R release
  - Ubuntu latest, R oldrel-1

## Submission notes

This is an initial CRAN submission.

Remote COG retrieval tests are opt-in because they depend on network access and KNB data availability. The standard test suite skips those tests unless `FIREX_RUN_REMOTE_TESTS=true`.
