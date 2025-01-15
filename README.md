- [Make support files](#Makesupportfiles)
- [Configure and install](#Configureinstall)
- [Module file](#Modulefile)
- [Customizations](#Customizations)

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
        -D DEAL_II_DIR=${TACC_DEALII_DIR}
include ${MAKEINCLUDES}/Make.cmake
include ${MAKEINCLUDES}/Make.cbuild

HASBIN = 1

TGZURL = https://github.com/geodynamics/aspect/releases/download/v${PACKAGEVERSION}/aspect-${PACKAGEVERSION}.tar.gz
include ${MAKEINCLUDES}/Make.download
include ${MAKEINCLUDES}/Make.clean
```

You see that it consists of some variables and some include files. Together this make it possible to say first

```
make download untar
```
and then 

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

* `PACKAGE` : this is the name of your package, without any version numbers and such. Don't worry about capitalization: all names are normalized.
* `PACKAGEVERSION` : this is the version number. If you do not a versioned version, but a repository checkout, use a fictitious version `git` or `git20230314` or so.

## Optional variables

In addition to the previous, you can have a line

```
MODE = seq # or mpi
```
that determines the type of compiler used, and influences the name of the module file and its location in the module hierarchy.

If your package needs other packages loaded, set

```
MODULES = petsc boost
```
or whatever may be the case. Variables `MODULE_MINIMUM_VERSION_yourpackage` can be used for a very simple test on mimimum versions.

Incompatible modules can be set with

```
NONMODULES = intel
```

## Directory structure

If you accept the default naming conventions, `PACKAGEROOT` is the root of the whole installation tree. Installation now obeys the following structure:

- `homedir = ${PACKAGEROOT}/${package}` is created by the `download/clone` calls. This will contain the source, build and install directories. Here `package` is an all-lowercase version of `${PACKAGE}`. Override this by setting `HOMEDIR`.
- `srcdir = ${homedir}/${packagebasename}-${packageversion}` is what downloads and clones are unpacked to and what is used for compilation. Override this by setting `SRCDIR`.

Next, the installation goes into 

- `builddir=${homedir}/build-$EXTENSION` where see below for the extension. You override this by setting `BUILDDIRROOT`, for instance to `/tmp/yourpackage`.
- `installdir=${homedir}/installation-$EXTENSION` where see below for the extension. You can override this partially by setting `INSTALLROOT` which will cause the install dir to be `installdir=${INSTALLROOT}/installation-$EXTENSION`, or completely by setting `INSTALLPATH`.

## Obtain the sources

You can make your Makefile do a package download or a repository checkout.

### Download tar or zip files

For downloadable packages, you would have two lines:

```
TGZURL = https://github.com/fmtlib/fmt/archive/${PACKAGEVERSION}.tar.gz
include ${MAKEINCLUDES}/Make.download
```

which allows you to `make download untar`. This creates the source directory:
 
```${PACKAGEROOT}/${PACKAGE}/${PACKAGE}-${PACKAGEVERSION}```

Note that the downloaded tar file does not necessarily contain a directory with this standardized name: in that case the unpacked directory is renamed from whatever gets unpacked.

* If the download is a `.zip` file, specify `ZIPURL=....`
instead of `TGZURL`.
* Compression with `xz` is supported: `TXZURL = package.tar.xz`.
* You can create a `.tgz` file from the standard name with `make retar`. (This is for instance convenient in TACC build jail.)

### Cloned repositories

For git repositories, you would have:

```
GITREPO= https://github.com/ECP-WarpX/WarpX.git
include ${MAKEINCLUDES}/Make.git
```

and use `make clone` and later `make pull`. This does the same directory renaming as for `tgz` downloads above. Use `CLONEARGS` for extra arguments such as `--depth=1`.

You can have all four of the `download/clone` lines, and use the 
package versions explicitly:

```
make download PACKAGEVERSION=3.1.4
make pull PACKAGEVERSION=git
```

#### Branches and submodules

To switch branches:

```
make pull BRANCH=somebranch
```
or permanently put the branch in your makefile.

You can override the download location by setting `DOWNLOADPATH`.

Setting `SUBMODULE` to anything non-blank causes 

```
git submodule init && git submodule update
```
on the clone.

#### Clone time stamp

Cloning a repository gives a `package-git` source directory. If you want to time-stamp your clone date, set `GITDATE` explicitly.

```
GITDATE=20250101 # explicit date
GITDATE=today    # use today's date
```
To recompile that clone at a later date, do 


```
make configure build GITDATE=20250101
```


#### Tarring the clone

Remember that we do some directory renaming after the download? It might be convenient have a tar file with the standardized name as above.

* There is a rule

```
make retar
```
that creates a new `.tgz` file that would unpack to the standardized name.

* Just like `make retar` for download sources, there is `make betar` for repositories; this creates a `tar.gz` file that unpacks to the repository directory. 

Why two separate rule names? Because you sometimes want both download & clone in the same makefile.

### Extra actions

If you need to download extra packages you can extend the `untar` rule:

```
untar ::
        @source ${MAKEINCLUDES}/names.sh \
         && setdirlognames "${PACKAGEROOT}" "${PACKAGE}" "${PACKAGEVERSION}" "${INSTALLEXT}" "${P\ACKAGEBASENAME}" "${VARIANT}" "${MODULENAME}" "${MODE}" \
         && cd $$srcdir \
         && wget http://tau.uoregon.edu/ext.tgz && tar fxz ext.tgz
```

# Configure and install

There is support for autotools and CMake based packages.
For both types of packages, the configure/install proceeds by

```
make configure build
```

This generates directories

```
${PACKAGEROOT}/${package}/build-${ID}
${PACKAGEROOT}/${package}/installation-${ID}
```

where `package` is the lowercase form of the package name, and`ID` is a composite of the version number, `TACC_FAMILY_COMPILER` and `TACC_FAMILY_MPI` for MPI packages. (For the rare package without a "make install" facility, set `NOINSTALL` to something non-null.)

You can set a totally explicit installpath with `INSTALLPATH=...` or replace the `${PACKAGEROOT}/${package}` part of the path by `INSTALLROOT=...`.

The installation stage also generates a modulefile; see below.

## The build/install process

For autotools installations, add these lines to your makefile:

```
include ${MAKEINCLUDES}/Make.configure
include ${MAKEINCLUDES}/Make.install
```

If the package uses `-prefix` instead of the usual `--prefix`, set the variable `PREFIXOPTION` to the desired option string.

For Cmake installation, add these lines:

```
include ${MAKEINCLUDES}/Make.cmake
include ${MAKEINCLUDES}/Make.cbuild
```

The  `make` is parallel: specify 

```JCOUNT=24```
in your makefile (or better: on your make commandline) to use 24 threads, et cetera.

## Customization

If the package does not generate a `lib` (or `lib64`) directory, set the variable `NOLIB` to anything nonzero.

If the package generates a `bin` directory, set `HASBIN` to something non-null. If the bin directory is other than `TACC_PACKAGE_DIR/bin`, set `BINDIR` to the location relative to `TACC_PACKAGE_DIR`.

By default, shared libraries are built. Set `BUILDSTATICLIBS` to nonnull to get static.

If the `configure` program or the `CMakeLists.txt` is hidden in a subdirectory, for instance `src`, set

```
CONFIGURESUBDIR=src
MAKESUBDIR=src
```

respectively

```
CMAKESUBDIR=src
```

If there is extra stuff, such as an examples directory, to copy into the installation, specify

```
CPTOINSTALLDIR = path1 path2
```
where the paths are relative to the source directory.

Sometimes CMake generates a `lib64` dir, but other packages rely on an 
older installation into `lib`. Set

```
LINKLIB64toLIB = 1
```
to let `lib` be a symlink to `lib64`. 
(Any already existing `lib` dir is first erased. 
This applies to `netcdf-fortran` which generates both `lib`
containing useless stuff, and `lib64` with the actual lib stuff.)
If no `lib64` exists, this is a no-op, but I hesitate to make
it a default.

If `make` needs an explicit target, set `MAKEBUILDTARGET`.
By default this macro is empty.

## Configure customization

The scripts try to detect the need for `autoconf` and `autogen`, but you can force preliminary actions in the source directory by setting

```
BEFORECONFIGURECMDS = autoreconf -i
```
et cetera.

## Permissions

The installation pass by default opens the install directory to the world.
If you write your own installation, do

```
include ${MAKEINCLUDES}/Make.public
```

and

```
make public
# or for system locations:
make public SUDO=sudo
```


# Module file

The build stage generates a modulefile using the guidelines of the Lmod package; see next.

## Default module file

The path to the module is determined as follows:

* Start at `${MODULEROOT}`
* If `MODE` IS `mpi`, append `MPI`, for mode `seq` append `Compiler`
* Append `${TACC_FAMILY_COMPILER}/${TACC_FAMILY_COMPILER_VERSION}`
* For MPI packages, append  `${TACC_FAMILY_MPI}/${LMOD_FAMILY_MPI_VERSION}`

After that the module is `${PACKAGE}/${PACKAGEVERSION}.lua`, where the package name has been lowercased. All directories upwards of the `MODULEROOT` are `mkdir`ed.

Two customizations:

 * Setting `MODULENAME` uses that instead of the package name (see for instance `phdf5` for the `hdf5` package);
 * Setting `MODULEVERSIONEXTRA` appends that to the package version with a dash; see the multiple petsc variants.

The `DIR,INC,LIB` variables are generated both with `TACC_`  and `LMOD_` prefix. Set `NOINC` or `NOLIB` to nonzero if the corresponding directory is missing; set `HASBIN` to nonzero if there is a `bin` directory.

If the makefile has a `URL` defined, this is listed as "Software" in the modulefile; if `DOCURL` is defined, this listed as "Documentation".

Setting `MODULEDIRSET` completely overrides this mechanism: this is the fully explicit location for the `.lua` file.

Setting `NOMODULE` to any non-blank value omits creation of the modulefile. That's good for when you build your own compiler or MPI: those modules need to inherit, declare `family`, et cetera.

## Explicit modulefile generation

The modulefile generation is usually taken care of by the cmake or autoconf `build` rule. In case you write that yourself, include 

```
include ${MAKEINCLUDES}/Make.vars
```

and use the command `make varsmodule` to create the modulefile.

If your configuration is too strange, you may want to specify the `INSTALLDIR` variable for the modulefile generation.

## CMake discoverability

If your package generates a `.pc` file, specify its location relative to the install directory by a line such as 

```
PKGCONFIG = share/pkgconfig
```

If the `pc` file is somewhere in the `lib` or `lib64` directory, specify

```
PKGCONFIGLIB = pkgconfig
```
which will use `lib` or `lib64` depending on what is found.

The resulting path will be added to the `PKG_CONFIG_PATH` in the modulefile.

Setting `CMAKEPREFIXPATHSET` to non-null causes the install prefix to be added to the `CMAKE_PREFIX_PATH`.

## More module stuff

Set the variable `HASBIN` to anything nonero to include a bin directory.  Otherwise the installation will assume that only `DIR/LIB/INC` apply.

	Conversely `NOLIB` (for instance for C++ header-only libraries) prevents a `TACC_PACKAGE_LIB` variable being generated. Likewise, `NOINC` prevents `TACC_PACKAGE_INC` from being generated. 

If the include directory is not immediately under the install directory, specify the relative path, including the `include` part:

```
INCLUDELOC = share/cmake/include
```

Some packages (mapl, gftl) install to `prefixloc/PACKAGE-1.2.3/{include,lib}` so use `INSTALLEXTRAPATH` to insert that bit.

You can add custom variables to the module by specifying

```
EXTRAVARS="var1=val1 var2=val2"
```

Likewise,

```
EXTRAINSTALLVARS = var=subdir
```
defines `var` relative to the installation directory. Also likewise, 

```
EXTRAINSTALLPATHS = var=path
```
prepends the path, relative to the install directory, to an existing value of the `var` path.

The `depends_on` clause in the modulefile is generated by the `DEPENDSON` variable:

```
DEPENDSON = whatever
## or:
DEPENDSON = whatever/1.1.1
```

Alternatively, use

```
DEPENDSONCURRENT = whatever
```

to pick up whatever current version of the dependency that the module is being built with. This looks for a variable `TACC_<whatever>_VERSION`. If this is not defined the version dependency is skipped.

You can have a second set of variables set by specifying `MODULENAMEALT`. For instance, setting an alternative name `HDF5` for the `phdf5` package defines both `TACC_PHDF5_....` and `TACC_HDF5_...` variables.
 
# Customizations

## Autotools configure

Define a variable `CONFIGUREFLAGS` in your makefile for any flags beyond the prefix.

If the configure file is hidden in a subdirectory, for instance `src`, add

```
CONFIGURESUBDIR = src
MAKESUBDIR = src
```

## CMake

Define a variable `CMAKEFLAGS` in your makefile for any configuration 
options beyond the installation prefix. The use of quotes in this flag is tricky:

```
CMAKEFLAGS=\
    -D CMAKE_CXX_FLAGS=\"-qsomething -qelse\" \
    -D CMAKEWHATEVER:BOOL=ON
```

However, for mere compiler flags,
set 

```
CMAKECOMPILERFLAGS=-Wno-whatever
```

to add identical flags to all three compilers.

Set `CPPSTANDARD=20` (et cetera) to dictate a specific C++ standard to CMake.

Set `BUILDSTATICLIBS` to nonzero in order to build static libraries,
rather than shared, which is the default.

Set `CMAKEBUILDDEBUG` to nonzero to get a `Debug` build; otherwise `RelWithDebInfo` is the default.

Set `CMAKEPREFIXLIB` to define the path to `.cmake` files, relative to the lib directory.


## Source directory

By default, the source is found in `${PACKAGEROOT}/${package}` where `package` is an all-lowercase version of `${PACKAGE}`. To override this, set the `SRCDIR` variable. Note that this convention is more or less enforced by the download and clone rules, which create this directory if it doesn't exist yet.

## Installation directory

The name and location of the installation directory 
are determined automatically as describe above. 
The location can be customized by setting `INSTALLPATH`.
The contents are whatever the `make install` stage puts there.

In the module file, the `LMOD_YOURPACKAGE_LIB` is set to the `lib` or `lib64` subdirectory, depending on which one is found. If the library directory is named something else entirely, specify 

```
LIBDIR=library
```

If your package has multiple installation modes (for instance cpu and gpu) you can add an extension to the install directory:

```
make build INSTALLEXT=cuda
```
This is appended to the automatically generated install directory name, as well as the module name.

## Writing your own rules

### Directory names

The above include files all operate by means of a shell script `names.sh`. So if you need to write your own configure rule,
you can still use this support infrastructure by using that script explicitly.

```
configure ::
        @source ${MAKEINCLUDES}/names.sh \
         && setnames ${PACKAGEROOT} ${PACKAGE} ${PACKAGEVERSION} "" ${PACKAGEBASENAME} \
```

The `names.sh` files defines the following variables:

 - `srcdir`, `builddir`, `installdir` for the package source, the temporary directory for building, and the final install location. The latter encodes the system, compiler, MPI names and versions for uniqueness.

- `configurelog`, `installlog` for qualified names of log files. You can use these or ignore them for your own names.

### Compilers

Secondly, there is a file `compilers.sh` which when sourced deduces the compiler from `TACC_FAMILY_COMPILER`, and sets environment variables `CC, CXX, FC` accordingly. For most autoconf and CMake installations that is enough.

## Some interesting use cases

### Hypre normal and bigint

We want a module `hypre/2.29.0` and `hypre/2.29.0-i64` with big integers.

```
.PHONY: small big
small :
        @make --no-print-directory configure build public \
            INSTALLVARIANT=i32
big :
        @make --no-print-directory configure build public \
            CONFIGUREFLAGS=--enable-bigint \
            INSTALLVARIANT=i64 INSTALLEXT=i64
```

The `INSTALLVARIANT` puts them installations in `..../hypre/2.29.0/{i32,i64}` while the `INSTALLEXT` (note: null for the `small` target) attaches `i64` to the modulename.

### Hdf5 and parallel hdf5

The problem here is to build two different modules from the same code base. This is done by calling make recursively, specifying the `MODULENAME` variable to override the default.

```
HDF5PARALLEL = ON
CMAKEFLAGS = -D HDF5_ENABLE_PARALLEL:BOOL=${HDF5PARALLEL}

.PHONY: seq par
seq :
        @make configure build JCOUNT=${JCOUNT} \
            PACKAGEVERSION=${PACKAGEVERSION} \
            HDF5PARALLEL=OFF MODE=seq MODULENAME=hdf5
par :
        @make configure build JCOUNT=${JCOUNT} \
            PACKAGEVERSION=${PACKAGEVERSION} \
            HDF5PARALLEL=ON  MODE=mpi \
            MODULENAME=phdf5 MODULENAMEALT=hdf5
```

Note the `MODULEALTNAME` for `phdf5`: this causes both `TACC_HDF5_...` and `TACC_PHDF5_...` variables to be defined.

### System install from user

The following uses source & makefiles in a user location, but installs software and modules to a system location:

```
make configure build \
    SUDO=sudo \ 
    INSTALLROOT=/opt/local/packages \
    MODULEROOT=/opt/local/modulefiles
```

### Jail install (TACC-specific)

In TACC jail you are in the source directory:

```
export SRCPATH=`pwd`
export VICTOR=/admin/build/admin/rpms/frontera/SPECS/victor_scripts
export MAKEINCLUDES=${VICTOR}/make-support-files
```

Now you go to the specific directory, here for `zlib`, and do a complicated commandline:

```
pushd ${VICTOR}/makefiles/zlib

make configure build JCOUNT=10 \
    HOMEDIR=/admin/build/admin/rpms/frontera/SOURCES \
    PACKAGEVERSION=%{pkg_version} \
    PACKAGEROOT=/tmp \
    SRCPATH=${SRCPATH} \
    INSTALLPATH=%{INSTALL_DIR} \
    MODULEDIRSET=$RPM_BUILD_ROOT/%{MODULE_DIR}
```
    
## Where do I find this stuff?

Make include files:
[https://github.com/VictorEijkhout/make-support-files](https://github.com/VictorEijkhout/make-support-files)

Makefiles for popular TACC packages:
[https://github.com/VictorEijkhout/Makefiles](https://github.com/VictorEijkhout/Makefiles)

Regression tests for TACC packages:
[https://github.com/VictorEijkhout/software-testing](https://github.com/VictorEijkhout/software-testing)
