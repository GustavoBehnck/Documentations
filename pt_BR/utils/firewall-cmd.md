# Documentação de Uso do `firewall-cmd`

> [!WARNING]
> Para executar os comando de `firewall-cmd` é preciso ter permissões de root ou estar logado como.

- [Documentação de Uso do `firewall-cmd`](#documentação-de-uso-do-firewall-cmd)
  - [Descrição](#descrição)
  - [Listagem das Configurações Atuais](#listagem-das-configurações-atuais)
  - [Serviços](#serviços)
    - [Remoção de Serviços](#remoção-de-serviços)
    - [Listar Serviços Disponíveis pelo Sistema](#listar-serviços-disponíveis-pelo-sistema)
    - [Adição de Serviços](#adição-de-serviços)
    - [Criação de um Serviço Customizado](#criação-de-um-serviço-customizado)
  - [Portas](#portas)
    - [Adição de Portas](#adição-de-portas)
    - [Remoção de Portas](#remoção-de-portas)
  - [Zonas](#zonas)
    - [Descrição](#descrição-1)
    - [Criação de zonas](#criação-de-zonas)
    - [Execução de comandos em uma zona](#execução-de-comandos-em-uma-zona)
    - [Ativação de zonas](#ativação-de-zonas)
      - [Adição de uma `inteface`](#adição-de-uma-inteface)
      - [Adição de um `source`](#adição-de-um-source)
    - [Remoção de zonas](#remoção-de-zonas)

## Descrição

O comando `firewall-cmd` é utilizado para manipular as configurações de firewall da sua máquina, como, por exemplo, habilitar portas ou serviços para dispositivos externos acessarem.

## Listagem das Configurações Atuais

Para verificar as configurações atuais do firewall, utilize os seguinte comando abaixo:

```bash
sudo firewall-cmd --list-all
```

No caso dessa documentação, usaremos de exemplo um servidor [Rocky 9.3][rocky] recém instalado, sendo assim, a saída esperada deve ser algo como o exemplo abaixo:

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
> No final de cada alteração que fizer no firewall, liste as configurações do `firewall-cmd` para verificar se tudo ocorreu como esperado.

## Serviços

### Remoção de Serviços
***
Primeiramente iremos retirar os serviços `cockpit` e `dhcpv6-client`, listados no tópico anterior, da lista de serviços permitidos no firewall.

Para removê-los permanentemente utilizando o `firewall-cmd`, é possível realizar de diversas formas, a seguir está dois exemplos de como executar essa tarefa:

```bash
sudo firewall-cmd --remove-service=cockpit --permanent #Remove o serviço cockpit
sudo firewall-cmd --remove-service=dhcpv6-client --permanent #Remove o serviço dhcpv6-client
sudo firewall-cmd --reload
```

```bash
sudo firewall-cmd --remove-service={cockpit,dhcpv6-client} #Remove ambos serviços
sudo firewall-cmd --runtime-to-permanent #Salva as configurações permanentemente
sudo firewall-cmd --reload
```

> [!NOTE]
> É sempre interessante executar o comando `firewall-cmd --reload` após qualquer alteração no firewall para garantir que as mudanças foram aplicadas

### Listar Serviços Disponíveis pelo Sistema
***
Em seu sistema há uma diretório com todos os arquivos de serviços para utilização do `firewall-cmd`. No caso do [Rocky 9.3][rocky], é possível listar os serviços utilizando o seguinte comando:

```bash
ls /usr/lib/firewalld/services
```

A saída deverá ser a lista de arquivos .xml disponíveis por padrão pelo [Rocky 9.3][rocky], sendo eles já sendo usáveis.

> [!IMPORTANT]
> Se estiver utilizando outra distribuição Linux é possível que o caminho do diretório seja diferente, nesse caso, consulte o caminho dele na documentação da distribuição ou pesquise dentro de seus diretórios.

### Adição de Serviços
***
Para adicionar um serviço ao firewall, primeiro verifique se ele existe como no passo anterior.

Iremos adicionar como exemplo o serviço `grafana.xml` ao nosso firewall, assim como no exemplo a seguir:

```bash
sudo firewall-cmd --add-service=grafana --permanent
sudo firewall-cmd --reload
```

### Criação de um Serviço Customizado
***
Para criar um serviço, não é recomendado criá-lo na mesma pasta dos outros serviços, logo que é interessante separar o que veio junto do sistema e o que é criado pelo usuário.

Portanto iremos criar nosso arquivo .xml de serviço no diretório `/etc/firewalld/services/`, como por exemplo `sudo vim /etc/firewalld/services/<NOME DO ARQUIVO>.xml`.

> [!IMPORTANT]
> Se estiver utilizando outra distribuição Linux é possível que o caminho do diretório seja diferente, nesse caso, consulte o caminho dele na documentação da distribuição ou pesquise dentro de seus diretórios.

Com o arquivo criado, siga o como exemplo o seguinte tamplate básico a seguir:

```xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>(Nome Enxuto do Serviço)</short>
  <description>(Descrição do Serviço)</description>
  <port protocol="(Protocolo do serviço - ex: tcp ou udp)" port="(Porta do Serviço - ex: 3000)"/>
</service>
```

Em seguida, para adicionar o serviço já criado, execute a seguinte linha de comandos:

```bash
sudo firewall-cmd --reload
sudo firewall-cmd --add-service=(Nome do Serviço Criado) --permanent #Não é necessário o .xml no nome do serviço
sudo firewall-cmd --reload
```

## Portas

### Adição de Portas

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
