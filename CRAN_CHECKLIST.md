# CRAN Submission Checklist – solvency2rfr 0.1.0

## Pre-Submission
- [x] R CMD CHECK passed (0 errors, 1 warning, 2 notes — all expected)
- [x] Package version bumped to 0.1.0
- [x] NEWS.md updated with release notes
- [x] GitHub repository created and public
- [x] ORCID included in Authors@R
- [x] All dependencies on CRAN
- [x] No system dependencies required
- [x] License: MIT (standard, permissive, CRAN-approved)

## Package Structure
- [x] DESCRIPTION complete and valid
- [x] NAMESPACE auto-generated via roxygen2
- [x] R/*.R files documented with roxygen2
- [x] man/*.Rd files generated (checked)
- [x] README.md present and informative
- [x] LICENSE and LICENSE.md present
- [x] Vignette created (pre-built in inst/doc/)
- [x] Tests: 25 passing with testthat
- [x] .Rbuildignore properly configured

## Submission Steps

### 1. Prepare the tarball (already done)
```bash
R CMD build rfr --no-build-vignettes
# → solvency2rfr_0.1.0.tar.gz created
```

### 2. Go to https://cran.r-project.org/submit.html

### 3. Fill the form:
- Upload: `solvency2rfr_0.1.0.tar.gz`
- Maintainer email: `janhendrikweinert@gmail.com`
- Comments to CRAN: [paste content from CRAN_SUBMISSION.txt]
- **Check**: "This package may contain things that do not run on all platforms"? **NO**

### 4. Submit and wait for auto-check email

## After Submission

- CRAN auto-check (typically 5–10 minutes)
  - May see email: "CRAN submission solvency2rfr 0.1.0"
  - Usually passes (expected 1 warning, 2 notes are not blockers)
  
- Manual review (typically 24–72 hours)
  - CRAN team may ask for clarifications
  - Turnaround time ~1 week for first submission

- Upon acceptance: Package appears on CRAN, installable via
  ```r
  install.packages("solvency2rfr")
  ```

## File Locations

| File | Purpose |
|------|---------|
| `solvency2rfr_0.1.0.tar.gz` | **Upload this to CRAN** |
| `CRAN_SUBMISSION.txt` | Comments to CRAN (copy-paste) |
| `DESCRIPTION` | Package metadata |
| `NEWS.md` | Release notes |
| `README.md` | User-facing introduction |

## Support

- GitHub Issues: https://github.com/JanWein/solvency2rfr/issues
- CRAN Policy: https://cran.r-project.org/web/packages/policies.html
- R-ext Manual: https://cran.r-project.org/doc/manuals/R-exts.html
