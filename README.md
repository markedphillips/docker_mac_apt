# Dockerized mac_apt (arm7hf and x86-64)
Dockerized macOS Artifact Parsing Tool

Below are the relevant links to the main project. The macOS Artifact Parsing Tool Docker image gets you to the commandline with mac_apt in four lines, the below example adds a system alias for future simplicity. Typically, an instagratification path for acquiring mac_apt on an arm7hf system would look like this:

```bash
git clone https://github.com/markedphillips/docker_mac_apt/
cd docker_mac_apt
docker build -f Dockerfile.arm7hf --tag mac_apt .
echo "alias mac_apt='docker run --rm -v '$(pwd):/home/docker' mac_apt'" >> ~/.bashrc
source ~/.bashrc
mac_apt -h
```
Of course, there was some simple set up for future docker runs with regards to the aliasing.  The vanilla Dockerfile uses phusion/baseimage-docker, its been tested with ubuntu and a few other variants at attempt to reduce comtainer size. 

mac_apt is a tool to process Mac computer full disk images and extract data/metadata useful for forensic investigation. It is designed to be cross-platform and uses python libraries that
work across mac, linux and windows. Even easier now that it is in a docker container.

mac_apt is a python based framework, which has plugins to process individual artifacts (such as Safari internet history, Network interfaces, Recently used files, Spotlight typed
searches..) The framework does the heavy lifting, parsing of disk/volume image and offers a unified output interface, which currently supports writing out data as CSV, Sqlite and Excel
formats. There is an API which plugins can use to access files and folders within the disk image. Currently DD and E01 images are supported. DMG files without compression work too. You
can use a mounted image too (with limited support on windows for this feature). We even put in a native HFS parser adding support for lzvn/lzfse compressed files.

macOS Artifact Parsing Tool 
github https://github.com/ydkhatri/mac_apt
blog https://swiftforensics.com

Built for arm7hf and x86-64 pull the image with:

Installation
```bash
docker pull markephillips/mac_apt:arm7hf
```
or clone this repository:

```bash
git clone https://github.com/markedphillips/docker_mac_apt/
docker build -f Dockerfile.arm7hf --tag mac_apt .
```

Remember above is for armhf and removing "-f Dockerfile.armhf" for x86-64. 

After building the image. Its easy to tag (to something else) and alias to hide the larger Docker command. (Or if you want to just chmod +x on docker_alias.sh and run.) 

```bash
docker tag mac_apt:latest mac_apt
echo "alias mac_apt='docker run --rm -v '$(pwd):/home/docker' mac_apt'" >> ~/.bashrc # or ~/.zshrc
```

Now easy sailing to use the tool..

```bash
mac_apt -h
```

#### _New in mac_apt - A native APFS parser to parse HighSierra images, plugins for spotlight and fsevents._

### Notable features:
* Cross platform (no dependency on pyobjc)
* Works on E01, DD, split-DD, DMG (no compression) & mounted images
* XLSX, CSV, Sqlite outputs
* Analyzed files/artifacts are exported for later review
* zlib, lzvn, lzfse compressed files are supported!
* APFS volumes are supported!

So far, we've tested this on OSX 10.9 (Mavericks) through 10.13 (HighSierra).

### Running mac_apt

There are 2 main launch scripts

| Script | When to use? |
| ------ | --------     |
| mac_apt.py | Use with full disk/volume images as input |
| mac_apt_singleplugin.py | Use with individual artifact files as input. This is when you do not have the full image but you have key files like com.apple.airport.preferences.plist to analyze. (Not every plugin supports this!) |

Running the -h option will show you the optional and required parameters.

    C:\Users\khatri>python c:\mac_apt\mac_apt.py -h
    usage: mac_apt.py [-h] [-o OUTPUT_PATH] [-x] [-c] [-s] [-l LOG_LEVEL] [-u]
                      input_type input_path plugin [plugin ...]
    
    mac_apt is a framework to process forensic artifacts on a Mac OSX system
    You are running macOS Artifact Parsing Tool version 0.3
    
    positional arguments:
      input_type            Specify Input type as either E01, DD or MOUNTED
      input_path            Path to OSX image/volume
      plugin                Plugins to run (space separated). 'ALL' will process every available plugin
    
    optional arguments:
      -h, --help            show this help message and exit
      -o OUTPUT_PATH, --output_path OUTPUT_PATH
                            Path where output files will be created
      -x, --xlsx            Save output in excel spreadsheet(s)
      -c, --csv             Save output as CSV files (Default option if no output type selected)
      -s, --sqlite          Save output in an sqlite database
      -l LOG_LEVEL, --log_level LOG_LEVEL
                            Log levels: INFO, DEBUG, WARNING, ERROR, CRITICAL (Default is INFO)
      -u, --use_tsk         Use sleuthkit instead of native HFS+ parser (This is slower!) 

    The following plugins are available:
        ALL                 Processes all plugins
        BASHSESSIONS        Reads bash (Terminal) sessions & history for every user
        BASICINFO           Gets basic machine and OS configuration like SN,
                            timezone, computer name, last logged in user, HFS info,
                            etc..
        BLUETOOTH           Parses System Bluetooth Artifacts
        DOCKITEMS           Reads the Dock plist for every user
        DOMAINS             Get information about ActiveDirectory Domain(s) that
                            this mac is connected to
        FSEVENTS            Reads file system event logs (from .fseventsd)
        IDEVICEBACKUPS      Reads and exports iPhone/iPad backup databases
        IMESSAGE            Parses iMessage conversations, exports messages and
                            attachments
        INETACCOUNTS        Reads configured internet account (iCloud, Google,
                            Linkedin, facebook..) settings used by Mail, Contacts,
                            Calendar and other apps
        INSTALLHISTORY      Parses the InstallHistory.plist to get software
                            installation history
        NETUSAGE            Reads the NetUsage (network usage) database to get
                            program and other network usage data
        NETWORKING          Gets network related information - Interfaces, last IP
                            addresses, MAC address, etc..
        NOTES               Reads Notes databases
        NOTIFICATIONS       Reads notification databases
        PRINTJOBS           Parses CUPS spooled print jobs to get information about
                            files/commands sent to a printer
        QUARANTINE          Reads Quarantine V2 databases, and GateKeeper
                            .LastGKReject file
        RECENTITEMS         Gets recently accessed Servers, Documents, Hosts,
                            Volumes & Applications from .plist and .sfl files. Also
                            gets recent searches and places for each user
        SAFARI              Gets internet history, downloaded file information,
                            cookies and more from Safari caches
        SPOTLIGHT           Reads spotlight indexes on volume
        SPOTLIGHTSHORTCUTS  Gets user typed data in the spotlight bar, used to
                            launch applications and documents
        USERS               Gets local and domain user information like name, UID,
                            UUID, GID, homedir & Darwin paths. Also extracts auto-
                            login stored passwords and deleted user info
        WIFI                Gets wifi network information from the
                            com.apple.airport.preferences.plist file

