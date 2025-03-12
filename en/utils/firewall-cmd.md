# `firewall-cmd` Usage Documentation

> [!WARNING]
> To execute the `firewall-cmd` commands, you need to have root permissions or be logged in as one.

- [`firewall-cmd` Usage Documentation](#firewall-cmd-usage-documentation)
  - [Description](#description)
  - [Listing Current Configurations](#listing-current-configurations)
  - [Services](#services)
    - [Removing Services](#removing-services)
    - [List Available Services in the System](#list-available-services-in-the-system)
    - [Adding a Service Open to your Firewall](#adding-a-service-open-to-your-firewall)
    - [Creating a Custom Service](#creating-a-custom-service)
  - [Ports](#ports)
    - [Adição de Portas](#adição-de-portas)
    - [Remoção de Portas](#remoção-de-portas)
  - [Zonas](#zonas)
    - [Descrição](#descrição)
    - [Criação de zonas](#criação-de-zonas)
    - [Execução de comandos em uma zona](#execução-de-comandos-em-uma-zona)
    - [Ativação de zonas](#ativação-de-zonas)
      - [Adição de uma `inteface`](#adição-de-uma-inteface)
      - [Adição de um `source`](#adição-de-um-source)
    - [Remoção de zonas](#remoção-de-zonas)

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

### Adding a Service Open to your Firewall
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

### Adição de Portas
***
Não apenas os arquivos de serviços podem liberar portas no firewall, também é possível fazer isso diretamente pelo `firewall-cmd`.

Para adicionar uma porta ou mais, utilize um dos conjuntos de exemplo abaixo:

```bash
sudo firewall-cmd --add-port={3001/tcp,9090/udp} --permanent  #Coloque a porta e o protocolo de cada um (porta/protocolo)
sudo firewall-cmd --reload
```

```bash
sudo firewall-cmd --add-port=3001/tcp #Coloque a porta e o protocolo
sudo firewall-cmd --add-port=9090/udp #Coloque a porta e o protocolo
sudo firewall-cmd --runtime-to-permanent #Salva as configurações aplicadas permanentemente
sudo firewall-cmd --reload
```

### Remoção de Portas

Para adicionar uma porta ou mais, utilize um dos conjuntos de exemplo abaixo:

```bash
sudo firewall-cmd --remove-port={3001/tcp,9090/udp} --permanent  #Coloque a porta e o protocolo de cada um (porta/protocolo)
sudo firewall-cmd --reload
```

```bash
sudo firewall-cmd --remove-port=3001/tcp #Coloque a porta e o protocolo
sudo firewall-cmd --remove-port=9090/udp #Coloque a porta e o protocolo
sudo firewall-cmd --runtime-to-permanent #Salva as configurações aplicadas permanentemente
sudo firewall-cmd --reload
```


## Zonas

### Descrição
***
No `firewall-cmd` já existe por padrão diversas zonas, elas são usadas para atribuir diferentes configurações de permissões de firewall para ocasiões específicas. Por exemplo, a zona `trusted`, por padrão, é aplicada a todos de sua rede, ou seja, se estiver em uma rede `/15`, todos as máquinas `/15` da rede estarão suscetíveis a essa zona.

Para listar todas as zonas atuais use o comando abaixo:

```bash
sudo firewall-cmd --get-zones
```

Porém, nem todas as zonas existentes estão ativas, para listar as zonas ativas utilize o comando abaixo:

```bash
sudo firewall-cmd --get-active-zones
```

### Criação de zonas 
***
Para se criar uma zona, use o comando abaixo:

```bash
sudo firewall-cmd --permanent --new-zone=zone_teste #Troque pelo nome de sua escolha
sudo firewall-cmd --reload
```

### Execução de comandos em uma zona
***
É possível especificar qual zona você deseja utilizar um comando do `firewall-cmd`.

Para isso utilize a seguinte sintaxe abaixo:

```bash
sudo firewall-cmd --zone=<nome da zona> <comando>
```

Como por exemplo, para listar todas as configurações de uma zona, utilize o seguinte comando

```bash
sudo firewall-cmd --zone=zone_teste --list-all
```

### Ativação de zonas 
***
> [!IMPORTANT]
> Se estiver ativando uma zona em outra máquina através de SSH, é passível de se configurá-la para o seu tipo de conexão sem o serviço de `ssh`, ou seja, você não poderá mais fazer conexões ssh para a máquina novamente.
> 
> Certifique-se de adicionar o serviço nas configurações dessa zona ou verificar se essas serão aplicadas para sua conexão.

Para se ativar uma zona, é preciso atribuir uma `interface` ou um `source` para ela. Se atribuir uma inteface por exemplo, as configurações de firewall serão aplicadas a qualquer conexão feita por essa interface.

#### Adição de uma `inteface`

Para atribuir uma inteface a uma zona, utilize o comando abaixo:

```bash
sudo firewall-cmd --permanent --zone=zone_teste --add-interface=enp3s0 #Verifique suas intefaces de rede e troque para seu caso
```

> [!TIP]
> Se não souber suas intefaces de rede, use o comando `nmcli device show | grep DEVICE` para lista-las:

#### Adição de um `source`

No caso do `source`, é possível apenas aplicar uma faixa de IP para aplicar apenas a ela, como no exemplo a seguir:

```bash
sudo firewall-cmd --permanent --zone=zone_teste --add-source=10.1.250.0/24 #Mude para faixa de IP que desejar
sudo firewall-cmd --reload
```

Além de uma faixa de IP, também é possível adicinar um IPv4 ou IPv6 em específico. Se desejar, poderá até colocar um único MacAdress.


### Remoção de zonas
***
Após criar uma zona personalizada, seu arquivo de configuração `.xml` deverá estar no caminho `/etc/firewalld/zones`

> [!NOTE]
> É necessário permissão de root para modificações nessa pasta
>  
> Além disso, o local pode mudar de discribuição para discribuição, portanto, verifique se não for o seu caso.

É possível listar as zonas criadas com o seguinte comando:

```bash
sudo ls /etc/firewalld/zones
```

> [!TIP]
> É recomandado fazer um backup da zona antes de deletá-la.
> Para isso execute o seguinte comando:
> ```bash
> cp /etc/firewalld/zones/zona_teste.xml /etc/firewalld/zones/zona_teste.xml.old
> #lembre-se de trocar pelo nome de sua zona
> ```
> Se já exister um `zona_teste.xml.old` pode deletá-la

Depois de verificar a zona que deseja deletar, utilize o seguinte comando para relizar a ação:

```bash
sudo rm /etc/firewalld/zones/zona_teste.xml #troque pelo nome de sua zona
```


<!--- Links de documentação e referências  --->
[rocky]:https://docs.rockylinux.org/release_notes/9_3/
