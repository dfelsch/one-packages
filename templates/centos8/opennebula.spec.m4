%define oneadmin_home /var/lib/one
%define oneadmin_uid 9869
%define oneadmin_gid 9869

%define with_rubygems           0%{?_with_rubygems:1}
%define with_docker_machine     0%{?_with_docker_machine:1}
%define with_enterprise         0%{?_with_enterprise:1}
%define with_fireedge           0%{?_with_fireedge:1}
%define with_guacd              0%{!?_without_guacd:1}
%define with_oca_java           0%{!?_without_oca_java:1}
%define with_oca_java_prebuilt  0%{?_with_oca_java_prebuilt:1}
%define with_oca_python2        0%{!?_without_oca_python2:1}
%define with_oca_python3        0%{!?_without_oca_python3:1}

# distribution specific content
%define dir_sudoers  centos
%define dir_services systemd
%define dir_tmpfiles %{nil}

%if 0%{?fedora} >= 31
    %define with_oca_java_prebuilt 1
    %define with_oca_python2       0
    %define scons            scons-3
    %define gemfile_lock     Fedora%{?fedora}

    # don't mangle shebangs (e.g., fix /usr/bin/env ruby -> /usr/bin/ruby)
    %global __brp_mangle_shebangs_exclude_from ^(\/var\/lib\/one\/remotes\|\/usr\/share\/one\/gems-dist\/gems\|\/usr\/lib\/one\/sunstone\/public\/bower_components\/no-vnc\/node_modules\/uri-js\/dist\/esnext|\/usr\/lib/one\/sunstone\/guac\/node_modules\/uri-js\/dist\/esnext|\/usr\/lib\/one\/fireedge\/node_modules\/uri-js\/dist\/esnext)/

    # don't generate automatic requirements from bower components
    %global __requires_exclude_from ^(\/usr\/lib\/one\/sunstone\/public\/bower_components\/.*|\/usr\/lib\/python.*\/site-packages\/pyone-.*\.egg-info.*)$
%endif

%if 0%{?rhel} == 8
    %define with_oca_java_prebuilt 1
    %define scons            scons-3
    %define gemfile_lock     CentOS8
    %define dir_supervisor   centos8

    # don't mangle shebangs (e.g., fix /usr/bin/env ruby -> /usr/bin/ruby)
    %global __brp_mangle_shebangs_exclude_from ^(\/var\/lib\/one\/remotes\|\/usr\/share\/one\/gems-dist\/gems)/

    # don't generate automatic requirements from bower components
    %global __requires_exclude_from ^(\/usr\/lib\/one\/sunstone\/public\/bower_components\/.*|\/usr\/lib\/python.*\/site-packages\/pyone-.*\.egg-info.*)$
%endif

%if 0%{?rhel} == 7
    %global _hardened_build 1
    %define scons            scons
    %define gemfile_lock     CentOS7
%endif

# configuration management
%define onecfg_cfg /etc/onecfg.conf
%define onecfg_bak %{oneadmin_home}/backups/config

# Editions
%if %{with_enterprise}
    %define edition Enterprise Edition
    %define edition_short ee
    %define license OpenNebula Software License
    %define arg_enterprise yes
%else
    %define edition Community Edition
    %define edition_short ce
    %define license Apache
    %define arg_enterprise no
%endif

# Build arguments
%if %{with_fireedge}
    %define arg_fireedge yes
%else
    %define arg_fireedge no
%endif

# Version of Guacamole server
%define guacamole_version 1.2.0

Name: opennebula
Version: _VERSION_
Summary: OpenNebula Server and Scheduler (%{edition})
Release: _PKG_VERSION_%{?dist}
%if %{undefined packager}
Packager: Unofficial Unsupported Build
%endif
License: %{license}
Group: System
URL: https://opennebula.io

Source0: opennebula-%{version}.tar.gz
Source1: 50-org.libvirt.unix.manage-opennebula.pkla
Source2: xmlrpc-c.tar.gz
Source3: build_opennebula.sh
Source4: xml_parse_huge.patch
%if %{with_docker_machine}
Source5: opennebula-docker-machine-%{version}.tar.gz
%endif
%if %{with_oca_java_prebuilt}
Source9: java-oca-%{version}.tar.gz
%endif
%if %{with_rubygems}
Source10: opennebula-rubygems-%{version}.tar
%endif
%if %{with_enterprise}
Source11: opennebula-ee-tools-%{version}.tar.gz
%endif
%if %{with_fireedge}
Source12: opennebula-fireedge-modules-%{version}.tar.gz
%endif
%if %{with_guacd}
Source13: guacamole-server-%{guacamole_version}.zip
%endif

# Distribution specific KVM emulator paths to configure on front-end
Patch0: proper_path_emulator.diff

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

################################################################################
# Build Requires
################################################################################

BuildRequires: gcc-c++
BuildRequires: libcurl-devel
BuildRequires: libxml2-devel
BuildRequires: xmlrpc-c-devel
BuildRequires: openssl-devel
BuildRequires: mysql-devel
BuildRequires: libpq-devel
BuildRequires: sqlite-devel
BuildRequires: openssh
BuildRequires: pkgconfig
BuildRequires: ruby
BuildRequires: rubygems
BuildRequires: sqlite-devel
BuildRequires: systemd
BuildRequires: systemd-devel
BuildRequires: libvncserver-devel
BuildRequires: gnutls-devel
BuildRequires: libjpeg-turbo-devel
%if 0%{?rhel} == 8 || 0%{?fedora}
BuildRequires: python3-rpm-macros
BuildRequires: python3-scons
BuildRequires: /usr/bin/pathfix.py
BuildRequires: libnsl2-devel
%endif
%if 0%{?rhel} == 7
BuildRequires: epel-rpm-macros
BuildRequires: scons
%endif

%if %{with_rubygems}
BuildRequires: rubygems
BuildRequires: ruby-devel
BuildRequires: make
BuildRequires: gcc
BuildRequires: sqlite-devel
BuildRequires: mysql-devel
BuildRequires: openssl-devel
BuildRequires: curl-devel
BuildRequires: rubygem-rake
BuildRequires: libxml2-devel
BuildRequires: libxslt-devel
BuildRequires: patch
BuildRequires: expat-devel
BuildRequires: gcc-c++
BuildRequires: rpm-build
BuildRequires: augeas-devel
BuildRequires: postgresql-devel
%endif

%if %{with_fireedge}
BuildRequires: nodejs >= 10
BuildRequires: nodejs-devel >= 10
BuildRequires: npm
BuildRequires: zeromq-devel
BuildRequires: make
BuildRequires: gcc-c++
BuildRequires: python3
%endif

%if %{with_guacd}
BuildRequires: libtool
BuildRequires: autoconf
BuildRequires: cairo-devel
BuildRequires: uuid-devel
BuildRequires: freerdp-devel
BuildRequires: libssh2-devel
BuildRequires: pango-devel
BuildRequires: pulseaudio-libs-devel
BuildRequires: libwebp-devel
BuildRequires: libvorbis-devel
%endif

################################################################################
# Main Package
################################################################################

Requires: %{name}-tools = %{version}
Requires: %{name}-common-onecfg = %{version}
Requires: sqlite
Requires: openssh-server
Requires: genisoimage
Requires: qemu-img
Requires: xmlrpc-c
#VH Requires: nfs-utils
Requires: wget
Requires: curl
Requires: rsync
Requires: iputils
Requires: file
Requires: procps
Requires: util-linux
Requires: python3-libselinux
%if 0%{?rhel} == 8 || 0%{?fedora}
Requires: zeromq >= 4, zeromq < 5
%endif
%if 0%{?rhel} == 7
Requires: zeromq >= 4, zeromq < 5
%endif
# Devel package brings libzmq.so symlink required by ffi-rzmq-core gem
Requires: zeromq-devel
Provides: %{name}-server = %{version}
Obsoletes: %{name}-server < 5.13.80
Obsoletes: %{name}-addon-markets
Obsoletes: %{name}-ozones
%if %{with_enterprise}
Requires: %{name}-migration = %{version}
%else
Obsoletes: %{name}-migration
%endif

%description
OpenNebula Server and Scheduler daemons.

################################################################################
# Package opennebula-tools
################################################################################

%package tools
Summary: OpenNebula command line tools (%{edition})
Group: System
BuildArch: noarch
Requires: openssl
Requires: openssh
Requires: openssh-clients
Requires: /bin/more
Recommends: bash-completion
Recommends: gnuplot
Obsoletes: %{name} < 5.13.80
Obsoletes: %{name}-addon-tools
Requires: %{name}-common = %{version}
Requires: %{name}-common-onecfg = %{version}
Requires: %{name}-libs = %{version}
%if %{with_rubygems}
Requires: %{name}-rubygems = %{version}
%endif

%description tools
CLI tools for OpenNebula.

################################################################################
# Package common
################################################################################

%package common
Summary: Common OpenNebula package shared by various components (%{edition})
Group: System
BuildArch: noarch
Requires: %{name}-common-onecfg = %{version}
Requires: shadow-utils
Requires: coreutils
Requires: sudo
Requires: glibc-common

%description common
Common package shared by various OpenNebula components.

################################################################################
# Package common-onecfg
################################################################################

%package common-onecfg
Summary: Common OpenNebula package with helpers for onecfg (%{edition})
Group: System
BuildArch: noarch
Obsoletes: %{name}-common-onescape

%description common-onecfg
Helpers for OpenNebula onecfg

################################################################################
# Package libs
################################################################################

%package libs
Summary: OpenNebula libraries (%{edition})
Group: System
BuildArch: noarch
Obsoletes: %{name}-ruby < 5.13.80
Requires: ruby
Requires: rubygems
Requires: rubygem-bigdecimal
Requires: rubygem-json
Requires: rubygem-io-console
Requires: rubygem-psych
%if %{with_rubygems}
Requires: %{name}-rubygems = %{version}
%endif

