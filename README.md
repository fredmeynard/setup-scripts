# LighthouseLabs - Student machine setup script

Ideally we should have three versions of this script:

* **Linux (and Vagrant):** we'll use plain `apt-get` to install tools and setup Postgres, MongoDB, Redis and all other support services **plus** a nice git-aware command-prompt setup. Maybe we'll throw in a nice Vim distro too. After that we'll do a custom installation of Node with nvm to ensure we don't depend on distro-specific versions for that. The same is valid for Ruby/rbenv.
* **MacOS:** We'll do an automated run of `xcode-select --install`, `Postgres.app`, `Homebrew` and from that point on it should be smooth sailing using more or less same the code as the Linux version.
* **Windows 10 Anniversary Edition (stretch goal):** I'll play with this one first, but it should be possible to install the whole stack on top of the "Ubuntu for Windows" layer. Failing that, we should recommend students to install a full Linux desktop on top of Virtualbox to avoid driver issues.

For the Linux version: we'll make it clear this script is **only guaranteed to run on Ubuntu/Debian-style distros**. We can try to support `yum`-based as a stretch goal later.

## Objectives

* A single script should do the whole setup process with minimal user intervention.
* The script should be kept **updated and stable at all times**.
* The Vagrant box should be in a blank state when downloaded and use the exact same script to do the setup (excluding port forwarding, folder sharing and other Vagrant-specific details).

## List of tools to install

General:
* Git (and tig) √
* Vim √ (SPF13?)
* wget √
* tmux (and/or screen) √
* htop √
* Postgres √
* MongoDB - TODO: FIX INSTALLATION
* Redis √
* Node/nvm √
* Ruby/rbenv √
* git-aware bash prompt √
* Create and add `~/bin` to path (very useful for further customization) √
* ssh key generation (maybe?)

Linux:
* The `build-essential` package, before everything else. √
* Postgres: include proper user setup script. √
  * Ensure `-dev` libraries are also installed. √
* Redis and MongoDB: `-dev` libraries must also be installed. √
* Ensure Postgres, Mongo and Redis are starting on boot √
  * Also show students how to stop and restart these services

MacOS:
* `xcode-select --install`
* Homebrew
* Postgres.app
  * Add additional configurations to ensure `npm` modules and Ruby gems can compile native extensions
* MondoDB: add a start/stop script to `~/bin`
* Redis: add a start/stop script to `~/bin`
