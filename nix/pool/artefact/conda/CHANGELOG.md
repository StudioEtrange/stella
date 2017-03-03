## 4.4.0 (unreleased)

### New Features
* general support for all bourne- and c-based shells (#3175)

### Deprecations/Breaking Changes
* The default channel repo.continuum.io/pkgs/free is moved to
  repo.continuum.io/pkgs/anaconda (#4635)

### Improvements
* filter out unwritable package caches from conda clean command (#4620)

### Non-User-Facing Changes
* eliminate index modification in Resolve.__init__ (#4333)


## 4.3.14 (unreleased)

### Improvements
* use cPickle in place of pickle for repodata (#4717)
* ignore pyc compile failure (#4719)
* use conda.exe for windows entry point executable (#4716, #4720)
* localize use of conda_signal_handler (#4730)
* add skip_safety_checks configuration parameter (#4767)

### Bug Fixes
* fix #4703 menuinst PathNotFoundException (#4709)
* ignore permissions error if user_site can't be read (#4710)
* fix #4694 don't import requests directly in models (#4711)
* fix #4715 include resources directory in recipe (#4716)
* fix CondaHttpError for URLs that contain '%' (#4769)
* bug fixes for preferred envs (#4678)
* fix #4745 check for info/index.json with package is_extracted (#4776)

### Non-User-Facing Changes
* test coverage improvement (#4607)
* CI configuration improvements (#4713, #4773, #4775)
* allow sha256 to be None (#4759)
* add cache_fn_url to exports (#4729)


## 4.3.13 (2017-02-17)

### Improvements
* resolve #4636 environment variable expansion for pkgs_dirs (#4637)
* link, symlink, islink, and readlink for Windows (#4652, #4661)
* add extra information to CondaHTTPError (#4638, #4672)

### Bug Fixes
* maximize requested builds after feature determination (#4647)
* fix #4649 incorrect assert statement concerning package cache directory (#4651)
* multi-user mode bug fixes (#4663)

### Non-User-Facing Changes
* path_actions unit tests (#4654)
* remove dead code (#4369, #4655, #4660)
* separate repodata logic from index into a new core/repodata.py module (#4669)


## 4.3.12 (2017-02-14)

### Improvements
* prepare conda for uploading to pypi (#4619)
* better general http error message (#4627)
* disable old python noarch warning (#4576)

### Bug Fixes
* fix UnicodeDecodeError for ensure_text_type (#4585)
* fix determination of if file path is writable (#4604)
* fix #4592 BufferError cannot close exported pointers exist (#4628)
* fix run_script current working directory (#4629)
* fix pkgs_dirs permissions regression (#4626)

### Non-User-Facing Changes
* fixes for tests when conda-bld directory doesn't exist (#4606)
* use requirements.txt and Makefile for travis-ci setup (#4600, #4633)
* remove hasattr use from compat functions (#4634)


## 4.3.11 (2017-02-09)

### Bug Fixes
* fix attribute error in add_defaults_to_specs (#4577)


## 4.3.10 (2017-02-07)

### Improvements
* remove .json from pickle path (#4498)
* improve empty repodata noarch warning and error messages (#4499)
* don't add python and lua as default specs for private envs (#4529, #4533)
* let default_python be None (#4547, #4550)

### Bug Fixes
* fix #4513 null pointer exception for channel without noarch (#4518)
* fix ssl_verify set type (#4517)
* fix bug for windows multiuser (#4524)
* fix clone with noarch python packages (#4535)
* fix ipv6 for python 2.7 on Windows (#4554)

### Non-User-Facing Changes
* separate integration tests with a marker (#4532)


## 4.3.9 (2017-01-31)

### Improvements
* improve repodata caching for performance (#4478, #4488)
* expand scope of packages included by bad_installed (#4402)
* silence pre-link warning for old noarch (#4451)
* add configuration to optionally require noarch repodata (#4450)
* improve conda subprocessing (#4447)
* respect info/link.json (#4482)

### Bug Fixes
* fix #4398 'hard' was used for link type at one point (#4409)
* fixed "No matches for wildcard '$activate_d/*.fish'" warning (#4415)
* print correct activate/deactivate message for fish shell (#4423)
* fix 'Dist' object has no attribute 'fn' (#4424)
* fix noarch generic and add additional integration test (#4431)
* fix #4425 unknown encoding (#4433)

### Non-User-Facing Changes
* fail CI on conda-build fail (#4405)
* run doctests (#4414)
* make index record mutable again (#4461)
* additional test for conda list --json (#4480)


## 4.3.8 (2017-01-23)

### Bug Fixes
* fix #4309 ignore EXDEV error for directory renames (#4392)
* fix #4393 by force-renaming certain backup files if the path already exists (#4397)


## 4.3.7 (2017-01-20)

### Bug Fixes
* actually revert json output for leaky plan (#4383)
* fix not raising on pre/post-link error (#4382)
* fix find_commands and find_executable for symlinks (#4387)


## 4.3.6 (2017-01-18)

### Bug Fixes
* fix 'Uncaught backoff with errno 41' warning on windows (#4366)
* revert json output for leaky plan (#4349)
* audit os.environ setting (#4360)
* fix #4324 using old dist string instead of dist object (#4361)
* fix #4351 infinite recursion via code in #4120 (#4370)
* fix #4368 conda -h (#4367)
* workaround for symlink race conditions on activate (#4346)


## 4.3.5 (2017-01-17)

### Improvements
* add exception message for corrupt repodata (#4315)

### Bug Fixes
* fix package not being found in cache after download (#4297)
* fix logic for Content-Length mismatch (#4311, #4326)
* use unicode_escape after etag regex instead of utf-8 (#4325)
* fix #4323 central condarc file being ignored (#4327)
* fix #4316 a bug in deactivate (#4316)
* pass target_prefix as env_prefix regardless of is_unlink (#4332)
* pass positional argument 'context' to BasicClobberError (#4335)

### Non-User-Facing Changes
* additional package pinning tests (#4317)


## 4.3.4 (2017-01-13)

### Improvements
* vendor url parsing from urllib3 (#4289)

### Bug Fixes
* fix some bugs in windows multi-user support (#4277)
* fix problems with channels of type <unknown> (#4290)
* include aliases for first command-line argument (#4279)
* fix for multi-line FTP status codes (#4276)

### Non-User-Facing Changes
* make arch in IndexRecord a StringField instead of EnumField
* improve conda-build compatibility (#4266)


## 4.3.3 (2017-01-10)

### Improvements
* respect Cache-Control max-age header for repodata (#4220)
* add 'local_repodata_ttl' configurability (#4240)
* remove questionable "nothing to install" logic (#4237)
* relax channel noarch requirement for 4.3; warn now, raise in future feature release (#4238)
* add additional info to setup.py warning message (#4258)

### Bug Fixes
* remove features properly (#4236)
* do not use `IFS` to find activate/deactivate scripts to source (#4239)
* fix #4235 print message to stderr (#4241)
* fix relative path to python in activate.bat (#4242)
* fix args.channel references (#4245, #4246)
* ensure cache_fn_url right pad (#4255)
* fix #4256 subprocess calls must have env wrapped in str (#4259)


## 4.3.2 (2017-01-06)

### Deprecations/Breaking Changes
* Further refine conda channels specification. To verify if the url of a channel
  represents a valid conda channel, we check that `noarch/repodata.json` and/or
  `noarch/repodata.json.bz2` exist, even if empty. (#3739)

### Improvements
* add new 'path_conflict' and 'clobber' configuration options (#4119)
* separate fetch/extract pass for explicit URLs (#4125)
* update conda homepage to conda.io (#4180)

### Bug Fixes
* fix pre/post unlink/link scripts (#4113)
* fix package version regex and bug in create_link (#4132)
* fix history tracking (#4143)
* fix index creation order (#4131)
* fix #4152 conda env export failure (#4175)
* fix #3779 channel UNC path encoding errors on windows (#4190)
* fix progress bar (#4191)
* use context.channels instead of args.channel (#4199)
* don't use local cached repodata for file:// urls (#4209)

### Non-User-Facing Changes
* xfail anaconda token test if local token is found (#4124)
* fix open-ended test failures relating to python 3.6 release (#4145)
* extend timebomb for test_multi_channel_export (#4169)
* don't unlink dists that aren't in the index (#4130)
* add python 3.6 and new conda-build test targets (#4194)



## 4.3.1 (2016-12-19)

### Improvements
* additional pre-transaction validation (#4090)
* export FileMode enum for conda-build (#4080)
* memoize disk permissions tests (#4091)
* local caching of repodata without remote server calls; new 'repodata_timeout_secs'
  configuration parameter (#4094)
* performance tuning (#4104)
* add additional fields to dist object serialization (#4102)

### Bug Fixes
* fix a noarch install bug on windows (#4071)
* fix a spec mismatch that resulted in python versions getting mixed during packaging (#4079)
* fix rollback linked record (#4092)
* fix #4097 keep split in PREFIX_PLACEHOLDER (#4100)


## 4.3.0 (2016-12-14)  Safety

### New Features
* **Unlink and Link Packages in a Single Transaction**: In the past, conda hasn't always been safe
  and defensive with its disk-mutating actions. It has gleefully clobbered existing files, and
  mid-operation failures leave environments completely broken. In some of the most severe examples,
  conda can appear to "uninstall itself." With this release, the unlinking and linking of packages
  for an executed command is done in a single transaction. If a failure occurs for any reason
  while conda is mutating files on disk, the environment will be returned its previous state.
  While we've implemented some pre-transaction checks (verifying package integrity for example),
  it's impossible to anticipate every failure mechanism. In some circumstances, OS file
  permissions cannot be fully known until an operation is attempted and fails. And conda itself
  is not without bugs. Moving forward, unforeseeable failures won't be catastrophic. (#3833, #4030)

* **Progressive Fetch and Extract Transactions**: Like package unlinking and linking, the
  download and extract phases of package handling have also been given transaction-like behavior.
  The distinction is the rollback on error is limited to a single package. Rather than rolling back
  the download and extract operation for all packages, the single-package rollback prevents the
  need for having to re-download every package if an error is encountered. (#4021, #4030)

* **Generic- and Python-Type Noarch/Universal Packages**: Along with conda-build 2.1.0, a
  noarch/universal type for python packages is officially supported. These are much like universal
  python wheels. Files in a python noarch package are linked into a prefix just like any other
  conda package, with the following additional features
  1. conda maps the `site-packages` directory to the correct location for the python version
     in the environment,
  2. conda maps the python-scripts directory to either $PREFIX/bin or $PREFIX/Scripts depending
     on platform,
  3. conda creates the python entry points specified in the conda-build recipe, and
  4. conda compiles pyc files at install time when prefix write permissions are guaranteed.

  Python noarch packages must be "fully universal."  They cannot have OS- or
  python version-specific dependencies.  They cannot have OS- or python version-specific "scripts"
  files. If these features are needed, traditional conda packages must be used. (#3712)

* **Multi-User Package Caches**: While the on-disk package cache structure has been preserved,
  the core logic implementing package cache handling has had a complete overhaul.  Writable and
  read-only package caches are fully supported. (#4021)

* **Python API Module**: An oft requested feature is the ability to use conda as a python library,
  obviating the need to "shell out" to another python process. Conda 4.3 includes a
  `conda.cli.python_api` module that facilitates this use case. While we maintain the user-facing
  command-line interface, conda commands can be executed in-process. There is also a
  `conda.exports` module to facilitate longer-term usage of conda as a library across conda
  conda releases.  However, conda's python code *is* considered internal and private, subject
  to change at any time across releases. At the moment, conda will not install itself into
  environments other than its original install environment. (#4028)

* **Remove All Locks**:  Locking has never been fully effective in conda, and it often created a
  false sense of security. In this release, multi-user package cache support has been
  implemented for improved safety by hard-linking packages in read-only caches to the user's
  primary user package cache. Still, users are cautioned that undefined behavior can result when
  conda is running in multiple process and operating on the same package caches and/or
  environments. (#3862)

### Deprecations/Breaking Changes
* Conda will refuse to clobber existing files that are not within the unlink instructions of
  the transaction. At the risk of being user-hostile, it's a step forward for conda. We do
  anticipate some growing pains. For example, conda will not clobber packages that have been
  installed with pip (or any other package manager). In other instances, conda packages that
  contain overlapping file paths but are from different package families will not install at
  the same time. The `--force` command line flag is the escape hatch. Using `--force` will
  let your operation proceed, but also makes clear that you want conda to do something it
  considers unsafe.
* Conda signed packages have been removed in 4.3. Vulnerabilities existed. An illusion of security
  is worse than not having the feature at all.  We will be incorporating The Update Framework
  into conda in a future feature release. (#4064)
* Conda 4.4 will drop support for older versions of conda-build.

### Improvements
* create a new "trace" log level enabled by `-v -v -v` or `-vvv` (#3833)
* allow conda to be installed with pip, but only when used as a library/dependency (#4028)
* the 'r' channel is now part of defaults (#3677)
* private environment support for conda (#3988)
* support v1 info/paths.json file (#3927, #3943)
* support v1 info/package_metadata.json (#4030)
* improved solver hint detection, simplified filtering (#3597)
* cache VersionOrder objects to improve performance (#3596)
* fix documentation and typos (#3526, #3572, #3627)
* add multikey configuration validation (#3432)
* some Fish autocompletions (#2519)
* reduce priority for packages removed from the index (#3703)
* add user-agent, uid, gid to conda info (#3671)
* add conda.exports module (#3429)
* make http timeouts configurable (#3832)
* add a pkgs_dirs config parameter (#3691)
* add an 'always_softlink' option (#3870, #3876)
* pre-checks for diskspace, etc for fetch and extract #(4007)
* address #3879 don't print activate message when quiet config is enabled (#3886)
* add zos-z subdir (#4060)
* add elapsed time to HTTP errors (#3942)

### Bug Fixes
* account for the Windows Python 2.7 os.environ unicode aversion (#3363)
* fix link field in record object (#3424)
* anaconda api token bug fix; additional tests (#3673)
* fix #3667 unicode literals and unicode decode (#3682)
* add conda-env entrypoint (#3743)
* fix #3807 json dump on conda config --show --json (#3811)
* fix #3801 location of temporary hard links of index.json (#3813)
* fix invalid yml example (#3849)
* add arm platforms back to subdirs (#3852)
* fix #3771 better error message for assertion errors (#3802)
* fix #3999 spaces in shebang replacement (#4008)
* config --show-sources shouldn't show force by default (#3891)
* fix #3881 don't install conda-env in clones of root (#3899)
* conda-build dist compatibility (#3909)

### Non-User-Facing Changes
* remove unnecessary eval (#3428)
* remove dead install_tar function (#3641)
* apply PEP-8 to conda-env (#3653)
* refactor dist into an object (#3616)
* vendor appdirs; remove conda's dependency on anaconda-client import (#3675)
* revert boto patch from #2380 (#3676)
* move and update ROOT_NO_RM (#3697)
* integration tests for conda clean (#3695, #3699)
* disable coverage on s3 and ftp requests adapters (#3696, #3701)
* github repo hygiene (#3705, #3706)
* major install refactor (#3712)
* remove test timebombs (#4012)
* LinkType refactor (#3882)
* move CrossPlatformStLink and make available as export (#3887)
* make Record immutable (#3965)
* project housekeeping (#3994, #4065)
* context-dependent setup.py files (#4057)


## 4.2.17 (unreleased)

## Improvements
* silence pre-link warning for old noarch 4.2.x backport (#4453)

### Non-User-Facing Changes
* build 4.2.x against conda-build 2.1.2 and enforce passing (#4462)


## 4.2.16 (2017-01-20)

### Improvements
* vendor url parsing from urllib3 (#4289)
* workaround for symlink race conditions on activate (#4346)

### Bug Fixes
* do not replace \ with / in file:// URLs on Windows (#4269)
* include aliases for first command-line argument (#4279)
* fix for multi-line FTP status codes (#4276)
* fix errors with unknown type channels (#4291)
* change sys.exit to raise UpgradeError when info/files not found (#4388)

### Non-User-Facing Changes
* start using doctests in test runs and coverage (#4304)
* additional package pinning tests (#4312)


## 4.2.15 (2017-01-10)

### Improvements
* use 'post' instead of 'dev' for commits according to PEP-440 (#4234)
* do not use IFS to find activate/deactivate scripts to source (#4243)
* fix relative path to python in activate.bat (#4244)

### Bug Fixes
* replace sed with python for activate and deactivate #4257


## 4.2.14 (2017-01-07)

### Improvements
* use install.rm_rf for TemporaryDirectory cleanup (#3425)
* improve handling of local dependency information (#2107)
* add default channels to exports for Windows and Unix (#4103)
* make subdir configurable (#4178)

### Bug Fixes
* fix conda/install.py single-file behavior (#3854)
* fix the api->conda substitution (#3456)
* fix silent directory removal (#3730)
* fix location of temporary hard links of index.json (#3975)
* fix potential errors in multi-channel export and offline clone (#3995)
* fix auxlib/packaging, git hashes are not limited to 7 characters (#4189)
* fix compatibility with requests >=2.12, add pyopenssl as dependency (#4059)
* fix #3287 activate in 4.1-4.2.3 clobbers non-conda PATH changes (#4211)

### Non-User-Facing Changes
* fix open-ended test failures relating to python 3.6 release (#4166)
* allow args passed to cli.main() (#4193, #4200, #4201)
* test against python 3.6 (#4197)


## 4.2.13 (2016-11-22)

### Deprecations/Breaking Changes
* show warning message for pre-link scripts (#3727)
* error and exit for install of packages that require conda minimum version 4.3 (#3726)

### Improvements
* double/extend http timeouts (#3831)
* let descriptive http errors cover more http exceptions (#3834)
* backport some conda-build configuration (#3875)

### Bug Fixes
* fix conda/install.py single-file behavior (#3854)
* fix the api->conda substitution (#3456)
* fix silent directory removal (#3730)
* fix #3910 null check for is_url (#3931)

### Non-User-Facing Changes
* flake8 E116, E121, & E123 enabled (#3883)


## 4.2.12 (2016-11-02)

### Bug Fixes

* fix #3732, #3471, #3744 CONDA_BLD_PATH (#3747)
* fix #3717 allow no-name channels (#3748)
* fix #3738 move conda-env to ruamel_yaml (#3740)
* fix conda-env entry point (#3745 via #3743)
* fix again #3664 trash emptying (#3746)


## 4.2.11 (2016-10-23)

### Improvements
* only try once for windows trash removal (#3698)

### Bug Fixes
* fix anaconda api token bug (#3674)
* fix #3646 FileMode enum comparison (#3683)
* fix #3517 conda install --mkdir (#3684)
* fix #3560 hack anaconda token coverup on conda info (#3686)
* fix #3469 alias envs_path to envs_dirs (#3685)


## 4.2.10 (2016-10-18)

### Improvements
* add json output for `conda info -s` (#3588)
* ignore certain binary prefixes on windows (#3539)
* allow conda config files to have .yaml extensions or 'condarc' anywhere in filename (#3633)

### Bug Fixes
* fix conda-build's handle_proxy_407 import (#3666)
* fix #3442, #3459, #3481, #3531, #3548 multiple networking and auth issues (#3550)
* add back linux-ppc64le subdir support (#3584)
* fix #3600 ensure links are removed when unlinking (#3625)
* fix #3602 search channels by platform (#3629)
* fix duplicated packages when updating environment (#3563)
* fix #3590 exception when parsing invalid yaml (#3593 via #3634)
* fix #3655 a string decoding error (#3656)

### Non-User-Facing Changes
* backport conda.exports module to 4.2.x (#3654)
* travis-ci OSX fix (#3615 via #3657)


## 4.2.9 (2016-09-27)

### Bug Fixes
* fix #3536 conda-env messaging to stdout with --json flag (#3537)
* fix #3525 writing to sys.stdout with --json flag for post-link scripts (#3538)
* fix #3492 make NULL falsey with python 3 (#3524)


## 4.2.8 (2016-09-26)

### Improvements
* add "error" key back to json error output (#3523)

### Bug Fixes
* fix #3453 conda fails with create_default_packages (#3454)
* fix #3455 --dry-run fails (#3457)
* dial down error messages for rm_rf (#3522)
* fix #3467 AttributeError encountered for map config parameter validation (#3521)


## 4.2.7 (2016-09-16)

### Deprecations/Breaking Changes
* revert to 4.1.x behavior of `conda list --export` (#3450, #3451)

### Bug Fixes
* don't add binstar token if it's given in the channel spec (#3427, #3440, #3444)
* fix #3433 failure to remove broken symlinks (#3436)

### Non-User-Facing Changes
* use install.rm_rf for TemporaryDirectory cleanup (#3425)


## 4.2.6 (2016-09-14)

### Improvements
* add support for client TLS certificates (#3419)
* address #3267 allow migration of channel_alias (#3410)
* conda-env version matches conda version (#3422)

### Bug Fixes
* fix #3409 unsatisfiable dependency error message (#3412)
* fix #3408 quiet rm_rf (#3413)
* fix #3407 padding error messaging (#3416)
* account for the Windows Python 2.7 os.environ unicode aversion (#3363 via #3420)


## 4.2.5 (2016-09-08)

### Deprecations/Breaking Changes
* partially revert #3041 giving conda config --add previous --prepend behavior (#3364 via #3370)
* partially revert #2760 adding back conda package command (#3398)

### Improvements
* order output of conda config --show; make --json friendly (#3384 via #3386)
* clean the pid based lock on exception (#3325)
* improve file removal on all platforms (#3280 via #3396)

### Bug Fixes
* fix #3332 allow download urls with :: in them (#3335)
* fix always_yes and not-set argparse args overriding other sources (#3374)
* fix ftp fetch timeout (#3392)
* fix #3307 add try/except block for touch lock (#3326)
* fix CONDA_CHANNELS environment variable splitting (#3390)
* fix #3378 CONDA_FORCE_32BIT environment variable (#3391)
* make conda info channel urls actually give urls (#3397)
* fix cio_test compatibility (#3395 via #3400)


## 4.2.4 (2016-08-18)

### Bug Fixes
* fix #3277 conda list package order (#3278)
* fix channel priority issue with duplicated channels (#3283)
* fix local channel channels; add full conda-build unit tests (#3281)
* fix conda install with no package specified (#3284)
* fix #3253 exporting and importing conda environments (#3286)
* fix priority messaging on conda config --get (#3304)
* fix conda list --export; additional integration tests (#3291)
* fix conda update --all idempotence; add integration tests for channel priority (#3306)

### Non-User-Facing Changes
* additional conda-env integration tests (#3288)


## 4.2.3 (2016-08-11)

### Improvements
* added zsh and zsh.exe to Windows shells (#3257)

### Bug Fixes
* allow conda to downgrade itself (#3273)
* fix breaking changes to conda-build from 4.2.2 (#3265)
* fix empty environment issues with conda and conda-env (#3269)

### Non-User-Facing Changes
* add integration tests for conda-env (#3270)
* add more conda-build smoke tests (#3274)


## 4.2.2 (2016-08-09)

### Improvements
* enable binary prefix replacement on windows (#3262)
* add `--verbose` command line flag (#3237)
* improve logging and exception detail (#3237, #3252)
* do not remove empty environment without asking; raise an error when a named environment
  can't be found (#3222)

### Bug Fixes
* fix #3226 user condarc not available on Windows (#3228)
* fix some bugs in conda config --show* (#3212)
* fix conda-build local channel bug (#3202)
* remove subprocess exiting message (#3245)
* fix comment parsing and channels in conda-env environment.yml (#3258, #3259)
* fix context error with conda-env (#3232)
* fix #3182 conda install silently skipping failed linking (#3184)


## 4.2.1 (2016-08-01)

### Improvements
* improve an error message that can happen during conda install --revision (#3181)
* use clean sys.exit with user choice 'No' (#3196)

### Bug Fixes
* critical fix for 4.2.0 error when no git is on PATH (#3193)
* revert #3171 lock cleaning on exit pending further refinement
* patches for conda-build compatibility with 4.2 (#3187)
* fix a bug in --show-sources output that ignored aliased parameter names (#3189)

### Non-User-Facing Changes
* move scripts in bin to shell directory (#3186)


## 4.2.0 (2016-07-28)  Configuration

### New Features
* **New Configuration Engine**: Configuration and "operating context" are the foundation of
  conda's functionality. Conda now has the ability to pull configuration information from a
  multitude of on-disk locations, including `.d` directories and a `.condarc` file *within*
  a conda environment), along with full `CONDA_` environment variable support. Helpful
  validation errors are given for improperly-specified configuration. Full documentation
  updates pending. (#2537, #3160, #3178)
* **New Exception Handling Engine**: Previous releases followed a pattern of premature exiting
  (with hard calls to `sys.exit()` when exceptional circumstances were encountered. This
  release replaces over 100 `sys.exit` calls with python exceptions.  For conda developers,
  this will result in tests that are easier to write.  For developers using conda, this is a
  first step on a long path toward conda being directly importable.  For conda users, this will
  eventually result in more helpful and descriptive errors messages.
  (#2899, #2993, #3016, #3152, #3045)
* **Empty Environments**: Conda can now create "empty" environments when no initial packages
  are specified, alleviating a common source of confusion. (#3072, #3174)
* **Conda in Private Env**: Conda can now be configured to live within its own private
  environment.  While it's not yet default behavior, this represents a first step toward
  separating the `root` environment into a "conda private" environment and a "user default"
  environment. (#3068)
* **Regex Version Specification**: Regular expressions are now valid version specifiers.
  For example, `^1\.[5-8]\.1$|2.2`. (#2933)

### Deprecations/Breaking Changes
* remove conda init (#2759)
* remove conda package and conda bundle (#2760)
* deprecate conda-env repo; pull into conda proper (#2950, #2952, #2954, #3157, #3163, #3170)
* force use of ruamel_yaml (#2762)
* implement conda config --prepend; change behavior of --add to --append (#3041)
* exit on link error instead of logging it (#2639)

### Improvements
* improve locking (#2962, #2989, #3048, #3075)
* clean up requests usage for fetching packages (#2755)
* remove excess output from conda --help (#2872)
* remove os.remove in update_prefix (#3006)
* better error behavior if conda is spec'd for a non-root environment (#2956)
* scale back try_write function on unix (#3076)

### Bug Fixes
* remove psutil requirement, fixes annoying error message (#3135, #3183)
* fix #3124 add threading lock to memoize (#3134)
* fix a failure with multi-threaded repodata downloads (#3078)
* fix windows file url (#3139)
* address #2800, error with environment.yml and non-default channels (#3164)

### Non-User-Facing Changes
* project structure enhancement (#2929, #3132, #3133, #3136)
* clean up channel handling with new channel model (#3130, #3151)
* add Anaconda Cloud / Binstar auth handler (#3142)
* remove dead code (#2761, #2969)
* code refactoring and additional tests (#3052, #3020)
* remove auxlib from project root (#2931)
* vendor auxlib 0.0.40 (#2932, #2943, #3131)
* vendor toolz 0.8.0 (#2994)
* move progressbar to vendor directory (#2951)
* fix conda.recipe for new quirks with conda-build (#2959)
* move captured function to common module (#3083)
* rename CHANGELOG to md (#3087)


## 4.1.13 (unreleased)

* improve handling of local dependency information, #2107
* show warning message for pre-link scripts, #3727
* error and exit for install of packages that require conda minimum version 4.3, #3726
* fix conda/install.py single-file behavior, #3854
* fix open-ended test failures relating to python 3.6 release, #4167
* fix #3287 activate in 4.1-4.2.3 clobbers non-conda PATH changes, #4211
* fix relative path to python in activate.bat, #4244


## 4.1.12 (2016-09-08)

* fix #2837 "File exists" in symlinked path with parallel activations, #3210
* fix prune option when installing packages, #3354
* change check for placeholder to be more friendly to long PATH, #3349


## 4.1.11 (2016-07-26)

* fix PS1 backup in activate script, #3135 via #3155
* correct resolution for 'handle failures in binstar_client more generally', #3156


## 4.1.10 (2016-07-25)

* ignore symlink failure because of read-only file system, #3055
* backport shortcut tests, #3064
* fix #2979 redefinition of $SHELL variable, #3081
* fix #3060 --clone root --copy exception, #3080


## 4.1.9 (2016-07-20)

* fix #3104, add global BINSTAR_TOKEN_PAT
* handle failures in binstar_client more generally


## 4.1.8 (2016-07-12)

* fix #3004 UNAUTHORIZED for url (null binstar token), #3008
* fix overwrite existing redirect shortcuts when symlinking envs, #3025
* partially revert no default shortcuts, #3032, #3047


## 4.0.11 2016-07-09

* allow auto_update_conda from sysrc, #3015 via #3021


## 4.1.7 (2016-07-07)

* add msys2 channel to defaults on Windows, #2999
* fix #2939 channel_alias issues; improve offline enforcement, #2964
* fix #2970, #2974 improve handling of file:// URLs inside channel, #2976


## 4.1.6 (2016-07-01)

* slow down exp backoff from 1 ms to 100 ms factor, #2944
* set max time on exp_backoff to ~6.5 sec,#2955
* fix #2914 add/subtract from PATH; kill folder output text, #2917
* normalize use of get_index behavior across clone/explicit, #2937
* wrap root prefix check with normcase, #2938


## 4.1.5 (2016-06-29)

* more conservative auto updates of conda #2900
* fix some permissions errors with more aggressive use of move_path_to_trash, #2882
* fix #2891 error if allow_other_channels setting is used, #2896
* fix #2886, #2907 installing a tarball directly from the package cache, #2908
* fix #2681, #2778 reverting #2320 lock behavior changes, #2915


## 4.0.10 (2016-06-29)

* fix #2846 revert the use of UNC paths; shorten trash filenames, #2859 via #2878
* fix some permissions errors with more aggressive use of move_path_to_trash, #2882 via #2894


## 4.1.4 (2016-06-27)

* fix #2846 revert the use of UNC paths; shorten trash filenames, #2859
* fix exp backoff on Windows, #2860
* fix #2845 URL for local file repos, #2862
* fix #2764 restore full path var on win; create to CONDA_PREFIX env var, #2848
* fix #2754 improve listing pip installed packages, #2873
* change root prefix detection to avoid clobbering root activate scripts, #2880
* address #2841 add lowest and highest priority indication to channel config output, #2875
* add SYMLINK_CONDA to planned instructions, #2861
* use CONDA_PREFIX, not CONDA_DEFAULT_ENV for activate.d, #2856
* call scripts with redirect on win; more error checking to activate, #2852


## 4.1.3 (2016-06-23)

* ensure conda-env auto update, along with conda, #2772
* make yaml booleans behave how everyone expects them to, #2784
* use accept-encoding for repodata; prefer repodata.json to repodata.json.bz2, #2821
* additional integration and regression tests, #2757, #2774, #2787
* add offline mode to printed info; use offline flag when grabbing channels, #2813
* show conda-env version in conda info, #2819
* adjust channel priority superseded list, #2820
* support epoch ! characters in command line specs, #2832
* accept old default names and new ones when canonicalizing channel URLs #2839
* push PATH, PS1 manipulation into shell scripts, #2796
* fix #2765 broken source activate without arguments, #2806
* fix standalone execution of install.py, #2756
* fix #2810 activating conda environment broken with git bash on Windows, #2795
* fix #2805, #2781 handle both file-based channels and explicit file-based URLs, #2812
* fix #2746 conda create --clone of root, #2838
* fix #2668, #2699 shell recursion with activate #2831


## 4.1.2 (2016-06-17)

* improve messaging for "downgrades" due to channel priority, #2718
* support conda config channel append/prepend, handle duplicates, #2730
* remove --shortcuts option to internal CLI code, #2723
* fix an issue concerning space characters in paths in activate.bat, #2740
* fix #2732 restore yes/no/on/off for booleans on the command line, #2734
* fix #2642 tarball install on Windows, #2729
* fix #2687, #2697 WindowsError when creating environments on Windows, #2717
* fix #2710 link instruction in conda create causes TypeError, #2715
* revert #2514, #2695, disabling of .netrc files, #2736
* revert #2281 printing progress bar to terminal, #2707


## 4.1.1 (2016-06-16)

* add auto_update_conda config parameter, #2686
* fix #2669 conda config --add channels can leave out defaults, #2670
* fix #2703 ignore activate symlink error if links already exist, #2705
* fix #2693 install duplicate packages with older version of Anaconda, #2701
* fix #2677 respect HTTP_PROXY, #2695
* fix #2680 broken fish integration, #2685, #2694
* fix an issue with conda never exiting, #2689
* fix #2688 explicit file installs, #2708
* fix #2700 conda list UnicodeDecodeError, #2706


## 4.0.9 (2016-06-15)

* add auto_update_conda config parameter, #2686


## 4.1.0 (2016-06-14)  Channel Priority

* clean up activate and deactivate scripts, moving back to conda repo, #1727,
  #2265, #2291, #2473, #2501, #2484
* replace pyyaml with ruamel_yaml, #2283, #2321
* better handling of channel collisions, #2323, #2369 #2402, #2428
* improve listing of pip packages with conda list, #2275
* re-license progressbar under BSD 3-clause, #2334
* reduce the amount of extraneous info in hints, #2261
* add --shortcuts option to install shortcuts on windows, #2623
* skip binary replacement on windows, #2630
* don't show channel urls by default in conda list, #2282
* package resolution and solver tweaks, #2443, #2475, #2480
* improved version & build matching, #2442, #2488
* print progress to the terminal rather than stdout, #2281
* verify version specs given on command line are valid, #2246
* fix for try_write function in case of odd permissions, #2301
* fix a conda search --spec error, #2343
* update User-Agent for conda connections, #2347
* remove some dead code paths, #2338, #2374
* fixes a thread safety issue with http requests, #2377, #2383
* manage BeeGFS hard-links non-POSIX configuration, #2355
* prevent version downgrades during removes, #2394
* fix conda info --json, #2445
* truncate shebangs over 127 characters using /usr/bin/env, #2479
* extract packages to a temporary directory then rename, #2425, #2483
* fix help in install, #2460
* fix re-install bug when sha1 differs, #2507
* fix a bug with file deletion, #2499
* disable .netrc files, #2514
* dont fetch index on remove --all, #2553
* allow track_features to be a string *or* a list in .condarc, #2541
* fix #2415 infinite recursion in invalid_chains, #2566
* allow channel_alias to be different than binstar, #2564


## 4.0.8 (2016-06-03)

* fix a potential problem with moving files to trash, #2587


## 4.0.7 (2016-05-26)

* workaround for boto bug, #2380


## 4.0.6 (2016-05-11)

* log "custom" versions as updates rather than downgrades, #2290
* fixes a TypeError exception that can occur on install/update, #2331
* fixes an error on Windows removing files with long path names, #2452


## 4.0.5 (2016-03-16)

* improved help documentation for install, update, and remove, #2262
* fixes #2229 and #2250 related to conda update errors on Windows, #2251
* fixes #2258 conda list for pip packages on Windows, #2264


## 4.0.4 (2016-03-10)

* revert #2217 closing request sessions, #2233


## 4.0.3 (2016-03-10)

* adds a `conda clean --all` feature, #2211
* solver performance improvements, #2209
* fixes conda list for pip packages on windows, #2216
* quiets some logging for package downloads under python 3, #2217
* more urls for `conda list --explicit`, #1855
* prefer more "latest builds" for more packages, #2227
* fixes a bug with dependency resolution and features, #2226


## 4.0.2 (2016-03-08)

* fixes track_features in ~/.condarc being a list, see also #2203
* fixes incorrect path in lock file error #2195
* fixes issues with cloning environments, #2193, #2194
* fixes a strange interaction between features and versions, #2206
* fixes a bug in low-level SAT clause generation creating a
  preference for older versions, #2199


## 4.0.1 (2016-03-07)

* fixes an install issue caused by md5 checksum mismatches, #2183
* remove auxlib build dependency, #2188


## 4.0.0 (2016-03-04)  Solver

* The solver has been retooled significantly. Performance
  should be improved in most circumstances, and a number of issues
  involving feature conflicts should be resolved.
* `conda update <package>` now handles depedencies properly
  according to the setting of the "update_deps" configuration:
      --update-deps: conda will also update any dependencies as needed
                     to install the latest verison of the requrested
                     packages.  The minimal set of changes required to
                     achieve this is sought.
      --no-update-deps: conda will update the packages *only* to the
                     extent that no updates to the dependencies are
                     required
  The previous behavior, which would update the packages without regard to
  their dependencies, could result in a broken configuration, and has been
  removed.
* Conda finally has an official logo.
* Fix `conda clean --packages` on Windows, #1944
* Conda sub-commands now support dashes in names, #1840


3.19.4 (unreleased):
--------------------
  * improve handling of local dependency information, #2107
  * use install.rm_rf for TemporaryDirectory cleanup, #3425
  * fix the api->conda substitution, #3456
  * error and exit for install of packages that require conda minimum version 4.3, #3726
  * show warning message for pre-link scripts, #3727
  * fix silent directory removal, #3730
  * fix conda/install.py single-file behavior, #3854


2016-02-19   3.19.3:
--------------------
  * fix critical issue, see #2106


2016-02-19   3.19.2:
--------------------
  * add basic activate/deactivate, conda activate/deactivate/ls for fish,
    see #545
  * remove error when CONDA_FORCE_32BIT is set on 32-bit systems, #1985
  * suppress help text for --unknown option, #2051
  * fix issue with conda create --clone post-link scripts, #2007
  * fix a permissions issue on windows, #2083


2016-02-01   3.19.1:
--------------------
  * resolve.py: properly escape periods in version numbers, #1926
  * support for pinning Lua by default, #1934
  * remove hard-coded test URLs, a module cio_test is now expected when
    CIO_TEST is set


2015-12-17   3.19.0:
--------------------
  * OpenBSD 5.x support, #1891
  * improve install CLI to make Miniconda -f work, #1905


2015-12-10   3.18.9:
--------------------
  * allow chaning default_channels (only applies to "system" condarc), from
    from CLI, #1886
  * improve default for --show-channel-urls in conda list, #1900


2015-12-03   3.18.8:
--------------------
  * always attempt to delete files in rm_rf, #1864


2015-12-02   3.18.7:
--------------------
  * simplify call to menuinst.install()
  * add menuinst as dependency on Windows
  * add ROOT_PREFIX to post-link (and pre_unlink) environment


2015-11-19   3.18.6:
--------------------
  * improve conda clean when user lacks permissions, #1807
  * make show_channel_urls default to True, #1771
  * cleaner write tests, #1735
  * fix documentation, #1709
  * improve conda clean when directories don't exist, #1808


2015-11-11   3.18.5:
--------------------
  * fix bad menuinst exception handling, #1798
  * add workaround for unresolved dependencies on Windows


2015-11-09   3.18.4:
--------------------
  * allow explicit file to contain MD5 hashsums
  * add --md5 option to "conda list --explicit"
  * stop infinite recursion during certain resolve operations, #1749
  * add dependencies even if strictness == 3, #1766


2015-10-15   3.18.3:
--------------------
  * added a pruning step for more efficient solves, #1702
  * disallow conda-env to be installed into non-root environment
  * improve error output for bad command input, #1706
  * pass env name and setup cmd to menuinst, #1699


2015-10-12   3.18.2:
--------------------
  * add "conda list --explicit" which contains the URLs of all conda packages
    to be installed, and can used with the install/create --file option, #1688
  * fix a potential issue in conda clean
  * avoid issues with LookupErrors when updating Python in the root
    environment on Windows
  * don't fetch the index from the network with conda remove
  * when installing conda packages directly, "conda install <pkg>.tar.bz2",
    unlink any installed package with that name (not just the installed one)
  * allow menu items to be installed in non-root env, #1692


2015-09-28   3.18.1:
--------------------
  * fix: removed reference to win_ignore_root in plan module


2015-09-28   3.18.0:
--------------------
  * allow Python to be updated in root environment on Windows, #1657
  * add defaults to specs after getting pinned specs (allows to pin a
    different version of Python than what is installed)
  * show what older versions are in the solutions in the resolve debug log
  * fix some issues with Python 3.5
  * respect --no-deps when installing from .tar or .tar.bz2
  * avoid infinite recursion with NoPackagesFound and conda update --all --file
  * fix conda update --file
  * toposort: Added special case to remove 'pip' dependency from 'python'
  * show dotlog messages during hint generation with --debug
  * disable the max_only heuristic during hint generation
  * new version comparison algorithm, which consistently compares any version
    string, and better handles version strings using things like alpha, beta,
    rc, post, and dev. This should remove any inconsistent version comparison
    that would lead to conda installing an incorrect version.
  * use the trash in rm_rf, meaning more things will get the benefit of the
    trash system on Windows
  * add the ability to pass the --file argument multiple times
  * add conda upgrade alias for conda update
  * add update_dependencies condarc option and --update-deps/--no-update-deps
    command line flags
  * allow specs with conda update --all
  * add --show-channel-urls and --no-show-channel-urls command line options
  * add always_copy condarc option
  * conda clean properly handles multiple envs directories. This breaks
    backwards compatibility with some of the --json output. Some of the old
    --json keys are kept for backwards compatibility.


2015-09-11   3.17.0:
--------------------
  * add windows_forward_slashes option to walk_prefix(), see #1513
  * add ability to set CONDA_FORCE_32BIT environment variable, it should
    should only be used when running conda-build, #1555
  * add config option to makes the python dependency on pip optional, #1577
  * fix an UnboundLocalError
  * print note about pinned specs in no packages found error
  * allow wildcards in AND-connected version specs
  * print pinned specs to the debug log
  * fix conda create --clone with create_default_packages
  * give a better error when a proxy isn't found for a given scheme
  * enable running 'conda run' in offline mode
  * fix issue where hardlinked cache contents were being overwritten
  * correctly skip packages whose dependencies can't be found with conda
    update --all
  * use clearer terminology in -m help text.
  * use splitlines to break up multiple lines throughout the codebase
  * fix AttributeError with SSLError


2015-08-10   3.16.0:
--------------------
  * rename binstar -> anaconda, see #1458
  * fix --use-local when the conda-bld directory doesn't exist
  * fixed --offline option when using "conda create --clone", see #1487
  * don't mask recursion depth errors
  * add conda search --reverse-dependency
  * check whether hardlinking is available before linking when
    using "python install.py --link" directly, see #1490
  * don't exit nonzero when installing a package with no dependencies
  * check which features are installed in an environment via track_features,
    not features
  * set the verify flag directly on CondaSession (fixes conda skeleton not
    respecting the ssl_verify option)


2015-07-23   3.15.1:
--------------------
  * fix conda with older versions of argcomplete
  * restore the --force-pscheck option as a no-op for backwards
    compatibility


2015-07-22   3.15.0:
--------------------
  * sort the output of conda info package correctly
  * enable tab completion of conda command extensions using
    argcomplete. Command extensions that import conda should use
    conda.cli.conda_argparse.ArgumentParser instead of
    argparse.ArgumentParser. Otherwise, they should enable argcomplete
    completion manually.
  * allow psutil and pycosat to be updated in the root environment on Windows
  * remove all mentions of pscheck. The --force-pscheck flag has been removed.
  * added support for S3 channels
  * fix color issues from pip in conda list on Windows
  * add support for other machine types on Linux, in particular ppc64le
  * add non_x86_linux_machines set to config module
  * allow ssl_verify to accept strings in addition to boolean values in condarc
  * enable --set to work with both boolean and string values


2015-06-29   3.14.1:
--------------------
  * make use of Crypto.Signature.PKCS1_PSS module, see #1388
  * note when features are being used in the unsatisfiable hint


2015-06-16   3.14.0:
--------------------
  * add ability to verify signed packages, see #1343 (and conda-build #430)
  * fix issue when trying to add 'pip' dependency to old python packages
  * provide option "conda info --unsafe-channels" for getting unobscured
    channel list, #1374


2015-06-04   3.13.0:
--------------------
  * avoid the Windows file lock by moving files to a trash directory, #1133
  * handle env dirs not existing in the Environments completer
  * rename binstar.org -> anaconda.org, see #1348
  * speed up 'source activate' by ~40%


2015-05-05   3.12.0:
--------------------
  * correctly allow conda to update itself
  * print which file leads to the "unable to remove file" error on Windows
  * add support for the no_proxy environment variable, #1171
  * add a much faster hint generation for unsatisfiable packages, which is now
    always enabled (previously it would not run if there were more than ten
    specs). The new hint only gives one set of conflicting packages, rather
    than all sets, so multiple passes may be necessary to fix such issues
  * conda extensions that import conda should use
    conda.cli.conda_argparser.ArgumentParser instead of
    argparse.ArgumentParser to conform to the conda help guidelines (e.g., all
    help messages should be capitalized with periods, and the options should
    be preceded by "Options:" for the sake of help2man).
  * add confirmation dialog to conda remove. Fixes conda remove --dry-run.


2015-04-22   3.11.0:
--------------------
  * fix issue where forced update on Windows could cause a package to break
  * remove detection of running processes that might conflict
  * deprecate --force-pscheck (now a no-op argument)
  * make conda search --outdated --names-only work, fixes #1252
  * handle the history file not having read or write permissions better
  * make multiple package resolutions warning easier to read
  * add --full-name to conda list
  * improvements to command help


2015-04-06   3.10.1:
--------------------
  * fix logic in @memoized for unhashable args
  * restored json cache of repodata, see #1249
  * hide binstar tokens in conda info --json
  * handle CIO_TEST='2 '
  * always find the solution with minimal number of packages, even if there
    are many solutions
  * allow comments at the end of the line in requirement files
  * don't update the progressbar until after the item is finished running
  * add conda/<version> to HTTP header User-Agent string


2015-03-12   3.10.0:
--------------------
  * change default repo urls to be https
  * add --offline to conda search
  * add --names-only and --full-name to conda search
  * add tab completion for packages to conda search


2015-02-24   3.9.1:
-------------------
  * pscheck: check for processes in the current environment, see #1157
  * don't write to the history file if nothing has changed, see #1148
  * conda update --all installs packages without version restrictions (except
    for Python), see #1138
  * conda update --all ignores the anaconda metapackage, see #1138
  * use forward slashes for file urls on Windows
  * don't symlink conda in the root environment from activate
  * use the correct package name in the progress bar info
  * use json progress bars for unsatisfiable dependencies hints
  * don't let requests decode gz files when downloaded


2015-02-16   3.9.0:
-------------------
  * remove (de)activation scripts from conda, those are now in conda-env
  * pip is now always added as a Python dependency
  * allow conda to be installed into environments which start with _
  * add argcomplete tab completion for environments with the -n flag, and for
    package names with install, update, create, and remove


2015-02-03   3.8.4:
-------------------
  * copy (de)activate scripts from conda-env
  * Add noarch (sub) directory support


2015-01-28   3.8.3:
-------------------
  * simplified how ROOT_PREFIX is obtained in (de)activate


2015-01-27   3.8.2:
-------------------
  * add conda clean --source-cache to clean the conda build source caches
  * add missing quotes in (de)activate.bat, fixes problem in Windows when
    conda is installed into a directory with spaces
  * fix conda install --copy


2015-01-23   3.8.1:
-------------------
  * add missing utf-8 decoding, fixes Python 3 bug when icondata to json file


2015-01-22   3.8.0:
-------------------
  * move active script into conda-env, which is now a new dependency
  * load the channel urls in the correct order when using concurrent.futures
  * add optional 'icondata' key to json files in conda-meta directory, which
    contain the base64 encoded png file or the icon
  * remove a debug print statement


2014-12-18   3.7.4:
-------------------
  * add --offline option to install, create, update and remove commands, and
    also add ability to set "offline: True" in condarc file
  * add conda uninstall as alias for conda remove
  * add conda info --root
  * add conda.pip module
  * fix CONDARC pointing to non-existing file, closes issue #961
  * make update -f work if the package is already up-to-date
  * fix possible TypeError when printing an error message
  * link packages in topologically sorted order (so that pre-link scripts can
    assume that the dependencies are installed)
  * add --copy flag to install
  * prevent the progressbar from crashing conda when fetching in some
    situations


2014-11-05   3.7.3:
-------------------
  * conda install from a local conda package (or a tar fill which
    contains conda packages), will now also install the dependencies
    listed by the installed packages.
  * add SOURCE_DIR environment variable in pre-link subprocess
  * record all created environments in ~/.conda/environments.txt


2014-10-31   3.7.2:
-------------------
  * only show the binstar install message once
  * print the fetching repodata dot after the repodata is fetched
  * write the install and remove specs to the history file
  * add '-y' as an alias to '--yes'
  * the `--file` option to conda config now defaults to
    os.environ.get('CONDARC')
  * some improvements to documentation (--help output)
  * add user_rc_path and sys_rc_path to conda info --json
  * cache the proxy username and password
  * avoid warning about conda in pscheck
  * make ~/.conda/envs the first user envs dir


2014-10-07   3.7.1:
-------------------
  * improve error message for forgetting to use source with activate and
    deactivate, see issue #601
  * don't allow to remove the current environment, see issue #639
  * don't fail if binstar_client can't be imported for other reasons,
    see issue #925
  * allow spaces to be contained in conda run
  * only show the conda install binstar hint if binstar is not installed
  * conda info package_spec now gives detailed info on packages. conda info
    path has been removed, as it is duplicated by conda package -w path.


2014-09-19   3.7.0:
-------------------
  * faster algorithm for --alt-hint
  * don't allow channel_alias with allow_other_channels: false if it is set in
    the system .condarc
  * don't show long "no packages found" error with update --all
  * automatically add the Binstar token to urls when the binstar client is
    installed and logged in
  * carefully avoid showing the binstar token or writing it to a file
  * be more careful in conda config about keys that are the wrong type
  * don't expect directories starting with conda- to be commands
  * no longer recommend to run conda init after pip installing conda. A pip
    installed conda will now work without being initialized to create and
    manage other environments
  * the rm function on Windows now works around access denied errors
  * fix channel urls now showing with conda list with show_channel_urls set to
    true


2014-09-08   3.6.4:
-------------------
  * fix removing packages that aren't in the channels any more
  * Pretties output for --alt-hint


2014-09-04   3.6.3:
-------------------
  * skip packages that can't be found with update --all
  * add --use-local to search and remove
  * allow --use-local to be used along with -c (--channels) and
    --override-channels. --override-channels now requires either -c or
    --use-local
  * allow paths in has_prefix to be quoted, to allow for spaces in paths on
    Windows
  * retain Unix style path separators for prefixes in has_prefix on
    Windows (if the placeholder path uses /, replace it with a path that uses
    /, not \)
  * fix bug in --use-local due to API changes in conda-build
  * include user site directories in conda info -s
  * make binary has_prefix replacement work with spaces after the prefix
  * make binary has_prefix replacement replace multiple occurrences of the
    placeholder in the same null-terminated string
  * don't show packages from other platforms as installed or cached in conda
    search
  * be more careful about not warning about conda itself in pscheck
  * Use a progress bar for the unsatisfiable packages hint generation
  * Don't use TemporaryFile in try_write, as it is too slow when it fails
  * Ignore InsecureRequestWarning when ssl_verify is False
  * conda remove removes features tracked by removed packages in
    track_features


2014-08-20   3.6.2:
-------------------
  * add --use-index-cache to conda remove
  * fix a bug where features (like mkl) would be selected incorrectly
  * use concurrent.future.ThreadPool to fetch package metadata asynchronously
    in Python 3.
  * do the retries in rm_rf on every platform
  * use a higher cutoff for package name misspellings
  * allow changing default channels in "system" .condarc


2014-08-13   3.6.1:
-------------------
  * add retries to download in fetch module
  * improved error messages for missing packages
  * more robust rm_rf on Windows
  * print multiline help for subcommands correctly


2014-08-11   3.6.0:
-------------------
  * correctly check if a package can be hard-linked if it isn't extracted yet
  * change how the package plan is printed to better show what is new,
    updated, and downgraded
  * use suggest_normalized_version in the resolve module. Now versions like
    1.0alpha that are not directly recognized by verlib's NormalizedVersion
    are supported better
  * conda run command, to run apps and commands from packages
  * more complete --json API. Every conda command should fully support --json
    output now.
  * show the conda_build and requests versions in conda info
  * include packages from setup.py develop in conda list (with use_pip)
  * raise a warning instead of dying when the history file is invalid
  * use urllib.quote on the proxy password
  * make conda search --outdated --canonical work
  * pin the Python version during conda init
  * fix some metadata that is written for Python during conda init
  * allow comments in a pinned file
  * allow installing and updating menuinst on Windows
  * allow conda create with both --file and listed packages
  * better handling of some nonexistent packages
  * fix command line flags in conda package
  * fix a bug in the ftp adapter


2014-06-10   3.5.5:
-------------------
  * remove another instance pycosat version detection, which fails on
    Windows, see issue #761


2014-06-10   3.5.4:
-------------------
  * remove pycosat version detection, which fails on Windows, see issue #761


2014-06-09   3.5.3:
-------------------
  * fix conda update to correctly not install packages that are already
    up-to-date
  * always fail with connection error in download
  * the package resolution is now much faster and uses less memory
  * add ssl_verify option in condarc to allow ignoring SSL certificate
    verification, see issue #737


2014-05-27   3.5.2:
-------------------
  * fix bug in activate.bat and deactivate.bat on Windows


2014-05-26   3.5.1:
-------------------
  * fix proxy support - conda now prompts for proxy username and password
    again
  * fix activate.bat on Windows with spaces in the path
  * update optional psutil dependency was updated to psutil 2.0 or higher


2014-05-15   3.5.0:
-------------------
  * replace use of urllib2 with requests. requests is now a hard dependency of
    conda.
  * add ability to only allow system-wise specified channels
  * hide binstar from output of conda info


2014-05-05   3.4.3:
-------------------
  * allow prefix replacement in binary files, see issue #710
  * check if creating hard link is possible and otherwise copy,
    during install
  * allow circular dependencies


2014-04-21   3.4.2:
-------------------
  * conda clean --lock: skip directories that don't exist, fixes #648
  * fixed empty history file causing crash, issue #644
  * remove timezone information from history file, fixes issue #651
  * fix PackagesNotFound error for missing recursive dependencies
  * change the default for adding cache from the local package cache -
    known is now the default and the option to use index metadata from the
    local package cache is --unknown
  * add --alt-hint as a method to get an alternate form of a hint for
    unsatisfiable packages
  * add conda package --ls-files to list files in a package
  * add ability to pin specs in an environment. To pin a spec, add a file
    called pinned to the environment's conda-meta directory with the specs to
    pin. Pinned specs are always kept installed, unless the --no-pin flag is
    used.
  * fix keyboard interrupting of external commands. Now keyboard interupting
    conda build correctly removes the lock file
  * add no_link ability to conda, see issue #678


2014-04-07   3.4.1:
-------------------
  * always use a pkgs cache directory associated with an envs directory, even
    when using -p option with an arbitrary a prefix which is not inside an
    envs dir
  * add setting of PYTHONHOME to conda info --system
  * skip packages with bad metadata


2014-04-02   3.4.0:
-------------------
  * added revision history to each environment:
      - conda list --revisions
      - conda install --revision
      - log is stored in conda-meta/history
  * allow parsing pip-style requirement files with --file option and in command
    line arguments, e.g. conda install 'numpy>=1.7', issue #624
  * fix error message for --file option when file does not exist
  * allow DEFAULTS in CONDA_ENVS_PATH, which expands to the defaults settings,
    including the condarc file
  * don't install a package with a feature (like mkl) unless it is
    specifically requested (i.e., that feature is already enabled in that
    environment)
  * add ability to show channel URLs when displaying what is going to be
    downloaded by setting "show_channel_urls: True" in condarc
  * fix the --quiet option
  * skip packages that have dependencies that can't be found


2014-03-24   3.3.2:
-------------------
  * fix the --file option
  * check install arguments before fetching metadata
  * fix a printing glitch with the progress bars
  * give a better error message for conda clean with no arguments
  * don't include unknown packages when searching another platform


2014-03-19   3.3.1:
-------------------
  * Fix setting of PS1 in activate.
  * Add conda update --all.
  * Allow setting CONDARC=' ' to use no condarc.
  * Add conda clean --packages.
  * Don't include bin/conda, bin/activate, or bin/deactivate in conda
    package.


2014-03-18   3.3.0:
-------------------
  * allow new package specification, i.e. ==, >=, >, <=, <, != separated
    by ',' for example: >=2.3,<3.0
  * add ability to disable self update of conda, by setting
    "self_update: False" in .condarc
  * Try installing packages using the old way of just installing the maximum
    versions of things first. This provides a major speedup of solving the
    package specifications in the cases where this scheme works.
  * Don't include python=3.3 in the specs automatically for the Python 3
    version of conda.  This allows you to do "conda create -n env package" for
    a package that only has a Python 2 version without specifying
    "python=2". This change has no effect in Python 2.
  * Automatically put symlinks to conda, activate, and deactivate in each
    environment on Unix.
  * On Unix, activate and deactivate now remove the root environment from the
    PATH. This should prevent "bleed through" issues with commands not
    installed in the activated environment but that are installed in the root
    environment. If you have "setup.py develop" installed conda on Unix, you
    should run this command again, as the activate and deactivate scripts have
    changed.
  * Begin work to support Python 3.4.
  * Fix a bug in version comparison
  * Fix usage of sys.stdout and sys.stderr in environments like pythonw on
    Windows where they are nonstandard file descriptors.


2014-03-12   3.2.1:
-------------------
  * fix installing packages with irrational versions
  * fix installation in the api
  * use a logging handler to print the dots


2014-03-11   3.2.0:
-------------------
  * print dots to the screen for progress
  * move logic functions from resolve to logic module


2014-03-07   3.2.0a1:
---------------------
  * conda now uses pseudo-boolean constraints in the SAT solver. This allows
    it to search for all versions at once, rather than only the latest (issue
    #491).
  * Conda contains a brand new logic submodule for converting pseudo-boolean
    constraints into SAT clauses.


2014-03-07   3.1.1:
-------------------
  * check if directory exists, fixed issue #591


2014-03-07   3.1.0:
-------------------
  * local packages in cache are now added to the index, this may be disabled
    by using the --known option, which only makes conda use index metadata
    from the known remote channels
  * add --use-index-cache option to enable using cache of channel index files
  * fix ownership of files when installing as root on Linux
  * conda search: add '.' symbol for extracted (cached) packages


2014-02-20   3.0.6:
-------------------
  * fix 'conda update' taking build number into account


2014-02-17   3.0.5:
-------------------
  * allow packages from create_default_packages to be overridden from the
    command line
  * fixed typo install.py, issue #566
  * try to prevent accidentally installing into a non-root conda environment


2014-02-14   3.0.4:
-------------------
  * conda update: don't try to update packages that are already up-to-date


2014-02-06   3.0.3:
-------------------
  * improve the speed of clean --lock
  * some fixes to conda config
  * more tests added
  * choose the first solution rather than the last when there are more than
    one, since this is more likely to be the one you want.


2014-02-03   3.0.2:
-------------------
  * fix detection of prefix being writable


2014-01-31   3.0.1:
-------------------
  * bug: not having track_features in condarc now uses default again
  * improved test suite
  * remove numpy version being treated special in plan module
  * if the post-link.(bat|sh) fails, don't treat it as though it installed,
    i.e. it is not added to conda-meta
  * fix activate if CONDA_DEFAULT_ENV is invalid
  * fix conda config --get to work with list keys again
  * print the total download size
  * fix a bug that was preventing conda from working in Python 3
  * add ability to run pre-link script, issue #548


2014-01-24   3.0.0:
-------------------
  * removed build, convert, index, and skeleton commands, which are now
    part of the conda-build project: https://github.com/conda/conda-build
  * limited pip integration to `conda list`, that means
    `conda install` no longer calls `pip install` # !!!
  * add ability to call sub-commands named 'conda-x'
  * The -c flag to conda search is now shorthand for --channel, not
    --canonical (this is to be consistent with other conda commands)
  * allow changing location of .condarc file using the CONDARC environment
    variable
  * conda search now shows the channel that the package comes from
  * conda search has a new --platform flag for searching for packages in other
    platforms.
  * remove condarc warnings: issue #526#issuecomment-33195012


2014-01-17   2.3.1:
-------------------
  * add ability create info/no_softlink
  * add conda convert command to convert non-platform-dependent packages from
    one platform to another (experimental)
  * unify create, install, and update code. This adds many features to create
    and update that were previously only available to install. A backwards
    incompatible change is that conda create -f now means --force, not
    --file.


2014-01-16   2.3.0:
-------------------
  * automatically prepend http://conda.binstar.org/ (or the value of
    channel_alias in the .condarc file) to channels whenever the
    channel is not a URL or the word 'defaults or 'system'
  * recipes made with the skeleton pypi command will use setuptools instead of
    distribute
  * re-work the setuptools dependency and entry_point logic so that
    non console_script entry_points for packages with a dependency on
    setuptools will get correct build script with conda skeleton pypi
  * add -m, --mkdir option to conda install
  * add ability to disable soft-linking


2014-01-06   2.2.8:
-------------------
  * add check for chrpath (on Linux) before build is started, see issue #469
  * conda build: fixed ELF headers not being recognized on Python 3
  * fixed issues: #467, #476


2014-01-02   2.2.7:
-------------------
  * fixed bug in conda build related to lchmod not being available on all
    platforms


2013-12-31   2.2.6:
-------------------
  * fix test section for automatic recipe creation from pypi
    using --build-recipe
  * minor Py3k fixes for conda build on Linux
  * copy symlinks as symlinks, issue #437
  * fix explicit install (e.g. from output of `conda list -e`) in root env
  * add pyyaml to the list of packages which can not be removed from root
    environment
  * fixed minor issues: #365, #453


2013-12-17   2.2.5:
-------------------
  * conda build: move broken packages to conda-bld/broken
  * conda config: automatically add the 'defaults' channel
  * conda build: improve error handling for invalid recipe directory
  * add ability to set build string, issue #425
  * fix LD_RUN_PATH not being set on Linux under Python 3,
    see issue #427, thanks peter1000


2013-12-10   2.2.4:
-------------------
  * add support for execution with the -m switch (issue #398), i.e. you
    can execute conda also as: python -m conda
  * add a deactivate script for windows
  * conda build adds .pth-file when it encounters an egg (TODO)
  * add ability to preserve egg directory when building using
        build/preserve_egg_dir: True
  * allow track_features in ~/.condarc
  * Allow arbitrary source, issue #405
  * fixed minor issues: #393, #402, #409, #413


2013-12-03   2.2.3:
-------------------
  * add "foreign mode", i.e. disallow install of certain packages when
    using a "foreign" Python, such as the system Python
  * remove activate/deactivate from source tarball created by sdist.sh,
    in order to not overwrite activate script from virtualenvwrapper


2013-11-27   2.2.2:
-------------------
  * remove ARCH environment variable for being able to change architecture
  * add PKG_NAME, PKG_VERSION to environment when running build.sh,
    .<name>-post-link.sh and .<name>-pre-unlink.sh


2013-11-15   2.2.1:
-------------------
  * minor fixes related to make conda pip installable
  * generated conda meta-data missing 'files' key, fixed issue #357


2013-11-14   2.2.0:
-------------------
  * add conda init command, to allow installing conda via pip
  * fix prefix being replaced by placeholder after conda build on Unix
  * add 'use_pip' to condarc configuration file
  * fixed activate on Windows to set CONDA_DEFAULT_ENV
  * allow setting "always_yes: True" in condarc file, which implies always
    using the --yes option whenever asked to proceed


2013-11-07   2.1.0:
-------------------
  * fix rm_egg_dirs so that the .egg_info file can be a zip file
  * improve integration with pip
      * conda list now shows pip installed packages
      * conda install will try to install via "pip install" if no
        conda package is available (unless --no-pip is provided)
      * conda build has a new --build-recipe option which
        will create a recipe (stored in <root>/conda-recipes) from pypi
        then build a conda package (and install it)
      * pip list and pip install only happen if pip is installed
  * enhance the locking mechanism so that conda can call itself in the same
    process.


2013-11-04   2.0.4:
-------------------
  * ensure lowercase name when generating package info, fixed issue #329
  * on Windows, handle the .nonadmin files


2013-10-28   2.0.3:
-------------------
  * update bundle format
  * fix bug when displaying packages to be downloaded (thanks Crystal)


2013-10-27   2.0.2:
-------------------
  * add --index-cache option to clean command, see issue #321
  * use RPATH (instead of RUNPATH) when building packages on Linux


2013-10-23   2.0.1:
-------------------
  * add --no-prompt option to conda skeleton pypi
  * add create_default_packages to condarc (and --no-default-packages option
    to create command)


2013-10-01   2.0.0:
-------------------
  * added user/root mode and ability to soft-link across filesystems
  * added create --clone option for copying local environments
  * fixed behavior when installing into an environment which does not
    exist yet, i.e. an error occurs
  * fixed install --no-deps option
  * added --export option to list command
  * allow building of packages in "user mode"
  * regular environment locations now used for build and test
  * add ability to disallow specification names
  * add ability to read help messages from a file when install location is RO
  * restore backwards compatibility of share/clone for conda-api
  * add new conda bundle command and format
  * pass ARCH environment variable to build scripts
  * added progress bar to source download for conda build, issue #230
  * added ability to use url instead of local file to conda install --file
    and conda create --file options


2013-09-06   1.9.1:
-------------------
  * fix bug in new caching of repodata index


2013-09-05   1.9.0:
-------------------
  * add caching of repodata index
  * add activate command on Windows
  * add conda package --which option, closes issue 163
  * add ability to install file which contains multiple packages, issue 256
  * move conda share functionality to conda package --share
  * update documentation
  * improve error messages when external dependencies are unavailable
  * add implementation for issue 194: post-link or pre-unlink may append
    to a special file ${PREFIX}/.messages.txt for messages, which is display
    to the user's console after conda completes all actions
  * add conda search --outdated option, which lists only installed packages
    for which newer versions are available
  * fixed numerous Py3k issues, in particular with the build command


2013-08-16   1.8.2:
-------------------
  * add conda build --check option
  * add conda clean --lock option
  * fixed error in recipe causing conda traceback, issue 158
  * fixes conda build error in Python 3, issue 238
  * improve error message when test command fails, as well as issue 229
  * disable Python (and other packages which are used by conda itself)
    to be updated in root environment on Windows
  * simplified locking, in particular locking should never crash conda
    when files cannot be created due to permission problems


2013-08-07   1.8.1:
-------------------
  * fixed conda update for no arguments, issue 237
  * fix setting prefix before calling should_do_win_subprocess()
    part of issue 235
  * add basic subversion support when building
  * add --output option to conda build


2013-07-31   1.8.0:
-------------------
  * add Python 3 support (thanks almarklein)
  * add Mercurial support when building from source (thanks delicb)
  * allow Python (and other packages which are used by conda itself)
    to be updated in root environment on Windows
  * add conda config command
  * add conda clean command
  * removed the conda pip command
  * improve locking to be finer grained
  * made activate/deactivate work with zsh (thanks to mika-fischer)
  * allow conda build to take tarballs containing a recipe as arguments
  * add PKG_CONFIG_PATH to build environment variables
  * fix entry point scripts pointing to wrong python when building Python 3
    packages
  * allow source/sha1 in meta.yaml, issue 196
  * more informative message when there are unsatisfiable package
    specifications
  * ability to set the proxy urls in condarc
  * conda build asks to upload to binstar. This can also be configured by
    changing binstar_upload in condarc.
  * basic tab completion if the argcomplete package is installed and eval
    "$(register-python-argcomplete conda)" is added to the bash profile.


2013-07-02   1.7.2:
-------------------
  * fixed conda update when packages include a post-link step which was
    caused by subprocess being lazily imported, fixed by 0d0b860
  * improve error message when 'chrpath' or 'patch' is not installed and
    needed by build framework
  * fixed sharing/cloning being broken (issue 179)
  * add the string LOCKERROR to the conda lock error message


2013-06-21   1.7.1:
-------------------
  * fix "executable" not being found on Windows when ending with .bat when
    launching application
  * give a better error message from when a repository does not exist


2013-06-20   1.7.0:
-------------------
  * allow ${PREFIX} in app_entry
  * add binstar upload information after conda build finishes


2013-06-20   1.7.0a2:
---------------------
  * add global conda lock file for only allowing one instance of conda
    to run at the same time
  * add conda skeleton command to create recipes from PyPI
  * add ability to run post-link and pre-unlink script


2013-06-13   1.7.0a1:
---------------------
  * add ability to build conda packages from "recipes", using the conda build
    command, for some examples, see:
    https://github.com/ContinuumIO/conda-recipes
  * fixed bug in conda install --force
  * conda update command no longer uses anaconda as default package name
  * add proxy support
  * added application API to conda.api module
  * add -c/--channel and --override-channels flags (issue 121).
  * add default and system meta-channels, for use in .condarc and with -c
    (issue 122).
  * fixed ability to install ipython=0.13.0 (issue 130)


2013-06-05   1.6.0:
-------------------
  * update package command to reflect changes in repodata
  * fixed refactoring bugs in share/clone
  * warn when anaconda processes are running on install in Windows (should
    fix most permissions errors on Windows)


2013-05-31   1.6.0rc2:
----------------------
  * conda with no arguments now prints help text (issue 111)
  * don't allow removing conda from root environment
  * conda update python does no longer update to Python 3, also ensure that
    conda itself is always installed into the root environment (issue 110)


2013-05-30   1.6.0rc1:
----------------------
  * major internal refactoring
  * use new "depends" key in repodata
  * uses pycosat to solve constraints more efficiently
  * add hard-linking on Windows
  * fixed linking across filesystems (issue 103)
  * add conda remove --features option
  * added more tests, in particular for new dependency resolver
  * add internal DSL to perform install actions
  * add package size to download preview
  * add conda install --force and --no-deps options
  * fixed conda help command
  * add conda remove --all option for removing entire environment
  * fixed source activate on systems where sourcing a gives "bash" as $0
  * add information about installed versions to conda search command
  * removed known "locations"
  * add output about installed packages when update and install do nothing
  * changed default when prompted for y/n in CLI to yes


2013-04-29   1.5.2:
-------------------
  * fixed issue 59: bad error message when pkgs dir is not writable


2013-04-19   1.5.1:
-------------------
  * fixed issue 71 and (73 duplicate): not being able to install packages
    starting with conda (such as 'conda-api')
  * fixed issue 69 (not being able to update Python / NumPy)
  * fixed issue 76 (cannot install mkl on OSX)


2013-03-22   1.5.0:
-------------------
  * add conda share and clone commands
  * add (hidden) --output-json option to clone, share and info commands
    to support the conda-api package
  * add repo sub-directory type 'linux-armv6l'


2013-03-12   1.4.6:
-------------------
  * fixed channel selection (issue #56)


2013-03-11   1.4.5:
-------------------
  * fix issue #53 with install for meta packages
  * add -q/--quiet option to update command


2013-03-09   1.4.4:
-------------------
  * use numpy 1.7 as default on all platfroms


2013-03-09   1.4.3:
-------------------
  * fixed bug in conda.builder.share.clone_bundle()


2013-03-08   1.4.2:
-------------------
  * feature selection fix for update
  * Windows: don't allow linking or unlinking python from the root
             environment because the file lock, see issue #42


2013-03-07   1.4.1:
-------------------
  * fix some feature selection bugs
  * never exit in activate and deactivate
  * improve help and error messages


2013-03-05   1.4.0:
-------------------
  * fixed conda pip NAME==VERSION
  * added conda info --license option
  * add source activate and deactivate commands
  * rename the old activate and deactivate to link and unlink
  * add ability for environments to track "features"
  * add ability to distinguish conda build packages from Anaconda
    packages by adding a "file_hash" meta-data field in info/index.json
  * add conda.builder.share module


2013-02-05   1.3.5:
-------------------
  * fixed detecting untracked files on Windows
  * removed backwards compatibility to conda 1.0 version


2013-01-28   1.3.4:
-------------------
  * fixed conda installing itself into environments (issue #10)
  * fixed non-existing channels being silently ignored (issue #12)
  * fixed trailing slash in ~/.condarc file cause crash (issue #13)
  * fixed conda list not working when ~/.condarc is missing (issue #14)
  * fixed conda install not working for Python 2.6 environment (issue #17)
  * added simple first cut implementation of remove command (issue #11)
  * pip, build commands: only package up new untracked files
  * allow a system-wide <sys.prefix>/.condarc (~/.condarc takes precedence)
  * only add pro channel is no condarc file exists (and license is valid)


2013-01-23   1.3.3:
-------------------
  * fix conda create not filtering channels correctly
  * remove (hidden) --test and --testgui options


2013-01-23   1.3.2:
-------------------
  * fix deactivation of packages with same build number
    note that conda upgrade did not suffer from this problem, as was using
    separate logic


2013-01-22   1.3.1:
-------------------
  * fix bug in conda update not installing new dependencies


2013-01-22   1.3.0:
-------------------
  * added conda package command
  * added conda index command
  * added -c, --canonical option to list and search commands
  * fixed conda --version on Windows
  * add this changelog


2012-11-21   1.2.1:
-------------------
  * remove ambiguity from conda update command


2012-11-20   1.2.0:
-------------------
  * "conda upgrade" now updates from AnacondaCE to Anaconda (removed
    upgrade2pro
  * add versioneer


2012-11-13   1.1.0:
-------------------
  * Many new features implemented by Bryan


2012-09-06   1.0.0:
-------------------
  * initial release