%description libs
OpenNebula libraries.

################################################################################
# Package rubygems
################################################################################

%if %{with_rubygems}
%package rubygems
Summary: Ruby dependencies for OpenNebula (%{edition})
License: See bundled components
Group: System
Requires: ruby
Requires: rubygems
Obsoletes: %{name}-rubygem-activesupport
Obsoletes: %{name}-rubygem-addressable
Obsoletes: %{name}-rubygem-amazon-ec2
Obsoletes: %{name}-rubygem-augeas
Obsoletes: %{name}-rubygem-aws-eventstream
Obsoletes: %{name}-rubygem-aws-sdk
Obsoletes: %{name}-rubygem-aws-sdk-core
Obsoletes: %{name}-rubygem-aws-sdk-resources
Obsoletes: %{name}-rubygem-aws-sigv4
Obsoletes: %{name}-rubygem-azure
Obsoletes: %{name}-rubygem-azure-core
Obsoletes: %{name}-rubygem-builder
Obsoletes: %{name}-rubygem-chunky-png
Obsoletes: %{name}-rubygem-concurrent-ruby
Obsoletes: %{name}-rubygem-configparser
Obsoletes: %{name}-rubygem-curb
Obsoletes: %{name}-rubygem-daemons
Obsoletes: %{name}-rubygem-dalli
Obsoletes: %{name}-rubygem-eventmachine
Obsoletes: %{name}-rubygem-faraday
Obsoletes: %{name}-rubygem-faraday-middleware
Obsoletes: %{name}-rubygem-ffi
Obsoletes: %{name}-rubygem-ffi-rzmq
Obsoletes: %{name}-rubygem-ffi-rzmq-core
Obsoletes: %{name}-rubygem-hashie
Obsoletes: %{name}-rubygem-highline
Obsoletes: %{name}-rubygem-i18n
Obsoletes: %{name}-rubygem-inflection
Obsoletes: %{name}-rubygem-ipaddress
Obsoletes: %{name}-rubygem-jmespath
Obsoletes: %{name}-rubygem-memcache-client
Obsoletes: %{name}-rubygem-mime-types
Obsoletes: %{name}-rubygem-mime-types-data
Obsoletes: %{name}-rubygem-mini-portile2
Obsoletes: %{name}-rubygem-minitest
Obsoletes: %{name}-rubygem-multipart-post
Obsoletes: %{name}-rubygem-mustermann
Obsoletes: %{name}-rubygem-mysql2
Obsoletes: %{name}-rubygem-net-ldap
Obsoletes: %{name}-rubygem-nokogiri
Obsoletes: %{name}-rubygem-ox
Obsoletes: %{name}-rubygem-parse-cron
Obsoletes: %{name}-rubygem-polyglot
Obsoletes: %{name}-rubygem-public-suffix
Obsoletes: %{name}-rubygem-rack
Obsoletes: %{name}-rubygem-rack-protection
Obsoletes: %{name}-rubygem-rotp
Obsoletes: %{name}-rubygem-rqrcode
Obsoletes: %{name}-rubygem-rqrcode-core
Obsoletes: %{name}-rubygem-scrub-rb
Obsoletes: %{name}-rubygem-sequel
Obsoletes: %{name}-rubygem-sinatra
Obsoletes: %{name}-rubygem-sqlite3
Obsoletes: %{name}-rubygem-systemu
Obsoletes: %{name}-rubygem-thin
Obsoletes: %{name}-rubygem-thor
Obsoletes: %{name}-rubygem-thread-safe
Obsoletes: %{name}-rubygem-tilt
Obsoletes: %{name}-rubygem-treetop
Obsoletes: %{name}-rubygem-trollop
Obsoletes: %{name}-rubygem-tzinfo
Obsoletes: %{name}-rubygem-uuidtools
Obsoletes: %{name}-rubygem-xmlrpc
Obsoletes: %{name}-rubygem-xml-simple
Obsoletes: %{name}-rubygem-zendesk-api

%description rubygems
Ruby dependencies for OpenNebula.
%endif

################################################################################
# Package python
################################################################################

%if %{with_oca_python2}
%package -n python-pyone
Summary: Python 2 bindings for OpenNebula Cloud API, OCA (%{edition})
Group: System
BuildArch: noarch
%if 0%{?rhel} >= 8 || 0%{?fedora}
Requires: python2
BuildRequires: python2-devel
BuildRequires: python2-setuptools
BuildRequires: python2-wheel
%else
Requires: python
BuildRequires: python-devel
BuildRequires: python-setuptools
BuildRequires: python-wheel
%endif

%description -n python-pyone
Python 2 bindings for OpenNebula Cloud API (OCA).
%endif

%if %{with_oca_python3}
%package -n python3-pyone
Summary: Python 3 bindings for OpenNebula Cloud API, OCA (%{edition})
Group: System
BuildArch: noarch
Requires: python3
BuildRequires: python3-devel
BuildRequires: python3-setuptools
BuildRequires: python3-wheel

%description -n python3-pyone
Python 3 bindings for OpenNebula Cloud API (OCA).
%endif

################################################################################
# Package sunstone
################################################################################

%package sunstone
Summary: OpenNebula web interface Sunstone (%{edition})
BuildArch: noarch
Requires: %{name} = %{version}
Requires: %{name}-common = %{version}
Requires: %{name}-common-onecfg = %{version}
Requires: %{name}-libs = %{version}
%if %{with_rubygems}
Requires: %{name}-rubygems = %{version}
%endif
%if 0%{?rhel} == 8 || 0%{?fedora}
Requires: python3
Requires: python3-numpy
%endif
%if 0%{?rhel} == 7
Requires: python
Requires: numpy
%endif

%description sunstone
Browser based UI for OpenNebula cloud management and usage.

################################################################################
# Package fireedge
################################################################################

%if %{with_fireedge}
%package fireedge
Summary: OpenNebula web interface FireEdge (%{edition})
Requires: %{name}-common = %{version}
Requires: %{name}-common-onecfg = %{version}
Requires: %{name}-provision-data = %{version}
%if %{with_guacd}
Recommends: %{name}-guacd = %{version}
%endif

%description fireedge
Browser based UI for OpenNebula application management.
%endif

################################################################################
# Package gate
################################################################################

%package gate
Summary: OpenNebula Gate server (%{edition})
BuildArch: noarch
Requires: %{name}-common = %{version}
Requires: %{name}-common-onecfg = %{version}
Requires: %{name}-libs = %{version}
%if %{with_rubygems}
Requires: %{name}-rubygems = %{version}
%endif

%description gate
Server for information exchange between Virtual Machines and OpenNebula.

################################################################################
# Package flow
################################################################################

%package flow
Summary: OpenNebula Flow server (%{edition})
BuildArch: noarch
Requires: %{name}-common = %{version}
Requires: %{name}-common-onecfg = %{version}
Requires: %{name}-libs = %{version}
%if %{with_rubygems}
Requires: %{name}-rubygems = %{version}
%endif

%description flow
Server for multi-VM orchestration.

################################################################################
# Package Docker Machine ONE driver
################################################################################

%if %{with_docker_machine}
%package -n docker-machine-opennebula
Summary: OpenNebula driver for Docker Machine (%{edition})

%description -n docker-machine-opennebula
OpenNebula driver for the Docker Machine (note: Docker Machine needs
to be installed separately).
%endif

################################################################################
# Packages for Enterprise Edition
################################################################################

%if %{with_enterprise}
%package migration
License: OpenNebula Software License
Summary: Migration tools for OpenNebula Enterprise Edition
BuildArch: noarch
Requires: %{name} = %{version}
Requires: %{name}-tools = %{version}
Obsoletes: %{name}-migration-community

%description migration
Migration tools for OpenNebula Enterprise Edition

IMPORTANT: This package is distributed under "OpenNebula Software License".
See /usr/share/doc/one/LICENSE.onsla provided by opennebula-common package.

%package migration-community
License: OpenNebula Software License for Non-Commercial Use
Summary: Migration tools for OpenNebula Community Edition
BuildArch: noarch
Requires: %{name} >= 5.12, %{name} < 5.13
Obsoletes: %{name}-migration

%description migration-community
Migration tools for OpenNebula Community Edition

IMPORTANT: This package is distributed under the "OpenNebula Software License
for Non-Commercial Use". See /usr/share/doc/one/LICENSE.onsla-nc provided by
opennebula-common package.
%endif

################################################################################
# Package java
################################################################################

%if %{with_oca_java}
%package java
Summary: Java bindings for OpenNebula Cloud API, OCA (%{edition})
Group:   System
BuildArch: noarch
%if 0%{?rhel} == 8 || 0%{?fedora}
# no build dependencies available
#BuildRequires: java-11-openjdk-devel
%endif
%if 0%{?rhel} == 7
Requires: ws-commons-util
Requires: xmlrpc-common
Requires: xmlrpc-client
BuildRequires: java-1.7.0-openjdk-devel
BuildRequires: ws-commons-util
BuildRequires: xmlrpc-c
BuildRequires: xmlrpc-common
BuildRequires: xmlrpc-client
%endif

%description java
Java bindings for OpenNebula Cloud API (OCA)
%endif

################################################################################
# Package node-kvm
################################################################################

%package node-kvm
Summary: Services for OpenNebula KVM node (%{edition})
Group: System
Conflicts: %{name}-node-xen
Conflicts: %{name}-node-firecracker
BuildArch: noarch
Requires: ruby
Requires: openssh-server
Requires: openssh-clients
Requires: rsync
Requires: libvirt
Requires: qemu-kvm
Requires: qemu-img
Requires: nfs-utils
Requires: ipset
Requires: pciutils
Requires: cronie
Requires: augeas
Requires: rubygem-sqlite3
# This package does not exist in CentOS 7
Requires: %{name}-common = %{version}

