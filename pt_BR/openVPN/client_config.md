# Configuração de Clientes OpenVPN

> [!CAUTION]
> Essa documentação pré-supõe que há um servidor OpenVPN já configurado, se não for seu caso, utilize a documentação [Configuração do Servidor OpenVPN][doc-server-openvpn] para isso.

- [Configuração de Clientes OpenVPN](#configuração-de-clientes-openvpn)
  - [Instalação dos Pacotes Necessários](#instalação-dos-pacotes-necessários)
  - [Copiando Chaves e Certificados Necessários](#copiando-chaves-e-certificados-necessários)
  - [Configurando o Cliente](#configurando-o-cliente)
    - [Arquivo de Configuração](#arquivo-de-configuração)
    - [Ativação do Serviço](#ativação-do-serviço)
  - [Formas de Debuggar](#formas-de-debuggar)
    - [Journalctl](#journalctl)
    - [Verificando os Certificados e Chaves](#verificando-os-certificados-e-chaves)
    - [Configurações Incompatíveis](#configurações-incompatíveis)
  - [Referência](#referência)


> [!IMPORTANT]
> Nessa documentação estará sendo usado como base uma máquina virtual [Rocky 9.2][rocky], se estiver usando outro tipo de distribuição Linux, os comandos e diretórios podem variar, se for preciso, consulte a documentação da sua distribuição ou pesquise online.

## Instalação dos Pacotes Necessários

> [!WARNING]
> Para as etapas nessa documentação é preciso ter permissões de root ou estar logado como, certifique-se se ter esse acesso antes de continuar.

No [Rocky 9.3][rocky] será preciso primeiramente instalar o repositório do `epel-release`, se for apenas instalar os pacotes minimamente necessparios, consulte a documentação do [epel limitado][epel-limitado] para não permitir outros pacotes.

Para instalar o repositório, execute o seguinte comando:

```bash
sudo dnf install epel-release
```

Após isso, instale os pacotes do OpenVPN com o seguinte comando:

```bash
sudo dnf install openvpn
```

## Copiando Chaves e Certificados Necessários

Para configurarmos o cliente, precisamos trazer as chaves e certificados do servidor e do cliente já configurados para podermos nos autenticar como um cliente.

Nesse caso, será necessário trazer os seguinte arquivos:

| Arquivo         | Utilidade                              |
| --------------- | -------------------------------------- |
| ca.crt          | certificado de autorização do servidor |
| ta.key          | chave HMAC                             |
| pedro.crt | certificado do cliente                 |
| pedro.key | chave privada do cliente               |

Para trazer os arquivos do servidor utilize o seguinte comando:

```bash
# Cria uma pasta para guardar as chaves
mkdir /etc/openvpn/client/keys
# Copia todas as chaves e certificados da pasta do cliente 
scp root@192.168.15.68:/etc/openvpn/client/pedro/* /etc/openvpn/client/keys/ # Mude para o IP do servidor OpenVPN!!
# Copia a chave HMAC
scp root@192.168.15.68:/etc/openvpn/server/ta.key /etc/openvpn/client/keys/ # Mude para o IP do servidor OpenVPN!!
```

Após isso, seu diretório `/etc/openvpn` deve-se parecer com o abaixo:

```
└── keys
    ├── ca.crt
    ├── pedro.crt
    ├── pedro.key
    └── ta.key
```

## Configurando o Cliente

### Arquivo de Configuração
***

Junto com o pacote do `openvpn`, há alguns arquivos de documentação, iremos copiar o arquivo de exemplo dele para nosso diretório do OpenVPN com o seguinte comando:

```bash
cp /usr/share/doc/openvpn/sample/sample-config-files/client.conf /etc/openvpn/client/
```

Para deixar apenas mais explícito, vamos renomear esse arquivo com o nome do cliente que estamos configurando com o comando abaixo:

```bash
# Esteja no diretóro /etc/openvpn/client para executar esse comando
mv client.conf pedro.conf 
```

Após isso, modifique o arquivo como for necessário para seu caso.

Abaixo está como foi configurado (sem os comentários) nosso arquivo de configuração `/etc/openvpn/client/pedro.conf`:

> [!TIP]
> Antes de Modificar o arquivo, salve uma cópia dele como backup usando o comando `cp pedro.conf pedro.conf.old`, lembre-se de estar no diretório `/etc/openvpn/client/` ao executar esse comando.


```bash
client
tls-client
pull
dev tun
proto udp4
remote 192.168.15.68 1194 # Troque pelo IP do servidor!!!
resolv-retry infinite
nobind
#user nobody
#group nogroup
persist-key
persist-tun
key-direction 1
remote-cert-tls server
auth-nocache
comp-lzo
verb 3
auth SHA512
tls-auth keys/ta.key 1
ca keys/ca.crt
cert keys/pedro.crt
key keys/pedro.key
```

### Ativação do Serviço
***

Para acionar o serviço do cliente utilize o comando abaixo:

```bash
sudo systemctl enable --now openvpn-client@pedro
```

Se tudo ocorreu corretamente, ao executar o comando `ip a`, você deverá encontrar um IP da rede interna de VPN como o seguinte:

```
tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 100
    link/none 
    inet 10.8.0.2/24 brd 10.8.0.255 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::ca17:65bf:877f:53a7/64 scope link stable-privacy 
       valid_lft forever preferred_lft forever

```

## Formas de Debuggar

Se ao iniciar o serviço, tudo não ocorreu conforme o esperado, há algumas formas de "debuggar" o problema.


### Journalctl
***

Uma forma é usando o `journalctl`, ele tem os logs de tudo do serviço, com o comando abaixo:

```bash
sudo journalctl -xeu openvpn-client@pedro
```

Também é possível que as configurações do servidor e do cliente não estejam compatíveis. Se for esse o caso há algumas formas de verificar seu caso.

### Verificando os Certificados e Chaves
***

É possível de os certificados e chaves estarem diferentes. Para verificar isso, utilize o comando `md5sum`, ele retornará uma código baseados nos dados do arquivo, compare os arquivos do cliente e do servidor, se um caractere for diferente, haverá uma drástica diferença no retorno.

Abaixo está um exemplo, o retorno deve ser igual em ambos:

```bash
# Cliente:
md5sum client/keys/ta.key
ec37f30a75d8b0478851d22ff914d87f client/keys/ta.key  # Retorno

# Servidor:
md5sum server/ta.key 
ec37f30a75d8b0478851d22ff914d87f  server/ta.key # Retorno
```

### Configurações Incompatíveis
***

Também é possível que as configurações do cliente e do servidor sejem incompatíveis.

Se por exemplo o servidor pedir alguma senha adicional não esperada, é possível que o servidor senha sido configurado incorretamente, se for preciso, consulte a [documentação de configuração do servidor OpenVPN][doc-server-openvpn].

## Referência

Essa documentação foi criada utilizando como base um tutorial de instalação de cliente do OpenVPN do Rocky8, houve apenas um esforço de testes, validações e traduções para o [Rocky9.3][rocky]. Abaixo está o link para esse tutorial:

- [Install and Configure OpenVPN Client on Rocky Linux 8][ref-openvpn-8]

[doc-server-openvpn]:/docs/openVPN/server_config.md
<!--- Links de documentação e referências  --->
[rocky]:https://docs.rockylinux.org/release_notes/9_2/
[ref-openvpn-8]:https://kifarunix.com/install-and-configure-openvpn-client-on-rocky-linux-8/
[epel-limitado]:/docs/receitas/epel-limitado-prometheus.md
