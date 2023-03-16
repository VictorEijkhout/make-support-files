# Make support files

This is a set of make include files that greatly 
facilitate making your own Makefiles to wrap
around CMake or Autotools installations.

As an example, here is my makefile for the Aspect finite element library:

```
PACKAGE = ASPECT
PACKAGEVERSION = 2.4.0
MODE = mpi
MODULES = dealii

include ${MAKEINCLUDES}/Make.info

CMAKEFLAGS = \
        -D CMAKE_BUILD_TYPE=Release \
        -D DEAL_II_DIR=${LMOD_DEALII_DIR} \
        -Wno-dev
include ${MAKEINCLUDES}/Make.cmake
include ${MAKEINCLUDES}/Make.cbuild

ASPECT_BIN = ${ASPECT_INSTALLATION}/bin

TGZURL = https://github.com/geodynamics/aspect/releases/download/v${PACKAGEVERSION}/aspect-${PACKAGEVERSION}.tar.gz
include ${MAKEINCLUDES}/Make.download
include ${MAKEINCLUDES}/Make.clean
```

You see that it consists of some variables and some include files. Together this make it possible to say 

```
make configure build
```

which will do the whole installation and generate an Lmod module file.


## Site-specific variables

Your makefile uses some site-specific variables. You can define them in the makefile, but by setting them in the environment you can make your makefile portable.

 - `PACKAGEROOT` : This is the root of your installation tree. Package `foo` will go to `${PACKAGEROOT}/foo`.
 - `MAKEINCLUDES` : This is the directory containing the clone of the repo you are now looking at.

##  Package-specific variables

Each package needs to define a few variables, specifically for a package.

* `PACKAGE` : this is the name of your package, without any version numbers and such.
* `PACKAGEVERSION` : this is the version number. If you do not a versioned version, but a repository checkout, use a version `git` or `git20230314` or so.

## Optional variables

In addition to the previous, you can have a line

```
MODE = seq # or mpi
```
that determines the type of compiler used, and influences the name of the module file.

## Download

You can make your Makefile do a package download or a repository checkout.

For downloadable packages, you would have two lines:

```
TGZURL = https://github.com/fmtlib/fmt/archive/${PACKAGEVERSION}.tar.gz
include ${MAKEINCLUDES}/Make.download
```

which allows you to `make download untar`. This creates the source directory:
 
```${PACKAGEROOT}/${PACKAGE}/${PACKAGE}-${PACKAGEVERSION}```

For repositories, you would have:

```
GITREPO= https://github.com/ECP-WarpX/WarpX.git
include ${MAKEINCLUDES}/Make.git
```

and use `make clone` and later `make pull`.

You can have all four of the lines, and use the 
package version explicitly (or explicitly for whatever is
hard wired in the makefile):

```
make download PACKAGEVERSION=3.1.4
make pull PACKAGEVERSION=git
```

## Configure and install

For both types of packages, the configure/install proceeds by

```
make configure install
```

This generates directories

```
${PACKAGEROOT}/${PACKAGE}/build-${ID}
${PACKAGEROOT}/${PACKAGE}/installation-${ID}
```

where `ID` is a composite of the version number, `LMOD_FAMILY_COMPILER` and `LMOD_FAMILY_MPI` for MPI packages.

It also generates a modulefile.

For autotools installations, add these lines to your makefile:

```
include ${MAKEINCLUDES}/Make.configure
include ${MAKEINCLUDES}/Make.install
```

For Cmake installation, add these lines:

```
include ${MAKEINCLUDES}/Make.cmake
include ${MAKEINCLUDES}/Make.cbuild
```

# Module file

The build stage generates a modulefile using the guidelines of the Lmod package.

* Start at `${MODULEROOT}`
* If `MODE` IS `mpi`, append `MPI`, for mode `seq` append `Compiler`
* Append `${LMOD_FAMILY_COMPILER}/${LMOD_FAMILY_COMPILER_VERSION}`
* For MPI packages, append  `${LMOD_FAMILY_MPI}/${LMOD_FAMILY_MPI_VERSION}`

The `DIR,INC,LIB` variables are generated both with `TACC_`  and `LMOD_` prefix.

Setting `MODULEPATH` completely overrides this mechanism: this is the fully explicit location for the `.lua` file.

## CMake discoverability

If you package generates a `.pc` file, specify its location relative to the install directory by a line such as 

```
PKGCONFIGSET = lib/pkgconfig
```

The resulting path will be added to the `PKG_CONFIG_PATH` in the modulefile.

Likewise, a `CMAKE_MODULEPATH_SET` specification will be added to the `CMAKE_MODULE_PATH`, and `CMAKE_PREFIXPATH_SET` will be added to the `CMAKE_PREFIX_PATH`.

# Customizations

## Autotools

Define a variable `CONFIGUREFLAGS` in your makefile for any configuration options beyond the installation prefix.

## CMake

Define a variable `CMAKEFLAGS` in your makefile for any configuration 
options beyond the installation prefix.

Set `CPPSTANDARD=20` (et cetera) to dictate a specific standard to CMake.

## Source directory

By default, the source is found in `${PACKAGEROOT}/${package}` where `package` is an all-lowercase version of `${PACKAGE}`. To override this, set the `SRCDIR` variable.

## Installation directory

The name and location of the installation directory 
are determined automatically as describe above. 
The location can be customized by setting `INSTALLPATH`.
The contents are whatever the `make install` stage puts there.

In the module file, the `LMOD_YOURPACKAGE_LIB` is set to the `lib` subdirectory. If the library directory is named something else, typically `lib64`, specify 

```
LIBDIR=lib64
```


## Writing your own rules

The above include files all operate by means of a shell script `names.sh`. So if you need to write your own configure rule,
you can still use this support infrastructure by using that script explicitly.

```
configure ::
        @source ${MAKEINCLUDES}/names.sh \
         && setnames ${PACKAGEROOT} ${PACKAGE} ${PACKAGEVERSION} "" ${PACKAGEBASENAME} \
```

The `names.sh` files defines the following variables:

- 