%description node-kvm
Services and configurations for OpenNebula KVM node.

################################################################################
# Package node-firecracker
################################################################################

%package node-firecracker
Summary: Services for OpenNebula Firecracker node (%{edition})
Group: System
Conflicts: %{name}-node-xen
Conflicts: %{name}-node-kvm
Requires: ruby
Requires: openssh-server
Requires: openssh-clients
Requires: rsync
Requires: nfs-utils
Requires: ipset
Requires: cronie
Requires: rubygem-sqlite3
Requires: libvncserver
Requires: screen
Requires: bsdtar
Requires: e2fsprogs
Requires: lsof
Requires: qemu-img
# This package does not exist in CentOS 7
Requires: %{name}-common = %{version}

%description node-firecracker
Services and configurations for OpenNebula Firecracker node.

################################################################################
# Package provisioning tool
################################################################################

%package provision
Summary: OpenNebula infrastructure provisioning (%{edition})
BuildArch: noarch
Requires: %{name} = %{version}
Requires: %{name}-common = %{version}
Requires: %{name}-common-onecfg = %{version}
Requires: %{name}-tools = %{version}
Requires: %{name}-libs = %{version}
Requires: %{name}-provision-data = %{version}
%if %{with_rubygems}
Requires: %{name}-rubygems = %{version}
%endif

%description provision
OpenNebula provisioning tool

################################################################################
# Package provision-data
################################################################################

%package provision-data
Summary: OpenNebula infrastructure provisioning data (%{edition})
BuildArch: noarch

%description provision-data
OpenNebula infrastructure provisioning data

################################################################################
# Package guacd
################################################################################

%if %{with_guacd}
%package guacd
Release: %{guacamole_version}+_PKG_VERSION_%{?dist}
License: ASL 2.0
Summary: Provides Guacamole server for Fireedge to be used in Sunstone (%{edition})

%description guacd
OpenNebula Guacamole server
%endif


################################################################################
# Build and install
################################################################################

%prep
%setup -q
%if %{with_docker_machine}
%setup -T -D -a 5
%endif
%if %{with_oca_java} && %{with_oca_java_prebuilt}
%setup -T -D -a 9
mv java-oca-%{version}/jar/ src/oca/java/
%endif
%if %{with_rubygems}
%setup -T -D -a 10
%endif
%if %{with_enterprise}
%setup -T -D -a 11
%endif
%if %{with_fireedge}
%setup -T -D -a 12
%endif
%if %{with_guacd}
%setup -T -D -a 13
%endif

%patch0 -p1

%build
%set_build_flags
# Uncompress xmlrpc-c and copy build_opennebula.sh
(
    cd ..
    tar xzvf %{SOURCE2}
    cp %{SOURCE3} %{SOURCE4} .
)

