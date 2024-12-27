# Configuração do Servidor OpenVPN

- [Configuração do Servidor OpenVPN](#configuração-do-servidor-openvpn)
  - [Instalação dos Pacotes Necessários](#instalação-dos-pacotes-necessários)
  - [Criação das Chaves/Certificados do Servidor](#criação-das-chavescertificados-do-servidor)
    - [Setup Inicial](#setup-inicial)
    - [Inicialização da PKI](#inicialização-da-pki)
    - [Gerando Certificado e Chave de Autorização](#gerando-certificado-e-chave-de-autorização)
    - [Gerando chave Diffie-Hellman](#gerando-chave-diffie-hellman)
    - [Gerando Certificado e Chave do Servidor](#gerando-certificado-e-chave-do-servidor)
    - [Gerando a Chave de Autenticação de Mensagem (HMAC)](#gerando-a-chave-de-autenticação-de-mensagem-hmac)
    - [Gerando Certificado de Revogação](#gerando-certificado-de-revogação)
    - [Copiando os Certificados e Chaves](#copiando-os-certificados-e-chaves)
  - [Criação do Certificado e Chave de Clientes](#criação-do-certificado-e-chave-de-clientes)
    - [Gerando o Certificado e Chave](#gerando-o-certificado-e-chave)
    - [Copiando Arquivos](#copiando-arquivos)
  - [Configurando o OpenVPN](#configurando-o-openvpn)
    - [Arquivo server.conf](#arquivo-serverconf)
    - [Ajuste da Rota do OpenVPN](#ajuste-da-rota-do-openvpn)
    - [Configurando o Firewall](#configurando-o-firewall)
  - [Ativação do Serviço](#ativação-do-serviço)
    - [Formas de Debuggar](#formas-de-debuggar)
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

Além disso, será necessário gerar os certificados que serão usados nas configurações de autenticação do OpenVPN, em nosso caso, usaremos o `easy-rsa`, para instalá-lo, utilize o seguinte comando:

```vash
sudo dnf install easy-rsa
```

## Criação das Chaves/Certificados do Servidor

### Setup Inicial 
***
Primeiramente, vamos criar uma pasta `/etc/easy-rsa/` e copiar dentro dela todas as coisas que necessitaremos, para isso execute os seguintes comandos:

> [!NOTE]
> Essa parte de criação da pasta é totalmente opcional, apenas recomendado para facilitação do processo. Além disso, o resto da documentação terá como base que essa etapa foi realizada.

```bash
mkdir /etc/easy-rsa # Cria a pasta
cp -air /usr/share/easy-rsa/3/* /etc/easy-rsa/ # Copia todos os arquivos
cd /etc/easy-rsa/ # Entra na pasta recém criada
```

### Inicialização da PKI
***
Para inicializar a PKI utilize o seguinte comando:

> [!IMPORTANT]
> Certifique-se que esteja no diretório `/etc/easy-rsa`, para isso execute o comando `pwd` para retornar seu local atual.

```bash
. easyrsa init-pki
```

Após a execução, o seguinte deverá retornar:

```
Notice
------
'init-pki' complete; you may now create a CA or requests.

Your newly created PKI dir is:
* /etc/easy-rsa/pki

Using Easy-RSA configuration:
* /etc/easy-rsa/pki/vars

IMPORTANT:
  Easy-RSA 'vars' template file has been created in your new PKI.
  Edit this 'vars' file to customise the settings for your PKI.
  To use a global vars file, use global option --vars=<FILE>
```

Se tudo ocorreu corretamente, deverá existir a seguinte `tree` dentro do diretório `/etc/easy-rsa/`:

```
├── easyrsa
├── openssl-easyrsa.cnf
├── pki
│   ├── inline
│   ├── openssl-easyrsa.cnf
│   ├── private
│   ├── reqs
│   ├── vars
│   └── vars.example
└── x509-types
    ├── ca
    ├── client
    ├── code-signing
    ├── COMMON
    ├── email
    ├── kdc
    ├── server
    └── serverClient
```

### Gerando Certificado e Chave de Autorização
***
Agora vamos gerar o certificado e chave de autorização que serão usados para assinar os outros certificados, para isso execute o seguinte comando:

> [!IMPORTANT]
> Certifique-se que esteja no diretório `/etc/easy-rsa`, para isso execute o comando `pwd` para retornar seu local atual.

```bash
. easyrsa build-ca
```

o seguinte aparecerá para você:

```
Using Easy-RSA 'vars' configuration:
* /etc/easy-rsa/pki/vars

Using SSL:
* openssl OpenSSL 3.0.7 1 Nov 2022 (Library: OpenSSL 3.0.7 1 Nov 2022)

Enter New CA Key Passphrase: 
```

Logo em seguida será necessário fazer 3 coisas:

1. Colocar uma senha
2. Confirmá-la
3. Escolher um nome para o arquivo, nesse caso, apenas precione para confirmar, não é preciso escolher 
   <!-- Kifarunix-demo CA -->


Após isso, o seguinte texto deverá aparecer para você:

```
CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/easy-rsa/pki/ca.crt
```

### Gerando chave Diffie-Hellman
***

Agora geraremos uma chave [Diffie-Hellman][diffie-hellman], Diffie-Hellman é um método de criptografia para troca de chaves de maneira segura, ele é usado para o hadshake do TLS com clientes que se conectam.

Para gerar a chave execute o comando abaixo (esteja na pasta `/etc/easy-rsa/`):

> [!TIP]
> Esse comando pode demorar alguns minutos, não se preocupe com a demora


```bash
. easyrsa gen-dh
```

Após o término, o seguinte deve aperecer para você:

```
Using Easy-RSA 'vars' configuration:
* /etc/easy-rsa/pki/vars

Using SSL:
* openssl OpenSSL 3.0.7 1 Nov 2022 (Library: OpenSSL 3.0.7 1 Nov 2022)
Generating DH parameters, 2048 bit long safe prime
......+......................................+.......................................
+.............................+..................................+...........
DH parameters appear to be ok.

Notice
------

DH parameters of size 2048 created at:
* /etc/easy-rsa/pki/dh.pem
```

### Gerando Certificado e Chave do Servidor
***

Nessa etapa criaremos o certificado e a chave privada para o servidor do OpenVPN, para isso use o comando abaixo:

> [!IMPORTANT]
> Certifique-se que esteja no diretório `/etc/easy-rsa`, para isso execute o comando `pwd` para retornar seu local atual.

```bash
. easyrsa build-server-full server nopass
```

Durante a execução do comando, você terá que tomar duas ações, a primeira é confirmar a continuidade com `Confirm request details`, e em seguida confirmar a senha da senha `ca.key` configurado na etapa  de [geração do certificado e chave de autorização](#gerando-certificado-e-chave-de-autorização).

Após tudo ser executado corretamente, algo como o seguinte aparecerá para você:

```
Using Easy-RSA 'vars' configuration:
* /etc/easy-rsa/pki/vars

Using SSL:
* openssl OpenSSL 3.0.7 1 Nov 2022 (Library: OpenSSL 3.0.7 1 Nov 2022)
........+++++++++++++++++++++++++++
+++++++++++++++++++++++++++++++++++++*....+....+++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++*...+...............+.....+.+...+......+.....+.+..+...+...
.+...+................+..........+...+......+.....+.........+..........+..+...+......
+.......+..+.............+.........+++++++++++++++++++++...+.........+.....+.........+.+......++++++++++++++++++++++++
+++++++++++++++++++++
+++++++++++++++++++*..........+..++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.+............+..
-----

Notice
------
Private-Key and Public-Certificate-Request files created.
Your files are:
* req: /etc/easy-rsa/pki/reqs/server.req
* key: /etc/easy-rsa/pki/private/server.key 

You are about to sign the following certificate:
Request subject, to be signed as a server certificate 
for '825' days:

subject=
    commonName                = server

Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes

Using configuration from /etc/easy-rsa/pki/openssl-easyrsa.cnf
Enter pass phrase for /etc/easy-rsa/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Mar 22 18:31:38 2027 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

Notice
------
Certificate created at:
* /etc/easy-rsa/pki/issued/server.crt

Notice
------
Inline file created:
* /etc/easy-rsa/pki/inline/server.inline
```

### Gerando a Chave de Autenticação de Mensagem (HMAC)
***

HMAC é um tipo específico de código de autenticação de mensagem (MAC) que usa uma função hash criptográfica e uma chave criptográfica secreta; que pode ser usado para verificar simultaneamente a integridade dos dados e a autenticidade de uma mensagem. ([wikipedia](https://pt.wikipedia.org/wiki/HMAC))

Para gerar uma chave de autenticação pré-compartilhada TLS/SSL, que será usada para adicionar uma assinatura HMAC adicional a todos os pacotes do handshake SSL/TLS, a fim de evitar ataques DoS e inundação da porta UDP, execute o comando abaixo:

```
openvpn --genkey secret /etc/easy-rsa/pki/ta.key
```

> [!NOTE]
> O comando acima não há retorno de feedback

### Gerando Certificado de Revogação
***

Esse certificado serve para invalidar um certificado anteriormente assinado quando necessário. Para gerá-lo, execute o comando abaixo:

> [!IMPORTANT]
> Certifique-se que esteja no diretório `/etc/easy-rsa`, para isso execute o comando `pwd` para retornar seu local atual.

```bash
. easyrsa gen-crl
```

Após isso, você precisará inserir a senha anteriormente cadastrada no passo de [geração do certificado e chave de autorização](#gerando-certificado-e-chave-de-autorização).

Seu retorno deverá ser o seguinte:

```
Using Easy-RSA 'vars' configuration:
* /etc/easy-rsa/pki/vars

Using SSL:
* openssl OpenSSL 3.0.7 1 Nov 2022 (Library: OpenSSL 3.0.7 1 Nov 2022)
Using configuration from /etc/easy-rsa/pki/openssl-easyrsa.cnf
Enter pass phrase for /etc/easy-rsa/pki/private/ca.key:

Notice
------
An updated CRL has been created:
* /etc/easy-rsa/pki/crl.pem
```

### Copiando os Certificados e Chaves
***

Antes de continuar, certifique-se de que seu diretório `/etc/easy-rsa/` esteja como o abaixo:

```
├── easyrsa
├── openssl-easyrsa.cnf
├── pki
│   ├── ca.crt
│   ├── certs_by_serial
│   │   └── FC407E0B97C8418E696C3C5E91553.pem
│   ├── crl.pem
│   ├── dh.pem
│   ├── index.txt
│   ├── index.txt.attr
│   ├── index.txt.attr.old
│   ├── index.txt.old
│   ├── inline
│   │   └── server.inline
│   ├── issued
│   │   └── server.crt
│   ├── openssl-easyrsa.cnf
│   ├── private
│   │   ├── ca.key
│   │   └── server.key
│   ├── reqs
│   │   └── server.req
│   ├── revoked
│   │   ├── certs_by_serial
│   │   ├── private_by_serial
│   │   └── reqs_by_serial
│   ├── serial
│   ├── serial.old
│   ├── ta.key
│   ├── vars
│   └── vars.example
└── x509-types
    ├── ca
    ├── client
    ├── code-signing
    ├── COMMON
    ├── email
    ├── kdc
    ├── server
    └── serverClient
```

Agora iremos copiar todos os arquivos necessário para o diretório do servidor do OpenVPN, para isso execute o seguinte comando:

```bash
cp -rp /etc/easy-rsa/pki/{ca.crt,dh.pem,ta.key,crl.pem,issued,private} /etc/openvpn/server/
```

Após a execução do comando, o seu diretório `/etc/openvpn/server` deve ter o seguintes arquivos:

```
├── ca.crt
├── crl.pem
├── dh.pem
├── issued
│   └── server.crt
├── private
│   ├── ca.key
│   └── server.key
└── ta.key
```

## Criação do Certificado e Chave de Clientes

### Gerando o Certificado e Chave
***

Parar gerar o certificado e chave privada execute o comando abaixo:

> [!IMPORTANT]
> Certifique-se que esteja no diretório `/etc/easy-rsa`, para isso execute o comando `pwd` para retornar seu local atual.

```bash
. easyrsa build-client-full pedro nopass # Mude o com o nome do pedro que está configurando
```

Em nosso caso de teste estamos criando o cliente `pedro`.

Após executar o comando, terá que fazer algumas ações:

1. Confirmar com "yes" na parte de `Confirm request details`
2. Confirmar a senha do ca.key (gerada na etapa de [geração do certificado e chave de autorização](#gerando-certificado-e-chave-de-autorização))

Após tudo, algo como abaixo deverá ser seu resultado:

```
Using Easy-RSA 'vars' configuration:
* /etc/easy-rsa/pki/vars

Using SSL:
* openssl OpenSSL 3.0.7 1 Nov 2022 (Library: OpenSSL 3.0.7 1 Nov 2022)
.....+...+....+......+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.+...+.+.....+...+...+...+.+++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++*....+.....+...+............+....+.................+....+........
.+.......+...+........+.......+........+....+..+................+..................+..............+.+...............+.....+...
.............+.....+...+..........+...+..............+.+.....+...+..........+......+........+.............
+...+.........+..+...+.......+......+..+.+......+........+......+......+......+...+.......+..............+...+......+.++++++++++++++++++++++
....+..+....+...............+.....+.+...+..+...+......++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++++++++++*.+...............++++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++++++++*.....+....+..+......+....+...+...+........+.........+..........+..+....+...............+......+.
+++++++++++++++++++++++++++++++++++++++++++++
-----

Notice
------
Private-Key and Public-Certificate-Request files created.
Your files are:
* req: /etc/easy-rsa/pki/reqs/pedro.req
* key: /etc/easy-rsa/pki/private/pedro.key 

You are about to sign the following certificate:
Request subject, to be signed as a client certificate 
for '825' days:

subject=
    commonName                = pedro

Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes

Using configuration from /etc/easy-rsa/pki/openssl-easyrsa.cnf
Enter pass phrase for /etc/easy-rsa/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'pedro'
Certificate is to be certified until Mar 24 12:51:36 2027 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

Notice
------
Certificate created at:
* /etc/easy-rsa/pki/issued/pedro.crt

Notice
------
Inline file created:
* /etc/easy-rsa/pki/inline/pedro.inline

```

### Copiando Arquivos
***

Primeiramente, é necessário ter uma pasta com o nome de cada cliente, para isso execute o seguinte comando:

```bash
mkdir /etc/openvpn/client/pedro # Mude o com o nome do cliente que está configurando
```

Após criar a pasta do cliente, copie todos os arquivos com o seguinte comando:

```bash
cp -rp /etc/easy-rsa/pki/{ca.crt,issued/pedro.crt,private/pedro.key} /etc/openvpn/client/pedro # Mude o com o nome do cliente que está configurando
```

Com isso seu diretório `/etc/openvpn/client/` deverá ter o seguites arquivos (para cada cliente):

```
└── pedro 
    ├── ca.crt
    ├── pedro.crt
    └── pedro.key
```

## Configurando o OpenVPN

### Arquivo server.conf
***
Junto com o pacote do `openvpn`, há alguns arquivos de documentação, iremos copiar o arquivo de exemplo dele para nosso diretório do OpenVPN com o seguinte comando:

```bash
cp /usr/share/doc/openvpn/sample/sample-config-files/server.conf /etc/openvpn/server/
```

Após isso, modifique o arquivo como for necessário para seu caso.

Abaixo está como foi configurado (sem os comentários) nosso arquivo de configuração `/etc/openvpn/server/server.conf`:

> [!TIP]
> Antes de Modificar o arquivo, salve uma cópia dele como backup usando o comando `cp /etc/openvpn/server/server.conf /etc/openvpn/server/server.conf.old` 

```bash
port 1194
proto udp4
dev tun
ca ca.crt
cert issued/server.crt
key private/server.key  # This file should be kept secret
dh dh.pem
topology subnet
server 10.8.0.0 255.255.255.0
route 10.8.1.0 255.255.255.0
route 10.8.2.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
client-to-client
keepalive 10 120
tls-auth ta.key 0 # This file is secret
cipher AES-256-CBC
comp-lzo
user nobody
group nobody
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append  /var/log/openvpn/openvpn.log
verb 4
explicit-exit-notify 1
auth SHA512
# client-config-dir /etc/openvpn/ccd # Esse será usado na parte de fixação de IPs
```

Crie a pasta `/var/log/openvpn/`, pois o OpenVPN não cria crie automaticamente. Para isso, utilize os seguintes comandos:

```bash
sudo mkdir /var/log/openvpn
```

### Ajuste da Rota do OpenVPN
***

Para garantir que o tráfego do cliente seja roteado através do endereço IP do servidor (o que ajuda a mascarar o endereço IP do cliente), você precisa habilitar o encaminhamento de IP no servidor OpenVPN, Para isso execute o seguinte comando:

```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
```

Para aplicar a mudança sem reiniciar a máquina, execute o seguinte comando:

```
sysctl --system
```

### Configurando o Firewall
***

> [!IMPORTANT]
> Essa etapa usará o comando `firewall-cmd`, se tiver alguma dúvida sobre seu uso, consulte a [documentação do firewall-cmd](/docs/utils/firewall-cmd.md).

Permita que o porta `1194/udp` esteja liberada com o seguinte comando:

```bash
sudo firewall-cmd --add-port=1194/udp --permanent
```

Ative a opção de mascarar o endereço IP:

```bash
sudo firewall-cmd --add-masquerade --permanent
```

Encaminhe o tráfego recebido na sub-rede OpenVPN especificada, por exemplo, 10.8.0.0/24 no nosso caso, para uma interface através da qual os pacotes serão enviados.

Para encontrar a interface pela qual os pacotes estão sendo enviados, execute o comando abaixo:

```bash
ip route get 8.8.8.8
```

Após anotar o nome de sua inteface e a subrede, execute o seguinte comando ajustando-o para o seu caso:

```bash
sudo firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.0.0/24 -o enp1s0 -j MASQUERADE
```

Agora reinicie seu firewall-cmd

```bash
sudo firewall-cmd --reload
```

## Ativação do Serviço

Após todos os passos acima serem tomados, já deverá ser possível acionar o serviço do OpenVPN. Para isso, use o coamndo abaixo:

```bash
sudo systemctl enable --now openvpn-server@server
```

Se tudo ocorreu corretamente, ao executar o comando `ip a`, você deverá encontrar um IP da rede interna de VPN como o seguinte:

```
tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none 
    inet 10.8.0.1/24 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::3d1f:7a3b:4a19:1427/64 scope link stable-privacy 
       valid_lft forever preferred_lft forever
```

### Formas de Debuggar
***

Se ao iniciar o serviço, tudo não ocorreu conforme o esperado, há algumas formas de "debuggar" o problema.

Uma forma é usando o `journalctl` com o comando abaixo:

```bash
sudo journalctl -xeu openvpn-server@server.service
```

Também é possível vendo os logs do OpenVPN com os dois comandos abaixo:

```bash
sudo tail /var/log/openvpn/openvpn-status.log
```

```bash
sudo tail /var/log/openvpn/openvpn.log
```

## Referência

Essa documentação foi criada utilizando como base um tutorial de instalação do OpenVPN do Rocky8, houve apenas um esforço de testes, validações e traduções para o [Rocky9.3][rocky]. Abaixo está o link para esse tutorial:

- [Setup OpenVPN Server on Rocky Linux 8][ref-openvpn-8]

<!--- Links de documentação e referências  --->
[rocky]:https://docs.rockylinux.org/release_notes/9_2/
[ref-openvpn-8]:https://kifarunix.com/setup-openvpn-server-on-rocky-linux-8/
[epel-limitado]:/docs/receitas/epel-limitado-prometheus.md
[diffie-hellman]:https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange