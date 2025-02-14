# The Complete XML Developer - Virtual Machine

The following instructions will enable you to setup two things:

1. An [Apache Guacamole](https://guacamole.apache.org/) server that will provide a website for accessing remote machines through a Web Browser.

2. One or More Virtual Machines configured with all of the software required for the purpose of teaching "The Complete XML Developer" training course.


## Obtaining Servers

This can be setup either in [AWS EC2](https://aws.amazon.com/ec2/), or another Virtual Environment such as KVM running on a Linux Server.
The environment (which provided 1x Guacamole Server, and 8x "The Complete XML Developer"  Virtual Machines) and that was used for teaching "The Complete XML Developer" in London in February 2024 was Ubuntu 22.04 running on a bare-metal server leased by Evolved Binary from [Hetzner](https://www.hetzner.com/) in Germany, with the following configuration:
* Xeon E5-1650 v3 @ 3.50GHz (6 Cores / 12 Threads)
* 128 GB RAM
* 2x 480GB SSD in RAID 1

Below we detail two options for setting up Virtual Machines: 1. Hetzner bare-metal server, and 2. AWS EC2.

### 1. Setting up a new Linux KVM VM (optional)

If you have leased a server from someone like Hetzner with Ubuntu 22.04 installed and wish to set this all up using KVM to host your VMs, then on the server (KVM host) you should run the following commands (assuming an Evolved Binary Server in Hetzner):

```shell
git clone --single-branch --branch hetzner https://github.com/adamretter/soyoustart hetzner
cd ~/hetzner

sudo uvt-simplestreams-libvirt sync --source=http://cloud-images.ubuntu.com/minimal/releases arch=amd64 release=jammy

export HN=xmldev1 IP4=188.40.179.161 IP6=2a01:4f8:140:91f0::161
./create-uvt-kvm.sh --hostname $HN --release jammy --memory 16384 --disk 30 --cpu 4 --bridge virbr1 --ip $IP4 --ip6 $IP6 --gateway 6.4.100.114 --gateway6 2a01:4f8:140:91f0::2 --dns 185.12.64.1 --dns 185.12.64.2 --dns-search evolvedbinary.com --autostart
```

**NOTE**: The VM specific settings are:
* `--hostname` `xmldev1`
* `--ip` `188.40.179.161`
* `--ip6` `2a01:4f8:140:91f0::161`

**NOTE**: The network settings specific to the host are:
* `--bridge` `virbr1`
* `--gateway` `6.4.100.114`
* `--gateway6` `2a01:4f8:140:91f0::2`

**NOTE**: The network settings specific to the hosting provider are:
* `--dns 185.12.64.1`, `--dns 185.12.64.2`


### 2. Setting up a new AWS EC2 Instance (optional)

If you wish to set this up in AWS EC2, then for each Virtual Machine you need should setup a new EC2 instance with the following properties:

1. Name the instance 'xmldev1'. (change the `1` as needed for more machines).

2. Select the `Ubuntu Server 22.04 LTS (HVM), SSD Volume Type` AMI image, and the Architecture `arm64`.

3. Select `m6g.xlarge` instance type. (i.e.: 4vCPU, 16GB Memory, 1x237 NVMe SSD, $0.1776 / hour).

4. Select the `xmldev` keypair.

5. Select the `xmldev vm` Security Group.

6. Set the default Root Volume as an `EBS` `30 GiB` volume on `GP3` at `3000 IOPS` and `125 MiB throughput`.


## Install Guacamole Server

Apache Guacamole provides a web interface for accessing any virtual machine remotely. This is used so that students only need a web-browser. The student accesses Guacamole, and then Guacamole connects them to the remote virtual machine.

Guacamole should be run in its own virtual machine. To install Guacamole and configure it for 'The Complete XML Developer' run the following commands on a new VM:


```shell
git clone https://github.com/evolvedbinary/xml-developer-vm-setup.git
cd xml-developer-vm-setup
sudo ./install-puppet-agent.sh

cd guacamole

sudo FACTER_default_user_password=mypassword2 \
     /opt/puppetlabs/bin/puppet apply 01-base.pp
```

**NOTE:** you should set your own passwords appropriately above! The `default_user_password` is used for the Linux user that can access the machine, the username is `ubuntu`.

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So run:

```shell
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `xml-developer-vm-setup/guacamole` repo checkout:

```shell
cd xml-developer-vm-setup/guacamole

sudo FACTER_default_user_password=mypassword2 \
     FACTER_xmldev_default_user_password=mypassword \
     /opt/puppetlabs/bin/puppet apply .
```

**NOTE:** you should set your own passwords appropriately above!

* `default_user_password` this is the password to set for the default linux user on this machine (typically the user is named `ubuntu` on Ubuntu Cloud images).
* `xmlss_default_user_password` should be set to the password of the default user on the remote (cityEHR workstation) virtual machines that you are trying to access.

After installation Guacamole's Web Server should be accessible from: [http://localhost:8080](http://localhost:8080), but should be accessible (via an nginx reverse proxy) from: [https://localhost](https://localhost)


## Installing a Complete XML Developer Workstation

You can install one or more Complete XML Developer workstations, each should be configured within its own virtual (or physical) machine. We expect to start from a clean Ubuntu Server, or Ubuntu Cloud Image install. This has been tested with Ubuntu version 22.04 LTS (arm64).

### Complete XML Developer Software Environment

The following software will be configured:

* Desktop Environment
	* X.org
	* LXQt
	* Chromium
	* Firefox
	* Okular

* Java Development Environment
	* JDK 17
	* Apache Maven 3
	* IntelliJ IDEA CE
	* Eclipse IDE

* XML Environment
	* eXist-db 7.0.0-SNAPSHOT (build from source)
	* Oxygen XML Editor
	* Saxon HE 12.5

* Database Environment
	* IBM DB2 Community Edition 11.5.9
		* DB2 JDBC (level 4) Driver
	* IBM Data Studio 4.1.4.0
	* PostgreSQL
		* pgAdmin
		* PostgreSQL JDBC (level 4) Driver

* Visual Studio Code

* Miscellaneous Tools
	* Nullmailer
	* Zsh and OhMyZsh
	* Git
	* cURL
	* wget
	* Screen
	* tar, gzip, bzip2, zstd, zip (and unzip)
	* Python 3 and Pip 3


### Installing a Complete XML Developer Workstation

Each Complete XML Developer Workstation should be run in its own virtual machine. To install a workstation run the following commands on a new VM:

```shell
git clone https://github.com/evolvedbinary/xml-developer-vm-setup.git
cd xml-developer-vm-setup
sudo ./install-puppet-agent.sh

cd workstation

sudo /opt/puppetlabs/bin/puppet apply 00-locale.pp

sudo FACTER_default_user_password=mypassword \
     /opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/environments/production/modules:$(pwd)/modules \
	 01-base.pp
```

**NOTE:** you should set your own passwords appropriately above!

* `default_user_password` this is the password to set for the default linux user on this machine (typically the user is named `ubuntu` on Ubuntu Cloud images).

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So:

```shell
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `xml-developer-vm-setup/workstation` repo checkout:

```shell
cd xml-developer-vm-setup/workstation
sudo FACTER_default_user_password=mypassword \
     FACTER_existdb_db_admin_password=xmldev \
     FACTER_existdb_version=7.0.0-SNAPSHOT \
     FACTER_postgresql_db_postgres_password=postgres \
     /opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/environments/production/modules:$(pwd)/modules \
  .
```

**NOTE:** you should set your own passwords appropriately above!

* `default_user_password` this is the password to set for the default linux user (typically the user is named `ubuntu` on Ubuntu Cloud images). It needs to be the same as the password you used for this above.
* `existdb_db_admin_password` this is the password to set for the eXist-db `admin` user.
* `postgresql_db_postgres_password` - This is the password to set for the `postgres` database user in postgres.

We have to restart the system after the above as it installs a new desktop login manager.

```shell
sudo shutdown -r now
```

After installation you should be able to access this instance using either one of two mechanisms:

1. Directly, by using an RDP (Remote Desktop Protocol) client, e.g. Microsoft Remote Desktop. This approach usually gives the most responsive performance for the user.
	* Clients:
		* **Windows** - run `mstsc.exe`
		* **Mac** - Install and run [Microsoft Remote Desktop](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466?mt=12) from the Apple Store.
		* **Linux** - run `rdesktop` (Ubuntu install: `apt-get install -y rdesktop && rdesktop`)
	* Connection Settings:
		* **Host**: The IP address or FQDN of the remote machine (e.g. `xmldev1.evolvedbinary.com`)
		* **Username**: `ubuntu`
		* **Password**: *the password you set above for `default_user_password`*


2. Indirectly via the Guacamole website by visiting the website (e.g. [https://melon.evolvedbinary.com](https://melon.evolvedbinary.com)) in your web browser.
	* Login details:
		* **Username**: `xmldev1` (replace 1 with the number of the instance)
		* **Password**: *the password you set above for `xmldev_default_user_password`*
