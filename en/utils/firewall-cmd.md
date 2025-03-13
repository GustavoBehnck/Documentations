# `firewall-cmd` Usage Documentation

> [!WARNING]
> To execute the `firewall-cmd` commands, you need to have root permissions or be logged in as one.

- [`firewall-cmd` Usage Documentation](#firewall-cmd-usage-documentation)
  - [Description](#description)
  - [Listing Current Configurations](#listing-current-configurations)
  - [Services](#services)
    - [Removing Services](#removing-services)
    - [List Available Services in the System](#list-available-services-in-the-system)
    - [Adding a Service to your Firewall](#adding-a-service-to-your-firewall)
    - [Creating a Custom Service](#creating-a-custom-service)
  - [Ports](#ports)
    - [Adding a Port to your Firewall](#adding-a-port-to-your-firewall)
    - [Removing a Port from your Firewall](#removing-a-port-from-your-firewall)
  - [Zones](#zones)
    - [Description](#description-1)
    - [Creating Zones](#creating-zones)
    - [Executing Commands in a Zone](#executing-commands-in-a-zone)
    - [Activation of a Zone](#activation-of-a-zone)
      - [How to Add a Interface to a Zone](#how-to-add-a-interface-to-a-zone)
      - [How to Add a Source to a Zone](#how-to-add-a-source-to-a-zone)
    - [Deleting a Zone from `firewall-cmd`](#deleting-a-zone-from-firewall-cmd)

## Description

The `firewall-cmd` command is used to manage the firewall settings of your machine, such as enabling ports or services for external devices to access.

> [!IMPORTANT]
> This documentation will be based on a [Rocky 9.3][rocky] server. If you are using another type of Linux distribution, the commands and directories may vary. If necessary, consult your distribution's documentation or search online.

## Listing Current Configurations

To check the current firewall configurations, use the following command below:

```bash
sudo firewall-cmd --list-all
```

In this documentation, we will use a freshly installed [Rocky 9.3][rocky] server as an example; therefore, the expected output should be something like the example below:

```**bash**
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp3s0
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

> [!TIP]
> At the end of each change made to the firewall, list the `firewall-cmd` configurations to verify that everything went as expected.

## Services

### Removing Services
***
First, we will remove the `cockpit` and `dhcpv6-client` services, as listed in the previous section, from the list of allowed services in the firewall.

To remove them permanently using firewall-cmd, there are several ways to do so. Below are two examples of how to perform this task:

```bash
sudo firewall-cmd --remove-service=cockpit --permanent #Remove the cockpit service permanently
sudo firewall-cmd --remove-service=dhcpv6-client --permanent #Remove the dhcpv6-client service permanently
sudo firewall-cmd --reload
```

```bash
sudo firewall-cmd --remove-service={cockpit,dhcpv6-client} #Remove both services NOT permanently
sudo firewall-cmd --runtime-to-permanent #Save current changes permanently
sudo firewall-cmd --reload
```

> [!NOTE]
> It is always a good idea to run the command `firewall-cmd --reload` after making any changes to the firewall to ensure that the changes are applied correctly.

### List Available Services in the System
***
Em seu sistema há uma diretório com todos os arquivos de serviços para utilização do `firewall-cmd`. No caso do [Rocky 9.3][rocky], é possível listar os serviços utilizando o seguinte comando:

```bash
ls /usr/lib/firewalld/services
```

The output should be a list of `.xml` files available by default in [Rocky 9.3][rocky], which are already usable.

### Adding a Service to your Firewall
***
To add a service to the firewall, first check if it exists, as in the previous step.

We will add the `grafana.xml` service to our firewall as an example, as shown in the following example:

```bash
sudo firewall-cmd --add-service=grafana --permanent #Add the service permanently
sudo firewall-cmd --reload
```

### Creating a Custom Service
***
To create a service, it is not recommended to create it in the same folder as the default system services. It is preferable to separate what comes with the system from what is created by the user.

Therefore, we will create our service `.xml` file in the directory `/etc/firewalld/services/`. For example with the command `sudo vim /etc/firewalld/services/<FILENAME>.xml.`

With the file created, you can follow the basic template below:

```xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>(Brief Service Name)</short>
  <description>(Service Description)</description>
  <port protocol="(Service Protocol - as tcp/udp)" port="(Service Port - as 3000/5432)"/>
</service>
```

Next, to add the service you just created, execute the following command:

```bash
sudo firewall-cmd --reload
sudo firewall-cmd --add-service=(Service Name) --permanent #The file extention is not needed (.xml)
sudo firewall-cmd --reload
```

## Ports

### Adding a Port to your Firewall
***
Not only can service open ports in the firewall, but it is also possible to do it directly using `firewall-cmd`.

To add one or more ports, use one of the example sets below:

```bash
sudo firewall-cmd --add-port={3001/tcp,9090/udp} --permanent  #Change the port and protocol according to your needs.
sudo firewall-cmd --reload
```

```bash
sudo firewall-cmd --add-port=3001/tcp
sudo firewall-cmd --add-port=9090/udp
sudo firewall-cmd --runtime-to-permanent #Save current changes permanently
sudo firewall-cmd --reload
```

### Removing a Port from your Firewall

To remove one or more ports from your firewall, use one of the two examples below:

```bash
sudo firewall-cmd --remove-port={3001/tcp,9090/udp} --permanent  #Change the port and protocol according to your needs.
sudo firewall-cmd --reload
```

```bash
sudo firewall-cmd --remove-port=3001/tcp
sudo firewall-cmd --remove-port=9090/udp
sudo firewall-cmd --runtime-to-permanent #Save current changes permanently
sudo firewall-cmd --reload
```


## Zones

### Description
***
In `firewall-cmd`, there are several zones that exist by default. These zones are used to assign different firewall permission configurations for specific situations. For example, the `trusted` zone is applied by default to everyone on your local network, meaning that if you are on a `/24` network, all machines in the same `/24` subnet will fall under this zone.

To list all current zones, use the command below:

```bash
sudo firewall-cmd --get-zones
```

However, not all existing zones are active. To list the active zones, use the command below:

```bash
sudo firewall-cmd --get-active-zones
```

### Creating Zones 
***
To create a zone, use the following command:

```bash
sudo firewall-cmd --permanent --new-zone=test_zone #Change the name of the zone as you want
sudo firewall-cmd --reload
```

### Executing Commands in a Zone
***
It is possible to specify which zone you want to use a `firewall-cmd` command on.

To do this, use the following syntax below:

```bash
sudo firewall-cmd --zone=<zone name> <command (flags)>
```

For example, to list all configurations of a zone, use the following command:

```bash
sudo firewall-cmd --zone=test_zone --list-all
```

### Activation of a Zone
***
> [!WARNING]
> If you are activating a zone on another machine via SSH, it is possible to configure it for your type of connection without the `ssh` service, meaning you will not be able to establish SSH connections to the machine again.
> 
> "If this new zone applys to your connection, ensure that you add the `ssh` service before activating it.

To activate a zone, you need to assign an interface or a source to it. For example, if you assign an interface, the firewall configurations will be applied to any connection made through that interface.

#### How to Add a Interface to a Zone

To assign an interface to a zone, use the command below:

```bash
sudo firewall-cmd --permanent --zone=test_zone --add-interface=enp3s0 #Change the zone name and the interface in your system
```

> [!TIP]
> If you don't know the available inteface in your system, use the command below to list them:
> ```shell
> nmcli device show | grep -i DEVICE
> ```

#### How to Add a Source to a Zone

When adding a source to your zone, you can apply a subnet mask, or even specify a direct IP or MAC address.

Here a some examples:

```bash
sudo firewall-cmd --permanent --zone=test_zone --add-source=192.168.1.0/24 #A subnet mask
sudo firewall-cmd --reload
```
```bash
sudo firewall-cmd --permanent --zone=test_zone --add-source={192.168.1.150,0f:cc:47:c6:c4:5f} #A IP or MAC address
sudo firewall-cmd --reload
```

### Deleting a Zone from `firewall-cmd`
***
After creating a custom zone, its `.xml` configuration file should be located in the `/etc/firewalld/zones/`.

> [!NOTE]
> Remember that you need sudo permissions to access this directory.
>
> If you want to list the zones, log in as root and use the command below:
> ```bash
> ls /etc/firewalld/zones/
> ```

There are 2 ways to delete a zone, you can firt use the flag `--delete-zone=`, as the following:

```bash
sudo firewall-cmd --delete-zone=test_zone --permanent #Remember to change the name according to your zone
sudo firewall-cmd --reload
```

Or you can manually delete the zone file as shown below.

> [!TIP]
> It is recommended to back up the zone before deleting it.
> 
> To do this, execute the following command:
> ```bash
> cp /etc/firewalld/zones/test_zone.xml /etc/firewalld/zones/test_zone.xml.old
> #Change the zone name according to your situation.
> ```

```bash
sudo rm /etc/firewalld/zones/test_zone.xml #Change the zone name according to your situation.
```

<!--- Links de documentação e referências  --->
[rocky]:https://docs.rockylinux.org/release_notes/9_3/
