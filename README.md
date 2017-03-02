# THIS REPOSITORY IS NO LONGER ACTIVE 

The new repository available here: [ria-ee/X-Road](https://github.com/ria-ee/X-Road)

# X-Road

This repository provides the source code of the X-Road software. X-Road is used as a backbone of the Finnish National Data Exchange Layer (Kansallinen palveluväylä), and it's developed in cooperation between the Estonian Information System Authority (RIA) and the Population Register Centre (VRK). The workflow policy for collaborative and open source software development of X-Road is described in the [workflow policy](WORKFLOW.md) document.

### Getting started

Using a Ubuntu 14.04 LTS build host is recommended.

A Vagrantfile for setting up a minimal build environment is provided (requires [Vagrant](https://www.vagrantup.com/); tested with [VirtualBox](https://www.virtualbox.org/) version 5).

#### Prerequisites:

- Java 8 ([Oracle](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) or [OpenJDK](http://openjdk.java.net/projects/jdk8/))
- [JRuby](http://jruby.org) and Ruby version manager [RVM](https://rvm.io/)
- [GCC](gcc.gnu.org)
- [Gradle](http://gradle.org/) build tool

The prerequisites with correct versions can be installed by running the src/prepare_buildhost.sh script (assumes Ubuntu).

#### Building X-Road:

- Change working directory to xroad-public/src
- Before the first build, run `update_ruby_dependencies.sh`
- Run `build_packages.sh`
    - builds X-Road components and creates Debian packages

Tip. When using the virtual build host, copy (or git clone) the source tree into the host to speed up building.

#### Building rpm installation packages for RHEL 7 on an Ubuntu host:

- A Dockerfile that creates a rpm packaging environment and builds rpm packages is provided in src/packages/docker
    - Note. The minimal build environment created using the Vagrantfile does not contain Docker.

### Installing an X-Road instance

See [ansible/README.md](ansible/README.md).

### Support / Contact / Contribution

Please file a [new issue](https://github.com/vrk-kpa/xroad-public/issues) at GitHub.

### Development guidelines

Please see [X-Road Joint Development](https://github.com/vrk-kpa/xroad-joint-development) repository for joint development work agreements and regulations.

### Copying and License

This material is copyright (c) 2015 Estonian Information System Authority (RIA), Population Register Centre (VRK).

The X-Road project is distributed under The MIT License (MIT). The full text of the license can be found at [LICENSE.txt](LICENSE.txt), and the -LICENSE.info -files.
