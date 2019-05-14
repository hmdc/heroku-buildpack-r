# Heroku buildpack: R

This is a [Heroku buildpack](https://devcenter.heroku.com/articles/buildpacks) for applications which use
[R](https://www.r-project.org/) for statistical computing and [CRAN](https://cran.r-project.org/) for R packages.

The master branch of this repository contains the canonical version of the buildpack for use by IQSS/VPAL-R. The upstream branch is [virtualstaticvoid/heroku-buildpack-r.git#heroku-16-packrat](https://github.com/virtualstaticvoid/heroku-buildpack-r/tree/heroku-16-packrat).

## Usage

To use this version, the buildpack URL is `https://github.com/hmdc/heroku-buildpack-r`.

The buildpack will detect your app makes use of R if it has a `run.R` file in the root directory.

### Installing R Packages

The buildpack requires you are using [Packrat](https://github.com/rstudio/packrat) to lock down package dependencies. You must run `packrat::snapshot()` before making your first push to Heroku. If you modify the snapshot by adding, removing, or changing a package, you must clear the Heroku build cache before redeploying (see **Caching** below).

### Installing Binary Dependencies

If the R packages have binary dependencies, they can be specified by providing an `Aptfile` in your repository's root that contains the Ubuntu package names to install.

For instance, Tidyverse packages need `libxml2-dev` and RPostgreSQL needs `libpq-dev`. Examine the log of a failed `git push heroku` command for names of other Ubuntu/Debian dependencies your R packages might need.

### R Console

You can run the R console application as follows:

```
$ heroku run R ...
```

Type `q()` to exit the console when you are finished. You can run the Rscript utility as follows:

```
$ heroku run Rscript ...
```

_Note that the Heroku slug has an ephemeral file system and is effectively read-only, so any changes you make during the session will be discarded._

### Shiny Applications

See [apache-shiny-demo](https://github.com/hmdc/heroku-shiny-demo).

### Scheduling a Recurring Job

You can use the [Heroku scheduler](https://addons.heroku.com/scheduler) to schedule a recurring R process.

An example command for the scheduler, to run `prog.r`, would be `R -f /app/prog.r --gui-none --no-save`.

## Technical Details

### R Versions

The buildpack uses R 3.6.0 by default, however it is possible to use a different version if required. This is done by providing a `.r-version` file in the root directory, which contains the R version to use.

The following R versions are provide:

* 3.6.0

### Buildpack Versions

To reference a specific version of the buildpack, add the Git branch or tag name to the end of the build pack URL when creating or configuring your Heroku application.

E.g. Replace `branch_or_tag_name` with the desired branch or tag name:

```
$ heroku create --stack heroku-18 \
    --buildpack https://github.com/harvard-vpal/heroku-buildpack-r.git#branch_or_tag_name
```

### Buildpack Binaries

The binaries used by the buildpack are hosted on AWS S3 at [https://heroku-r-buildpack.s3.amazonaws.com](https://heroku-r-buildpack.s3.amazonaws.com).

See the [heroku-buildpack-r-build](https://github.com/virtualstaticvoid/heroku-buildpack-r-build) repository for building the R binaries yourself.

### Process Types

The buildpack includes the following default process types:

* console: Executes `bash` in the chroot context, if needed for debugging.
* web: Executes `run.R` to run Shiny in the chroot context

The `R` and `Rscript` executables are available like any other executable, via the `heroku run` command.

### Caching

To improve the time it takes to deploy, the buildpack caches the R binaries, any additional binaries installed using the `Aptfile` and the compiled package binaries. If you need to purge the cache, it is possible by using [heroku-repo](https://github.com/heroku/heroku-repo) CLI plugin.

To install the plugin run:

```bash
heroku plugins:install heroku-repo
```

To purge the buildpack cache, run the following command from your application's source code directory:

```bash
heroku repo:purge_cache -a your-app-name
```

See the [purge-cache](https://github.com/heroku/heroku-repo#purge-cache) documentation for more information.

### Multiple Buildpacks

This buildpack can be used in conjunction with other supported language stacks on Heroku by using multiple buildpacks. See [Using Multiple Buildpacks for an App](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app).

See the [ruby](test/ruby) application which shows how to use R together with a Ruby Sinatra web application and the [`rinruby`](https://rubygems.org/gems/rinruby) gem.

### CRAN Mirror Override

It is possible to override the default CRAN mirror used, by providing the URL via the `CRAN_MIRROR` environment variable.

E.g. Override the URL by setting the variable as follows. **Note**: There is no trailing "slash" in the URL.

```
heroku config:set CRAN_MIRROR=https://cloud.r-project.org
```

Check the CRAN [mirror status](https://cran.r-project.org/mirmon_report.html) page to ensure the mirror is available.

## Caveats

* Due to the size of the R runtime, the slug size on Heroku, without any additional packages or program code, is approximately 150Mb.
If additional R packages are installed then the slug size will increase.

* You can only use one dyno. Each dyno has >= 4 cores. The R shiny buildpack automatically launches as many R processes as cores in order
to serve more requests concurrently. Load balancing across multiple dynos will cause unexpected failures as R session management
requires sticky sessions which Heroku does not provide. 

* You may use (session affinity)[https://devcenter.heroku.com/articles/session-affinity] to load balance R sessions across multiple dynos
if you are inside the Common Runtime, working with data which is not classified secure. However, dynos restart daily, which would
invalidate any currently running sessions. You will experience the same failures as referenced in the previous caveat -- our
suggestion is to stick with one dyno. You may increase the dyno "weight" to 2x or 4x if necessary. Please contact HMDC support (support@hmdc.harvard.edu)
if you're running into any performance issues.

* R apps timeout on the client side after 60 seconds of inactivity, meaning that if a user is not actively using the widgets
displayed on the screen, the screen will turn grey in order to accomodate other traffic. You may extend this tiemout
by following this [guide from domino data labs](https://support.dominodatalab.com/hc/en-us/articles/360015932932-Increasing-the-timeout-for-Shiny-Server)

## Credits

* Original inspiration from [Noah Lorang's Rook on Heroku](https://github.com/noahhl/rookonheroku) project.
* [heroku-buildpack-apt](https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-apt) buildpack.
* [heroku-buildpack-fakesu](https://github.com/fabiokung/heroku-buildpack-fakesu) buildpack.
* [fakechroot](https://github.com/dex4er/fakechroot)

## License

MIT License. Copyright (c) 2013 Chris Stefano. See MIT_LICENSE for details.