%if %{with_rubygems}
pushd opennebula-rubygems-%{version}
    NOKOGIRI_USE_SYSTEM_LIBRARIES=yes \
    GEM_PATH=$PWD/gems-dist/ \
    GEM_HOME=$PWD/gems-dist/ \
        gem install \
            --local \
            --ignore-dependencies \
            --no-document \
            --conservative \
            --install-dir $PWD/gems-dist \
            --bindir $PWD/gems-dist/bin/ \
            $(cat manifest)

    # drop build artifacts
    rm -rf gems-dist/cache gems-dist/gems/*/ext
popd
%endif

%if %{with_guacd}
pushd guacamole-server-*
    autoreconf -i
    ./configure \
        --prefix=/usr/share/one/guacd \
        --exec-prefix=/usr/share/one/guacd \
        --with-freerdp-plugin-dir=/usr/share/one/guacd \
        --disable-static \
        --without-pulse
    make
popd
%endif

%if %{with_fireedge}
export CXXFLAGS="${CXXFLAGS} -I/usr/include/node"
npm config set nodedir /usr/include/node
npm config set offline true
npm config set zmq_external true

pushd src/fireedge
    # backup original package-lock.json and update dependencies locations
    # from remote https:// to local predownloaded files
    cp package-lock.json package-lock.json.bak
    sed -i -e 's/\(resolved": "\).*\//\1file:..\/..\/opennebula-fireedge-modules-%{version}\//' package-lock.json
popd
%endif

# Compile OpenNebula
# scons -j2 mysql=yes new_xmlrpc=yes
export SCONS=%{scons}
../build_opennebula.sh \
    systemd=yes \
    gitversion='%{gitversion}' \
    enterprise=%{?arg_enterprise} \
    fireedge=%{?arg_fireedge}

%if %{with_fireedge}
    mv -f src/fireedge/package-lock.json.bak src/fireedge/package-lock.json
%endif

%if %{with_oca_java} && ! %{with_oca_java_prebuilt}
pushd src/oca/java
    ./build.sh -d
popd
%endif

%if %{with_enterprise}
pushd one-ee-tools/src/onedb/
    ./build.rb
popd
%endif

%install
rm -rf src/sunstone/public/node_modules/ || :
export DESTDIR=%{buildroot}
./install.sh
%if %{with_docker_machine}
    ./install.sh -e
%endif

%if %{with_enterprise}
pushd one-ee-tools
    ./install-ee-tools.sh
    install -p -D -m 644 src/onedb/local/5.12.0_to_6.0.0.rbm  %{buildroot}/usr/lib/one/ruby/onedb/local/
    install -p -D -m 644 src/onedb/shared/5.12.0_to_6.0.0.rbm %{buildroot}/usr/lib/one/ruby/onedb/shared/
popd
%endif

# Guacamole
%if %{with_guacd}
pushd guacamole-server-*
    %make_install
    rm -rf %{buildroot}/usr/share/one/guacd/include
popd

install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-guacd.service %{buildroot}/lib/systemd/system/opennebula-guacd.service
%endif

%if %{with_enterprise}
echo EE > %{buildroot}/%{_sharedstatedir}/one/remotes/EDITION
%else
echo CE > %{buildroot}/%{_sharedstatedir}/one/remotes/EDITION
%endif

%if %{with_rubygems}
cp -a opennebula-rubygems-%{version}/gems-dist %{buildroot}/usr/share/one/
%endif

# Init scripts
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula.service                     %{buildroot}/lib/systemd/system/opennebula.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-ssh-agent.service           %{buildroot}/lib/systemd/system/opennebula-ssh-agent.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-ssh-socks-cleaner.service   %{buildroot}/lib/systemd/system/opennebula-ssh-socks-cleaner.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-ssh-socks-cleaner.timer     %{buildroot}/lib/systemd/system/opennebula-ssh-socks-cleaner.timer
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-showback.service            %{buildroot}/lib/systemd/system/opennebula-showback.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-showback.timer              %{buildroot}/lib/systemd/system/opennebula-showback.timer
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-scheduler.service           %{buildroot}/lib/systemd/system/opennebula-scheduler.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-hem.service                 %{buildroot}/lib/systemd/system/opennebula-hem.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-sunstone.service            %{buildroot}/lib/systemd/system/opennebula-sunstone.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-gate.service                %{buildroot}/lib/systemd/system/opennebula-gate.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-econe.service               %{buildroot}/lib/systemd/system/opennebula-econe.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-flow.service                %{buildroot}/lib/systemd/system/opennebula-flow.service
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-novnc.service               %{buildroot}/lib/systemd/system/opennebula-novnc.service

install -p -D -m 644 share/pkgs/tmpfiles/%{dir_tmpfiles}/opennebula-common.conf %{buildroot}/%{_tmpfilesdir}/opennebula-common.conf
install -p -D -m 644 share/pkgs/tmpfiles/%{dir_tmpfiles}/opennebula-node.conf %{buildroot}/%{_tmpfilesdir}/opennebula-node.conf

install -p -D -m 644 %{SOURCE1} \
        %{buildroot}%{_sysconfdir}/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla

# supervisor scripts
%if %{defined dir_supervisor}
%{__mkdir} -p %{buildroot}%{_datadir}/one/supervisor/
cp -a share/pkgs/services/supervisor/%{dir_supervisor}/* %{buildroot}%{_datadir}/one/supervisor/
%endif

# sudoers
%{__mkdir} -p %{buildroot}%{_sysconfdir}/sudoers.d
install -p -D -m 440 share/pkgs/sudoers/%{dir_sudoers}/opennebula %{buildroot}%{_sysconfdir}/sudoers.d/opennebula
install -p -D -m 440 share/pkgs/sudoers/opennebula-server %{buildroot}%{_sysconfdir}/sudoers.d/opennebula-server
install -p -D -m 440 share/pkgs/sudoers/opennebula-node-kvm %{buildroot}%{_sysconfdir}/sudoers.d/opennebula-node-kvm
install -p -D -m 440 share/pkgs/sudoers/opennebula-node-firecracker   %{buildroot}%{_sysconfdir}/sudoers.d/opennebula-node-firecracker

# logrotate
%{__mkdir} -p %{buildroot}%{_sysconfdir}/logrotate.d
install -p -D -m 644 share/pkgs/logrotate/opennebula           %{buildroot}%{_sysconfdir}/logrotate.d/opennebula
install -p -D -m 644 share/pkgs/logrotate/opennebula-econe     %{buildroot}%{_sysconfdir}/logrotate.d/opennebula-econe
install -p -D -m 644 share/pkgs/logrotate/opennebula-flow      %{buildroot}%{_sysconfdir}/logrotate.d/opennebula-flow
install -p -D -m 644 share/pkgs/logrotate/opennebula-gate      %{buildroot}%{_sysconfdir}/logrotate.d/opennebula-gate
install -p -D -m 644 share/pkgs/logrotate/opennebula-novnc     %{buildroot}%{_sysconfdir}/logrotate.d/opennebula-novnc
install -p -D -m 644 share/pkgs/logrotate/opennebula-scheduler %{buildroot}%{_sysconfdir}/logrotate.d/opennebula-scheduler
install -p -D -m 644 share/pkgs/logrotate/opennebula-hem       %{buildroot}%{_sysconfdir}/logrotate.d/opennebula-hem
install -p -D -m 644 share/pkgs/logrotate/opennebula-sunstone  %{buildroot}%{_sysconfdir}/logrotate.d/opennebula-sunstone

# FireEdge
%if %{with_fireedge}
install -p -D -m 644 share/pkgs/services/%{dir_services}/opennebula-fireedge.service            %{buildroot}/lib/systemd/system/opennebula-fireedge.service
install -p -D -m 644 share/pkgs/logrotate/opennebula-fireedge  %{buildroot}%{_sysconfdir}/logrotate.d/opennebula-fireedge
%else
# TODO: don't install with install.sh FireEdge
rm -rf \
    %{buildroot}/usr/lib/one/fireedge/ \
    %{buildroot}%{_bindir}/fireedge-server \
    %{buildroot}%{_sysconfdir}/one/fireedge-server.conf
%endif

# Java
%if %{with_oca_java}
install -p -D -m 644 src/oca/java/jar/org.opennebula.client.jar %{buildroot}%{_javadir}/org.opennebula.client.jar
%endif

# sysctl
install -p -D -m 644 share/etc/sysctl.d/bridge-nf-call.conf %{buildroot}%{_sysconfdir}/sysctl.d/bridge-nf-call.conf

# cron
install -p -D -m 644 share/etc/cron.d/opennebula-node %{buildroot}%{_sysconfdir}/cron.d/opennebula-node

# Gemfile
%if %{defined gemfile_lock}
install -p -D -m 644 share/install_gems/%{gemfile_lock}/Gemfile.lock %{buildroot}/usr/share/one/Gemfile.lock
%endif

# Shell completion
install -p -D -m 644 share/shell/bash_completion          %{buildroot}%{_sysconfdir}/bash_completion.d/opennebula

# oned.aug
%{__mkdir} -p %{buildroot}/usr/share/augeas/lenses
install -p -D -m 644 share/augeas/oned.aug %{buildroot}/usr/share/augeas/lenses/oned.aug

# Python
cd src/oca/python
%if %{with_oca_python2}
make install ROOT=%{buildroot}
%endif
%if %{with_oca_python3}
make install3 ROOT=%{buildroot}
%endif
cd -

%if 0%{?rhel} == 8 || 0%{?fedora}
# fix ambiguous Python shebangs
pathfix.py -pni "%{__python3} %{py3_shbang_opts}" %{buildroot}/usr/lib/one/sunstone/public/bower_components/guacamole-common-js/guacamole/util/*.py
pathfix.py -pni "%{__python3} %{py3_shbang_opts}" %{buildroot}/usr/lib/one/sunstone/public/bower_components/no-vnc/utils/*.py
pathfix.py -pni "%{__python3} %{py3_shbang_opts}" %{buildroot}/usr/share/one/websockify/websockify/websocketproxy.py
pathfix.py -pni "%{__python3} %{py3_shbang_opts}" %{buildroot}/usr/share/one/websockify/run
%endif

# Firecracker
%{__mkdir} -p %{buildroot}/srv/jailer/firecracker
install -p -D -m 755 src/svncterm_server/svncterm_server                                    %{buildroot}%{_bindir}/svncterm_server
install -p -D -m 755 src/vmm_mad/remotes/lib/firecracker/one-clean-firecracker-domain       %{buildroot}%{_sbindir}/one-clean-firecracker-domain
install -p -D -m 755 src/vmm_mad/remotes/lib/firecracker/one-prepare-firecracker-domain     %{buildroot}%{_sbindir}/one-prepare-firecracker-domain

# fix permissions
%{__chmod} -R o-rwx %{buildroot}/var/lib/one/remotes

%clean
%{__rm} -rf %{buildroot}

################################################################################
# common - scripts
################################################################################

%pre common
getent group oneadmin >/dev/null || groupadd -r -g %{oneadmin_gid} oneadmin
if getent passwd oneadmin >/dev/null; then
    /usr/sbin/usermod -a -G oneadmin oneadmin > /dev/null
else
    mkdir %{oneadmin_home} || :
    chcon -t user_home_dir_t %{oneadmin_home} 2>/dev/null || :
    cp /etc/skel/.bash* %{oneadmin_home}
    chown -R %{oneadmin_uid}:%{oneadmin_gid} %{oneadmin_home}
    /usr/sbin/useradd -r -m -d %{oneadmin_home} \
        -u %{oneadmin_uid} -g %{oneadmin_gid} \
        -s /bin/bash oneadmin 2> /dev/null
fi

if ! getent group disk | grep '\boneadmin\b' &>/dev/null; then
    usermod -a -G disk oneadmin
fi

%post common
if [ $1 = 1 ]; then
    # only on install once again fix directory SELinux type
    # TODO: https://github.com/OpenNebula/one/issues/739
    chcon -t user_home_dir_t %{oneadmin_home} 2>/dev/null || :

    # install ~oneadmin/.ssh/config if not present on a fresh install only
    if [ ! -e '%{oneadmin_home}/.ssh/config' ]; then
        if [ ! -d '%{oneadmin_home}/.ssh' ]; then
            mkdir -p '%{oneadmin_home}/.ssh'
            chmod 0700 '%{oneadmin_home}/.ssh'
            chown '%{oneadmin_uid}:%{oneadmin_gid}' '%{oneadmin_home}/.ssh'
        fi
        cp /usr/share/one/ssh/config '%{oneadmin_home}/.ssh/config'
        chmod 0600 '%{oneadmin_home}/.ssh/config'
        chown '%{oneadmin_uid}:%{oneadmin_gid}' '%{oneadmin_home}/.ssh/config'
    fi
fi

systemd-tmpfiles --create /usr/lib/tmpfiles.d/opennebula-common.conf || :

################################################################################
# common-onecfg - scripts
################################################################################

%pre common-onecfg
### Backup configuration ###

# better fail silently than break installation
set +e

# migrate old OneScape configuration
if [ -d '/etc/onescape' ]; then
    if [ -f '/etc/onescape/config.yaml' ] && [ ! -f '%{onecfg_cfg}' ]; then
        mv /etc/onescape/config.yaml '%{onecfg_cfg}'
    fi

    rm -rf /etc/onescape
fi

# create backup directory
if [ ! -d '%{onecfg_bak}' ]; then
    mkdir -p '%{onecfg_bak}'
    chmod 700 '%{onecfg_bak}'
    chown 'root:root' '%{onecfg_bak}'

    # FIX: parent directory, just safety check if we would change onecfg_bak
    if [ -d '%{oneadmin_home}/backups' ]; then
        chmod 700 '%{oneadmin_home}/backups'
        chown '%{oneadmin_uid}:%{oneadmin_gid}' '%{oneadmin_home}/backups'
    fi
fi

# detect previous installed version
PREV_VERSION=${PREV_VERSION:-$(oned --version 2>/dev/null | grep '^OpenNebula [0-9.]*[[:space:]]' | cut -d' ' -f2)}
PREV_VERSION=${PREV_VERSION:-$(grep -x "^[[:space:]]*VERSION = '[0-9.]*'[[:space:]]*" /usr/lib/one/ruby/opennebula.rb | cut -d"'" -f2)}
PREV_VERSION=${PREV_VERSION:-$(cat /var/lib/one/remotes/VERSION 2>/dev/null)}

# upgrade
if [ -n "${PREV_VERSION}" ]; then
    # backup configuration
    BACKUP_DIR="%{onecfg_bak}/$(date +'%Y-%m-%d_%H:%M:%%S')-v${PREV_VERSION:-UNKNOWN}"
    mkdir "${BACKUP_DIR}"
    chmod 700 "${BACKUP_DIR}"

    for DIR in '/etc/one' '/var/lib/one/remotes'; do
        if [ -d "${DIR}" ]; then
            # We try to mimic filesystem structure in backups, e.g.
            # /etc/one/oned.conf -> $BACKUP_DIR/etc/one/oned.conf
            DIR_PARENT="$(dirname "${DIR}")"
            mkdir -p "${BACKUP_DIR}/${DIR_PARENT}"
            cp -a "${DIR}" "${BACKUP_DIR}/${DIR_PARENT}"
        fi
    done

    if [ -f '%{onecfg_cfg}' ]; then
       # if it already contains backup, we put obsolete
       # flag and don't modify backup again.
       if grep -qF 'backup:' '%{onecfg_cfg}'; then
           if ! grep -qF 'outdated: true' '%{onecfg_cfg}'; then
               printf "\noutdated: true\n" >> '%{onecfg_cfg}'
           fi
       else
           printf "\nbackup: '%%s'\n" "${BACKUP_DIR}" >> '%{onecfg_cfg}'
       fi
    else
        # create new configuration
        cat - <<EOF >'%{onecfg_cfg}'
---
backup: '${BACKUP_DIR}'
EOF

        # and, put version inside if known
        if [ -n "${PREV_VERSION}" ]; then
            printf "\nversion: '%%s'\n" "${PREV_VERSION}" >> '%{onecfg_cfg}'
        fi
    fi

# install
elif [ "$1" = '1' ]; then
    cat - <<EOF >'%{onecfg_cfg}'
---
version: '%{version}'
EOF
fi

# pass silently
set -e
/bin/true

################################################################################
# main package - scripts
################################################################################

%pre
# Upgrade - Stop the service
if [ $1 = 2 ]; then
    /sbin/service opennebula stop >/dev/null || :
    /sbin/service opennebula-scheduler stop >/dev/null || :
    /sbin/service opennebula-hem stop >/dev/null || :
    /sbin/service opennebula-ssh-agent stop >/dev/null || :
fi

%post
if [ $1 = 1 ]; then
    if [ ! -e %{oneadmin_home}/.one/one_auth ]; then
        PASSWORD=$(echo $RANDOM$(date '+%s')|md5sum|cut -d' ' -f1)
        mkdir -p %{oneadmin_home}/.one
        /bin/chmod 700 %{oneadmin_home}/.one
        echo oneadmin:$PASSWORD > %{oneadmin_home}/.one/one_auth
        /bin/chown -R oneadmin:oneadmin %{oneadmin_home}/.one
        /bin/chmod 600 %{oneadmin_home}/.one/one_auth
    fi

    if [ ! -f "%{oneadmin_home}/.ssh/id_rsa" ]; then
        su oneadmin -c "ssh-keygen -N '' -t rsa -f %{oneadmin_home}/.ssh/id_rsa"
        if ! [ -f "%{oneadmin_home}/.ssh/authorized_keys" ]; then
            cp -p %{oneadmin_home}/.ssh/id_rsa.pub %{oneadmin_home}/.ssh/authorized_keys
            /bin/chmod 600 %{oneadmin_home}/.ssh/authorized_keys
        fi
    fi
fi
systemctl daemon-reload 2>/dev/null || :

%preun
if [ $1 = 0 ]; then
    /sbin/service opennebula stop >/dev/null || :
    /sbin/service opennebula-scheduler stop >/dev/null || :
    /sbin/service opennebula-hem stop >/dev/null || :
    /sbin/service opennebula-ssh-agent stop >/dev/null || :
fi

%postun
if [ $1 = 0 ]; then
    systemctl daemon-reload 2>/dev/null || :

    # Remove logs
    #NOTE: We don't remove all the daemon logs, as this is not common
    # behaviour of the RPM packages. We drop only logs from VMs, as
    # they could be reused if new installation is done again on same
    # host with fresh new database.
    rm -rf /var/log/one/[[:digit:]]*.log

    # Remove vms directory
    rm -rf /var/lib/one/vms

    # Remove empty datastore directories
    for DIR in /var/lib/one/datastores/*   \
               /var/lib/one/datastores/.*  \
               /var/lib/one/datastores; do
        # ignore . and ..
        BASE_DIR=$(basename "${DIR}")
        if [ "${BASE_DIR}" = '.' ] || [ "${BASE_DIR}" = '..' ]; then
            continue
        fi

        if [ -d "${DIR}" ]; then
            rmdir --ignore-fail-on-non-empty "${DIR}" 2>/dev/null || :
        fi
    done
fi

%triggerpostun -- opennebula-server
# This workarounds deprecation of opennebula-server<5.13.80 in favour
# of main opennebula package. On such deprecation, the removal of
# opennebula-server package results in running its %postun scriptlet
# in uninstalling(!!!), not upgrading, mode which removes some state
# directories we still require for current opennebula.
if [ $2 = 0 ]; then
    DIR_VMS=/var/lib/one/vms

    if [ -d /var/lib/one ] && ! [ -d "${DIR_VMS}" ]; then
        mkdir "${DIR_VMS}"
        chown oneadmin:oneadmin "${DIR_VMS}"
        chmod 0750 "${DIR_VMS}"
    fi
fi

################################################################################
# node-kvm - scripts
################################################################################

%post node-kvm
# Install
if [ -e /etc/libvirt/qemu.conf ]; then
    cp -f /etc/libvirt/qemu.conf "/etc/libvirt/qemu.conf.$(date +'%Y-%m-%d_%H:%M:%%S')"
fi

if [ -e /etc/libvirt/libvirtd.conf ]; then
    cp -f /etc/libvirt/libvirtd.conf "/etc/libvirt/libvirtd.conf.$(date +'%Y-%m-%d_%H:%M:%%S')"
fi

AUGTOOL=$(augtool -A 2>/dev/null <<EOF
set /augeas/load/Libvirtd_qemu/lens Libvirtd_qemu.lns
set /augeas/load/Libvirtd_qemu/incl /etc/libvirt/qemu.conf
set /augeas/load/Libvirtd/lens Libvirtd.lns
set /augeas/load/Libvirtd/incl /etc/libvirt/libvirtd.conf
load

set /files/etc/libvirt/qemu.conf/user oneadmin
set /files/etc/libvirt/qemu.conf/group oneadmin
set /files/etc/libvirt/qemu.conf/dynamic_ownership 0

# Disable PolicyKit https://github.com/OpenNebula/one/issues/1768
set /files/etc/libvirt/libvirtd.conf/auth_unix_ro none
set /files/etc/libvirt/libvirtd.conf/auth_unix_rw none
set /files/etc/libvirt/libvirtd.conf/unix_sock_group oneadmin
set /files/etc/libvirt/libvirtd.conf/unix_sock_ro_perms 0770
set /files/etc/libvirt/libvirtd.conf/unix_sock_rw_perms 0770

save
EOF
)

# generate generic qemu-kvm-one symlink
/usr/bin/qemu-kvm-one-gen

if [ -n "${AUGTOOL}" ] && [ -z "${AUGTOOL##*Saved *}" ]; then
    systemctl try-restart libvirtd 2>/dev/null || true
fi

if [ $1 = 2 ]; then
    # Upgrade
    PID=$(cat /tmp/one-monitord-client.pid 2> /dev/null)
    [ -n "$PID" ] && kill $PID 2> /dev/null || :
fi

%postun node-kvm
if [ $1 = 0 ]; then
    # Uninstall
    if [ -e /etc/libvirt/qemu.conf ]; then
        cp -f /etc/libvirt/qemu.conf "/etc/libvirt/qemu.conf.$(date +'%Y-%m-%d_%H:%M:%%S')"
    fi

    if [ -e /etc/libvirt/libvirtd.conf ]; then
        cp -f /etc/libvirt/libvirtd.conf "/etc/libvirt/libvirtd.conf.$(date +'%Y-%m-%d_%H:%M:%%S')"
    fi

    AUGTOOL=$(augtool -A 2>/dev/null <<EOF || /bin/true
set /augeas/load/Libvirtd_qemu/lens Libvirtd_qemu.lns
set /augeas/load/Libvirtd_qemu/incl /etc/libvirt/qemu.conf
set /augeas/load/Libvirtd/lens Libvirtd.lns
set /augeas/load/Libvirtd/incl /etc/libvirt/libvirtd.conf
load

rm /files/etc/libvirt/qemu.conf/user[. = 'oneadmin']
rm /files/etc/libvirt/qemu.conf/group[. = 'oneadmin']
rm /files/etc/libvirt/qemu.conf/dynamic_ownership[. = '0']

# Disable PolicyKit https://github.com/OpenNebula/one/issues/1768
rm /files/etc/libvirt/libvirtd.conf/auth_unix_ro[. = 'none']
rm /files/etc/libvirt/libvirtd.conf/auth_unix_rw[. = 'none']
rm /files/etc/libvirt/libvirtd.conf/unix_sock_group[. = 'oneadmin']
rm /files/etc/libvirt/libvirtd.conf/unix_sock_ro_perms[. = '0770']
rm /files/etc/libvirt/libvirtd.conf/unix_sock_rw_perms[. = '0770']

save
EOF
)

    # remove generic qemu-kvm-one symlink
    rm -f /usr/bin/qemu-kvm-one

    if [ -n "${AUGTOOL}" ] && [ -z "${AUGTOOL##*Saved *}" ]; then
        systemctl try-restart libvirtd 2>/dev/null || :
    fi
fi

################################################################################
# node-firecracker - scripts
################################################################################

%post node-firecracker
# Changes ownership of chroot folder
mkdir -p /srv/jailer/firecracker
chown -R oneadmin:oneadmin /srv/jailer
chmod 750 /srv/jailer

# Install firecracker + jailer
/usr/sbin/install-firecracker || exit $?

if [ $1 = 2 ]; then
    # Upgrade
    PID=$(cat /tmp/one-monitord-client.pid 2> /dev/null)
    [ -n "$PID" ] && kill $PID 2> /dev/null || :
fi

%postun node-firecracker
if [ $1 = 0 ]; then
    rm -f /usr/bin/firecracker
    rm -f /usr/bin/jailer
    # TODO, should /srv/jailer/* be removed (it may contains VM information)
fi

################################################################################
# provision - scripts
################################################################################

%post provision
if [ $1 = 1 ]; then
    if [ ! -d "%{oneadmin_home}/.ssh-oneprovision/" ]; then
        su oneadmin -c "mkdir %{oneadmin_home}/.ssh-oneprovision/"
        su oneadmin -c "chmod 700 %{oneadmin_home}/.ssh-oneprovision/"
        chcon -t ssh_home_t %{oneadmin_home}/.ssh-oneprovision
        su oneadmin -c "ssh-keygen -N '' -t rsa -f %{oneadmin_home}/.ssh-oneprovision/id_rsa"
    fi
fi

################################################################################
# sunstone - scripts
################################################################################

%pre sunstone
# Upgrade - Stop the service
if [ $1 = 2 ]; then
    /sbin/service opennebula-sunstone stop >/dev/null || :
    /sbin/service opennebula-novnc stop >/dev/null || :
    /sbin/service opennebula-econe stop >/dev/null || :
fi

%post sunstone
systemctl daemon-reload 2>/dev/null || :

if [ ! -f /var/lib/one/sunstone/main.js ]; then
    touch /var/lib/one/sunstone/main.js
fi

chown oneadmin:oneadmin /var/lib/one/sunstone/main.js

%preun sunstone
if [ $1 = 0 ]; then
    /sbin/service opennebula-sunstone stop >/dev/null  || :
    /sbin/service opennebula-novnc stop >/dev/null  || :
    /sbin/service opennebula-econe stop >/dev/null || :

    if [ -f /var/lib/one/sunstone/main.js ]; then
        rm -f /var/lib/one/sunstone/main.js 2>/dev/null || :
    fi
fi

%postun sunstone
if [ $1 = 0 ]; then
    systemctl daemon-reload 2>/dev/null || :
fi

################################################################################
# fireedge - scripts
################################################################################

%if %{with_fireedge}
%pre fireedge
# Upgrade - Stop the service
if [ $1 = 2 ]; then
    /sbin/service opennebula-fireedge stop >/dev/null || :
fi

%post fireedge
systemctl daemon-reload 2>/dev/null || :

%preun fireedge
if [ $1 = 0 ]; then
    /sbin/service opennebula-fireedge stop >/dev/null  || :
fi

%postun fireedge
if [ $1 = 0 ]; then
    systemctl daemon-reload 2>/dev/null || :
fi
%endif

################################################################################
# guacd - scripts
################################################################################

%if %{with_guacd}
%pre guacd
# Upgrade - Stop the service
if [ $1 = 2 ]; then
    /sbin/service opennebula-guacd stop >/dev/null || :
fi

%post guacd
systemctl daemon-reload 2>/dev/null || :

%preun guacd
if [ $1 = 0 ]; then
    /sbin/service opennebula-guacd stop >/dev/null  || :
fi

%postun guacd
if [ $1 = 0 ]; then
    systemctl daemon-reload 2>/dev/null || :
fi
%endif

################################################################################
# gate scripts
################################################################################

%pre gate
# Upgrade - Stop the service
if [ $1 = 2 ]; then
    /sbin/service opennebula-gate stop 2>/dev/null || :
fi

%preun gate
if [ $1 = 0 ]; then
    /sbin/service opennebula-gate stop 2>/dev/null || :
fi

%post gate
systemctl daemon-reload 2>/dev/null || :

%postun gate
if [ $1 = 0 ]; then
    systemctl daemon-reload 2>/dev/null || :
fi

################################################################################
# flow scripts
################################################################################

%pre flow
# Upgrade - Stop the service
if [ $1 = 2 ]; then
    /sbin/service opennebula-flow stop 2>/dev/null || :
fi

%preun flow
if [ $1 = 0 ]; then
    /sbin/service opennebula-flow stop 2>/dev/null || :
fi

%post flow
systemctl daemon-reload 2>/dev/null || :

%postun flow
if [ $1 = 0 ]; then
    systemctl daemon-reload 2>/dev/null || :
fi

################################################################################
# libs - scripts
################################################################################

%post libs
if ! [ -d /usr/share/one/gems/ ]; then
    cat <<EOF
==========================[ WARNING ]==================================
Packaged Ruby gems not symlinked to /usr/share/one/gems/. Don't forget
to manually execute command /usr/share/one/install_gems to install or
update all the OpenNebula required Ruby gems system-wide !!!
==========================[ WARNING ]==================================
EOF
fi

################################################################################
# rubygems - scripts
################################################################################

%if %{with_rubygems}
%post rubygems
if [ $1 = 1 ] && [ ! -e /usr/share/one/gems ]; then
    ln -s gems-dist /usr/share/one/gems
fi

%postun rubygems
if [ $1 = 0 ] && [ -L /usr/share/one/gems ]; then
    unlink /usr/share/one/gems
fi
%endif

################################################################################
# python - scripts
################################################################################

%if %{with_oca_python2}
%post -n python-pyone
echo ""
echo "WARNING: Unmanaged dependencies, please install following:"
echo "pip install six aenum lxml dicttoxml future tblib xmltodict"
echo ""

%postun -n python-pyone
echo ""
echo "WARNING: Unmanaged dependencies, please consider uninstalling following:"
echo "pip uninstall six aenum lxml dicttoxml future tblib xmltodict"
echo ""
%endif

%if %{with_oca_python3}
%post -n python3-pyone
echo ""
echo "WARNING: Unmanaged dependencies, please install following:"
echo "pip3 install six aenum lxml dicttoxml tblib xmltodict"
echo ""

%postun -n python3-pyone
echo ""
echo "WARNING: Unmanaged dependencies, please consider uninstalling following:"
echo "pip3 uninstall six aenum lxml dicttoxml tblib xmltodict"
echo ""
%endif

################################################################################
# Enterprise Edition - scripts
################################################################################

%if %{with_enterprise}
%pre migration-community
cat <<EOF
# -------------------------------------------------------------------------- #
# Copyright 2019-2020, OpenNebula Systems S.L.                               #
#                                                                            #
# Licensed under the OpenNebula Software License for Non-Commercial Use      #
# (the "License"); you may not use this file except in compliance with       #
# the License. You may obtain a copy of the License as part of the software  #
# distribution.                                                              #
#                                                                            #
# See https://github.com/OpenNebula/one/blob/master/LICENSE.onsla-nc         #
# (or copy bundled with OpenNebula in /usr/share/doc/one/).                  #
#                                                                            #
# Unless agreed to in writing, software distributed under the License is     #
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY   #
# KIND, either express or implied. See the License for the specific language #
# governing permissions and  limitations under the License.                  #
# -------------------------------------------------------------------------- #

OpenNebula Community Edition Migration package is distributed under the above
license only for non-commercial use. By installing the package, you agree with
the license. Installation will automatically continue in 10 seconds ...
EOF

sleep 10
%endif

################################################################################
# common - files
################################################################################

%files common
%attr(0440, root, root) %config %{_sysconfdir}/sudoers.d/opennebula
%attr(0750, oneadmin, oneadmin) %dir %{_sharedstatedir}/one
%dir /usr/lib/one
%dir %{_datadir}/one
%dir /usr/share/doc/one
%dir /usr/share/one/ssh
%doc /usr/share/doc/one/*
/usr/share/one/ssh/*
%{_tmpfilesdir}/opennebula-common.conf
%{_tmpfilesdir}/opennebula-node.conf

%defattr(0640, oneadmin, oneadmin, 0750)
%dir %{_localstatedir}/lock/one
%dir %{_localstatedir}/log/one
%dir %{_localstatedir}/run/one

################################################################################
# common-onecfg - files
################################################################################

%files common-onecfg

################################################################################
# node-kvm - files
################################################################################

%files node-kvm
%config %{_sysconfdir}/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla
%config %{_sysconfdir}/sysctl.d/bridge-nf-call.conf
%config %{_sysconfdir}/cron.d/opennebula-node
%attr(0440, root, root) %config %{_sysconfdir}/sudoers.d/opennebula-node-kvm
%{_bindir}/qemu-kvm-one-gen

################################################################################
# node-firecracker - files
################################################################################

%files node-firecracker
%config %{_sysconfdir}/sysctl.d/bridge-nf-call.conf
%config %{_sysconfdir}/cron.d/opennebula-node
%attr(0755, root, root) %{_sbindir}/install-firecracker
%{_sbindir}/one-clean-firecracker-domain
%{_sbindir}/one-prepare-firecracker-domain
%{_bindir}/svncterm_server
%attr(0440, root, root) %config %{_sysconfdir}/sudoers.d/opennebula-node-firecracker
%attr(0750, oneadmin, oneadmin) %dir /srv/jailer/firecracker

################################################################################
# java - files
################################################################################

%if %{with_oca_java}
%files java
%defattr(-,root,root)
%{_javadir}/org.opennebula.client.jar
%endif

################################################################################
# python - files
################################################################################

%if %{with_oca_python2}
%files -n python-pyone
%defattr(-, root, root, 0755)
%dir %{python2_sitelib}/pyone
%{python2_sitelib}/pyone/*
%dir %{python2_sitelib}/pyone*.egg-info
%{python2_sitelib}/pyone*.egg-info/*
%endif

%if %{with_oca_python3}
%files -n python3-pyone
%defattr(-, root, root, 0755)
%dir %{python3_sitelib}/pyone
%{python3_sitelib}/pyone/*
%dir %{python3_sitelib}/pyone*.egg-info
%{python3_sitelib}/pyone*.egg-info/*
%endif

################################################################################
# libs - files
################################################################################

%files libs
%defattr(-, root, root, 0755)
%dir /usr/lib/one/ruby/opennebula
/usr/lib/one/ruby/opennebula.rb
/usr/lib/one/ruby/opennebula/*
%dir /usr/lib/one/ruby/vendors
/usr/lib/one/ruby/vendors/packethost

# required by Sunstone
%dir /usr/lib/one/ruby
/usr/lib/one/ruby/scripts_common.rb
/usr/lib/one/ruby/nsx_driver.rb
%dir /usr/lib/one/ruby/nsx_driver
/usr/lib/one/ruby/nsx_driver/*
%dir /usr/lib/one/ruby/vcenter_driver
/usr/lib/one/ruby/vcenter_driver.rb
/usr/lib/one/ruby/vcenter_driver/*

%dir /usr/lib/one/ruby/cloud
/usr/lib/one/ruby/cloud/CloudClient.rb
/usr/lib/one/ruby/cloud/CloudAuth.rb
/usr/lib/one/ruby/cloud/CloudServer.rb
%dir /usr/lib/one/ruby/cloud/CloudAuth
/usr/lib/one/ruby/cloud/CloudAuth/*

%{_datadir}/one/install_gems
%{_datadir}/one/Gemfile
%if %{defined gemfile_lock}
%{_datadir}/one/Gemfile.lock
%endif

################################################################################
# rubygems - files
################################################################################

%if %{with_rubygems}
%files rubygems
%dir %{_datadir}/one/gems-dist
%{_datadir}/one/gems-dist/*
%endif

################################################################################
# sunstone - files
################################################################################

%files sunstone
%attr(0751, root, oneadmin) %dir %{_sysconfdir}/one
%config %{_sysconfdir}/logrotate.d/opennebula-econe
%config %{_sysconfdir}/logrotate.d/opennebula-sunstone
%config %{_sysconfdir}/logrotate.d/opennebula-novnc
%dir /usr/lib/one/sunstone
/usr/lib/one/sunstone/*
/usr/lib/one/ruby/OpenNebulaVNC.rb
/usr/lib/one/ruby/opennebula_guac.rb
/usr/lib/one/ruby/OpenNebulaAddons.rb
/usr/lib/one/ruby/opennebula_vmrc.rb
%dir /usr/lib/one/ruby/cloud/econe
/usr/lib/one/ruby/cloud/econe/*
%dir %{_datadir}/one/websockify
%{_datadir}/one/websockify/*

%{_bindir}/sunstone-server
%{_bindir}/novnc-server
%{_bindir}/econe-server
%{_bindir}/econe-allocate-address
%{_bindir}/econe-associate-address
%{_bindir}/econe-attach-volume
%{_bindir}/econe-create-keypair
%{_bindir}/econe-create-volume
%{_bindir}/econe-delete-keypair
%{_bindir}/econe-delete-volume
%{_bindir}/econe-describe-addresses
%{_bindir}/econe-describe-images
%{_bindir}/econe-describe-instances
%{_bindir}/econe-describe-keypairs
%{_bindir}/econe-describe-volumes
%{_bindir}/econe-detach-volume
%{_bindir}/econe-disassociate-address
%{_bindir}/econe-reboot-instances
%{_bindir}/econe-register
%{_bindir}/econe-release-address
%{_bindir}/econe-run-instances
%{_bindir}/econe-start-instances
%{_bindir}/econe-stop-instances
%{_bindir}/econe-terminate-instances
%{_bindir}/econe-upload

%{_mandir}/man1/econe-allocate-address.1*
%{_mandir}/man1/econe-associate-address.1*
%{_mandir}/man1/econe-attach-volume.1*
%{_mandir}/man1/econe-create-keypair.1*
%{_mandir}/man1/econe-create-volume.1*
%{_mandir}/man1/econe-delete-keypair.1*
%{_mandir}/man1/econe-delete-volume.1*
%{_mandir}/man1/econe-describe-addresses.1*
%{_mandir}/man1/econe-describe-images.1*
%{_mandir}/man1/econe-describe-instances.1*
%{_mandir}/man1/econe-describe-keypairs.1*
%{_mandir}/man1/econe-describe-volumes.1*
%{_mandir}/man1/econe-detach-volume.1*
%{_mandir}/man1/econe-disassociate-address.1*
%{_mandir}/man1/econe-reboot-instances.1*
%{_mandir}/man1/econe-register.1*
%{_mandir}/man1/econe-release-address.1*
%{_mandir}/man1/econe-run-instances.1*
%{_mandir}/man1/econe-start-instances.1*
%{_mandir}/man1/econe-stop-instances.1*
%{_mandir}/man1/econe-terminate-instances.1*
%{_mandir}/man1/econe-upload.1*

/lib/systemd/system/opennebula-sunstone.service
/lib/systemd/system/opennebula-econe.service
/lib/systemd/system/opennebula-novnc.service

%defattr(0640, root, oneadmin, 0750)
%dir %{_sysconfdir}/one/ec2query_templates
%dir %{_sysconfdir}/one/sunstone-views
%config %{_sysconfdir}/one/sunstone-server.conf
%config %{_sysconfdir}/one/sunstone-logos.yaml
%config %{_sysconfdir}/one/ec2query_templates/*
%config %{_sysconfdir}/one/econe.conf
%config %{_sysconfdir}/one/sunstone-views.yaml
%config %{_sysconfdir}/one/sunstone-views/*

%defattr(0640, oneadmin, oneadmin, 0750)
%dir %{_sharedstatedir}/one/sunstone
%exclude %{_sharedstatedir}/one/sunstone/main.js

################################################################################
# fireedge - files
################################################################################

%if %{with_fireedge}
%files fireedge
%attr(0751, root, oneadmin) %dir %{_sysconfdir}/one
%config %{_sysconfdir}/logrotate.d/opennebula-fireedge
%dir /usr/lib/one/fireedge
/usr/lib/one/fireedge/*
%{_bindir}/fireedge-server

/lib/systemd/system/opennebula-fireedge.service

%defattr(0640, root, oneadmin, 0750)
%config %{_sysconfdir}/one/fireedge-server.conf
%endif

################################################################################
# gate - files
################################################################################

%files gate
%attr(0751, root, oneadmin) %dir %{_sysconfdir}/one
%config %{_sysconfdir}/logrotate.d/opennebula-gate
%dir /usr/lib/one/onegate
/usr/lib/one/onegate/*
%{_bindir}/onegate-server
/lib/systemd/system/opennebula-gate.service

%defattr(0640, root, oneadmin, 0750)
%config %{_sysconfdir}/one/onegate-server.conf

################################################################################
# flow - files
################################################################################

%files flow
%attr(0751, root, oneadmin) %dir %{_sysconfdir}/one
%config %{_sysconfdir}/logrotate.d/opennebula-flow
%dir /usr/lib/one/oneflow
/usr/lib/one/oneflow/*
%{_bindir}/oneflow-server
/lib/systemd/system/opennebula-flow.service

%defattr(0640, root, oneadmin, 0750)
%config %{_sysconfdir}/one/oneflow-server.conf

################################################################################
# docker-machine - files
################################################################################

%if %{with_docker_machine}
%files -n docker-machine-opennebula
%{_bindir}/docker-machine-driver-opennebula
%endif

################################################################################
# provision - files
################################################################################

%files provision
%{_bindir}/oneprovision
%{_bindir}/oneprovider
%{_bindir}/oneprovision-template
%config %{_sysconfdir}/one/cli/oneprovision.yaml
%config %{_sysconfdir}/one/cli/oneprovider.yaml
%config %{_sysconfdir}/one/cli/oneprovision_template.yaml
/usr/lib/one/ruby/cli/one_helper/oneprovision_helper.rb
/usr/lib/one/ruby/cli/one_helper/oneprovider_helper.rb
/usr/lib/one/ruby/cli/one_helper/oneprovision_template_helper.rb
%dir /usr/lib/one/oneprovision
/usr/lib/one/oneprovision/*
%{_mandir}/man1/oneprovision.1*
%{_mandir}/man1/oneprovider.1*
%{_mandir}/man1/oneprovision-template.1*

################################################################################
# provision-data - files
################################################################################

%files provision-data
%dir %{_datadir}/one/oneprovision
%{_datadir}/one/oneprovision/*

################################################################################
# Packages for Enterprise Edition - files
################################################################################

%if %{with_enterprise}
%files migration
/usr/lib/one/ruby/onedb/local/*.rb
/usr/lib/one/ruby/onedb/shared/*.rb

%files migration-community
/usr/lib/one/ruby/onedb/local/5.12.0_to_6.0.0.rbm
/usr/lib/one/ruby/onedb/shared/5.12.0_to_6.0.0.rbm
%endif

################################################################################
# main package - files
################################################################################

%files
%attr(0440, root, root) %config %{_sysconfdir}/sudoers.d/opennebula-server
%attr(0751, root, oneadmin) %dir %{_sysconfdir}/one
%config %{_sysconfdir}/logrotate.d/opennebula
%config %{_sysconfdir}/logrotate.d/opennebula-scheduler
%config %{_sysconfdir}/logrotate.d/opennebula-hem
/lib/systemd/system/opennebula.service
/lib/systemd/system/opennebula-scheduler.service
/lib/systemd/system/opennebula-ssh-agent.service
/lib/systemd/system/opennebula-ssh-socks-cleaner.service
/lib/systemd/system/opennebula-ssh-socks-cleaner.timer
/lib/systemd/system/opennebula-showback.service
/lib/systemd/system/opennebula-showback.timer
/lib/systemd/system/opennebula-hem.service
/usr/share/augeas/lenses/oned.aug

%if %{defined dir_supervisor}
%dir /usr/share/one/supervisor
/usr/share/one/supervisor/*
%endif

%{_bindir}/mm_sched
%{_bindir}/one
%{_bindir}/oned
%{_bindir}/onedb
%{_bindir}/onehem-server
%{_bindir}/onecfg

%dir %{_datadir}/one/examples
%{_datadir}/one/examples/*
%dir %{_datadir}/one/esx-fw-vnc
%{_datadir}/one/esx-fw-vnc/*
%{_datadir}/one/follower_cleanup
%dir %{_datadir}/one/start-scripts
%{_datadir}/one/start-scripts/*
%dir %{_datadir}/one/schemas
%{_datadir}/one/schemas/*
%dir %{_datadir}/one/context
%{_datadir}/one/context/*
%dir %{_datadir}/one/dockerhub
%{_datadir}/one/dockerhub/*
%dir %{_datadir}/one/onecfg
%{_datadir}/one/onecfg/*

%dir /usr/lib/one/mads
/usr/lib/one/mads/*
%dir /usr/lib/one/onehem
/usr/lib/one/onehem/*
%dir /usr/lib/one/ruby
/usr/lib/one/ruby/ActionManager.rb
/usr/lib/one/ruby/az_driver.rb
/usr/lib/one/ruby/CommandManager.rb
/usr/lib/one/ruby/DriverExecHelper.rb
/usr/lib/one/ruby/ec2_driver.rb
/usr/lib/one/ruby/aws_vnm.rb
/usr/lib/one/ruby/packet_vnm.rb
%dir /usr/lib/one/ruby/onedb
%dir /usr/lib/one/ruby/onedb/local
%dir /usr/lib/one/ruby/onedb/shared
%dir /usr/lib/one/ruby/onedb/fsck
%dir /usr/lib/one/ruby/onedb/patches
/usr/lib/one/ruby/onedb/*.rb
/usr/lib/one/ruby/onedb/fsck/*
/usr/lib/one/ruby/onedb/patches/*
/usr/lib/one/ruby/one_vnm.rb
/usr/lib/one/ruby/opennebula_driver.rb
/usr/lib/one/ruby/OpenNebulaDriver.rb
/usr/lib/one/ruby/ssh_stream.rb
/usr/lib/one/ruby/packet_driver.rb
/usr/lib/one/ruby/VirtualMachineDriver.rb
/usr/lib/one/ruby/PublicCloudDriver.rb
%dir /usr/lib/one/sh
/usr/lib/one/sh/*
%dir /usr/lib/one/onecfg
/usr/lib/one/onecfg/*
%dir /usr/share/one/conf
/usr/share/one/conf/*

%if %{with_enterprise}
%{_bindir}/onesupport
%{_bindir}/onesupport_vcenter_privs
%endif

%{_mandir}/man1/onecfg.1*
%{_mandir}/man1/onedb.1*
%doc LICENSE LICENSE.onsla LICENSE.onsla-nc NOTICE

%defattr(0640, root, oneadmin, 0750)
%dir %{_sysconfdir}/one/auth
%dir %{_sysconfdir}/one/auth/certificates
%dir %{_sysconfdir}/one/hm
%dir %{_sysconfdir}/one/vmm_exec
%config %{_sysconfdir}/one/defaultrc
%config %{_sysconfdir}/one/tmrc
%config %{_sysconfdir}/one/hm/*
%config %{_sysconfdir}/one/oned.conf
%config %{_sysconfdir}/one/onehem-server.conf
%config %{_sysconfdir}/one/sched.conf
%config %{_sysconfdir}/one/monitord.conf
%config %{_sysconfdir}/one/vmm_exec/*
%config %{_sysconfdir}/one/az_driver.conf
%config %{_sysconfdir}/one/az_driver.default
%config %{_sysconfdir}/one/ec2_driver.conf
%config %{_sysconfdir}/one/ec2_driver.default
%config %{_sysconfdir}/one/vcenter_driver.default
%config %{_sysconfdir}/one/auth/server_x509_auth.conf
%config %{_sysconfdir}/one/auth/ldap_auth.conf
%config %{_sysconfdir}/one/auth/x509_auth.conf

%defattr(-, oneadmin, oneadmin, 0750)
%dir %{_sharedstatedir}/one/datastores
%dir %{_sharedstatedir}/one/remotes
%dir %{_sharedstatedir}/one/vms

%exclude %{_sharedstatedir}/one/datastores/*
%{_sharedstatedir}/one/remotes/*
%config %{_sharedstatedir}/one/remotes/etc/*

################################################################################
# guacd - files
################################################################################

%if %{with_guacd}
%files guacd
%dir /usr/share/one/guacd
/usr/share/one/guacd/*
/lib/systemd/system/opennebula-guacd.service
%endif

################################################################################
# tools - files
################################################################################

%files tools
%attr(0751, root, oneadmin) %dir %{_sysconfdir}/one
%dir %{_sysconfdir}/one/cli
%config %{_sysconfdir}/one/cli/oneacct.yaml
%config %{_sysconfdir}/one/cli/oneacl.yaml
%config %{_sysconfdir}/one/cli/onecluster.yaml
%config %{_sysconfdir}/one/cli/onedatastore.yaml
%config %{_sysconfdir}/one/cli/oneflow.yaml
%config %{_sysconfdir}/one/cli/oneflowtemplate.yaml
%config %{_sysconfdir}/one/cli/onegroup.yaml
%config %{_sysconfdir}/one/cli/onehook.yaml
%config %{_sysconfdir}/one/cli/onehost.yaml
%config %{_sysconfdir}/one/cli/oneimage.yaml
%config %{_sysconfdir}/one/cli/onemarket.yaml
%config %{_sysconfdir}/one/cli/onemarketapp.yaml
%config %{_sysconfdir}/one/cli/onesecgroup.yaml
%config %{_sysconfdir}/one/cli/oneshowback.yaml
%config %{_sysconfdir}/one/cli/onetemplate.yaml
%config %{_sysconfdir}/one/cli/oneuser.yaml
%config %{_sysconfdir}/one/cli/onevdc.yaml
%config %{_sysconfdir}/one/cli/onevmgroup.yaml
%config %{_sysconfdir}/one/cli/onevm.yaml
%config %{_sysconfdir}/one/cli/onevnet.yaml
%config %{_sysconfdir}/one/cli/onevntemplate.yaml
%config %{_sysconfdir}/one/cli/onevrouter.yaml
%config %{_sysconfdir}/one/cli/onezone.yaml

%{_bindir}/oneacct
%{_bindir}/oneacl
%{_bindir}/onecluster
%{_bindir}/onedatastore
%{_bindir}/onegroup
%{_bindir}/onehook
%{_bindir}/onehost
%{_bindir}/oneimage
%{_bindir}/onemarket
%{_bindir}/onemarketapp
%{_bindir}/onesecgroup
%{_bindir}/oneshowback
%{_bindir}/onetemplate
%{_bindir}/oneuser
%{_bindir}/onevcenter
%{_bindir}/onevdc
%{_bindir}/onevm
%{_bindir}/onevmgroup
%{_bindir}/onevnet
%{_bindir}/onevntemplate
%{_bindir}/onevrouter
%{_bindir}/onezone

%{_bindir}/oneflow
%{_bindir}/oneflow-template

%{_mandir}/man1/oneacct.1*
%{_mandir}/man1/oneacl.1*
%{_mandir}/man1/onecluster.1*
%{_mandir}/man1/onedatastore.1*
%{_mandir}/man1/oneflow.1*
%{_mandir}/man1/oneflow-template.1*
%{_mandir}/man1/onegroup.1*
%{_mandir}/man1/onehook.1*
%{_mandir}/man1/onehost.1*
%{_mandir}/man1/oneimage.1*
%{_mandir}/man1/onemarket.1*
%{_mandir}/man1/onemarketapp.1*
%{_mandir}/man1/onesecgroup.1*
%{_mandir}/man1/oneshowback.1*
%{_mandir}/man1/onetemplate.1*
%{_mandir}/man1/oneuser.1*
%{_mandir}/man1/onevcenter.1*
%{_mandir}/man1/onevdc.1*
%{_mandir}/man1/onevm.1*
%{_mandir}/man1/onevmgroup.1*
%{_mandir}/man1/onevnet.1*
%{_mandir}/man1/onevntemplate.1*
%{_mandir}/man1/onevrouter.1*
%{_mandir}/man1/onezone.1*

%dir /usr/lib/one/ruby/cli
%dir /usr/lib/one/ruby/cli/one_helper
/usr/lib/one/ruby/cli/one_helper/oneacct_helper.rb
/usr/lib/one/ruby/cli/one_helper/oneacl_helper.rb
/usr/lib/one/ruby/cli/one_helper/onecluster_helper.rb
/usr/lib/one/ruby/cli/one_helper/onedatastore_helper.rb
/usr/lib/one/ruby/cli/one_helper/oneflow_helper.rb
/usr/lib/one/ruby/cli/one_helper/oneflowtemplate_helper.rb
/usr/lib/one/ruby/cli/one_helper/onegroup_helper.rb
/usr/lib/one/ruby/cli/one_helper/onehook_helper.rb
/usr/lib/one/ruby/cli/one_helper/onehost_helper.rb
/usr/lib/one/ruby/cli/one_helper/oneimage_helper.rb
/usr/lib/one/ruby/cli/one_helper/onemarketapp_helper.rb
/usr/lib/one/ruby/cli/one_helper/onemarket_helper.rb
/usr/lib/one/ruby/cli/one_helper/onequota_helper.rb
/usr/lib/one/ruby/cli/one_helper/onesecgroup_helper.rb
/usr/lib/one/ruby/cli/one_helper/onetemplate_helper.rb
/usr/lib/one/ruby/cli/one_helper/oneuser_helper.rb
/usr/lib/one/ruby/cli/one_helper/onevcenter_helper.rb
/usr/lib/one/ruby/cli/one_helper/onevdc_helper.rb
/usr/lib/one/ruby/cli/one_helper/onevmgroup_helper.rb
/usr/lib/one/ruby/cli/one_helper/onevm_helper.rb
/usr/lib/one/ruby/cli/one_helper/onevnet_helper.rb
/usr/lib/one/ruby/cli/one_helper/onevntemplate_helper.rb
/usr/lib/one/ruby/cli/one_helper/onevrouter_helper.rb
/usr/lib/one/ruby/cli/one_helper/onezone_helper.rb

/usr/lib/one/ruby/cli/cli_helper.rb
/usr/lib/one/ruby/cli/command_parser.rb
/usr/lib/one/ruby/cli/one_helper.rb

/usr/share/one/onetoken.sh

%{_sysconfdir}/bash_completion.d/opennebula

################################################################################
# Changelog
################################################################################

%changelog
* _DATE_ _CONTACT_ - _VERSION_-_PKG_VERSION_
- Build for _VERSION_-_PKG_VERSION_ (Git revision %{gitversion}) %{edition}
