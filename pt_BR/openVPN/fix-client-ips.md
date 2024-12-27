# Atrelar IPs Fixos para Clientes

> [!CAUTION]
> Essa documentação pré-supõe que há um servidor OpenVPN e um cliente já configurados, se não for seu caso, utilize a documentação [Configuração do Servidor OpenVPN][doc-server-openvpn] e [Configuração de Clientes OpenVPN][doc-client-openvpn] para isso.

- [Atrelar IPs Fixos para Clientes](#atrelar-ips-fixos-para-clientes)
  - [Configurando o Arquivo de Configuração](#configurando-o-arquivo-de-configuração)
  - [Criando Configuração por Cliente](#criando-configuração-por-cliente)
    - [Verifique o Nome Específico](#verifique-o-nome-específico)
    - [Configuração do IP](#configuração-do-ip)
  - [Aplicando configurações](#aplicando-configurações)
    - [Formas de Debbugar](#formas-de-debbugar)
  - [Referência](#referência)

> [!IMPORTANT]
> Nessa documentação estará sendo usado como base uma máquina virtual [Rocky 9.2][rocky], se estiver usando outro tipo de distribuição Linux, os comandos e diretórios podem variar, se for preciso, consulte a documentação da sua distribuição ou pesquise online.

## Configurando o Arquivo de Configuração

> [!WARNING]
> Para as etapas nessa documentação é preciso ter permissões de root ou estar logado como, certifique-se de ter esse acesso antes de continuar.

Primeiramente é necessário modificar o arquivo de configuração do servidor. Iremos adionar o diretório de configurações dos IPs estáticos que serão providos para cara cliente de acordo com o certificado

Para isso utilize o `nano` ou o `vim` para editar o arquivo `/etc/openvpn/server/server.conf`. Após isso, adicione `client-config-dir /etc/openvpn/ccd` ao arquivo.

Também é possível com o seguinte comando:

```bash
echo "client-config-dir /etc/openvpn/ccd" >> /etc/openvpn/server/server.conf
```

## Criando Configuração por Cliente

### Verifique o Nome Específico
***

Primeiramente, precisamos pegar o nome comum expecífico de cada cliente, para isso utlize o comando abaixo:

```bash
openssl x509 -subject -noout -in /etc/openvpn/client/pedro/pedro.crt
```

Sua resposta deve ser algo como isso:

```bash
subject=CN = pedro # Esse é o nome que deverá usar
```

### Configuração do IP
***

Se for sua primeira vez configurando um IP de um cliente, será necessário criar o diretório `/etc/openvpn/ccd`. Para isso execute o seguinte comando:

```bash
mkdir /etc/openvpn/ccd # Cria o diretório
sudo chown -R nobody:nobody /etc/openvpn/ccd # Define o dono do arquivo como o nobody para evitar o SElinux
sudo chmod -R 750 /etc/openvpn/ccd
```

Agora, com o diretório já pronto, é possível usar o comando abaixo para para configurar o IP do cliente em relação ao nome comum obtido no passo anterior:

```bash
# Troque pelo IP desejado (nesse exemplo 10.8.0.60) e o nome do nome comum (pedro)
echo "ifconfig-push 10.8.0.60 255.255.255.0" > /etc/openvpn/ccd/pedro
```

> [!NOTE]
> Lembre-se que a forma como você atribui os endereços IP estáticos depende da topologia configurada no seu servidor OpenVPN.
> 
> No cado da configuração da [documentação de servidor OpenVPN][doc-server-openvpn], a topologia foi configurado como subnet como no caso abaixo
> ```
> topology subnet
> ```

## Aplicando configurações

Depois de tudo for configurado corretamente, reinicie o serviço com o seguinte comando:

```bash
systemctl restart openvpn-server@server
```

Após isso, reinicie o serviço do OpenVPN do cliente e verifique se o IP foi atribuido corretamente.

### Formas de Debbugar
***

Se após tudo, o IP não foi atribuído corretamente, há algumas formas de debbugar.

É possível verificar os logs do OpenVPN com os dois comandos abaixo:

```bash
sudo tail -f /var/log/openvpn/openvpn-status.log
```

```bash
sudo tail -f /var/log/openvpn/openvpn.log
```

Outra forma é usando o `journalctl` com o comando abaixo:

```bash
sudo journalctl -xeu openvpn-server@server
```

## Referência

Essa documentação foi criada utilizando como base um tutorial de instalação do OpenVPN do Rocky8, houve apenas um esforço de testes, validações e traduções para o [Rocky9.3][rocky]. Abaixo está o link para esse tutorial:

- [Assign Static IP Addresses for OpenVPN Clients][ref-openvpn-8]

<!--- Links de documentação e referências  --->
[doc-server-openvpn]:/docs/openVPN/server_config.md
[doc-client-openvpn]:/docs/openVPN/client_config.md
[rocky]:https://docs.rockylinux.org/release_notes/9_2/
[ref-openvpn-8]:https://kifarunix.com/assign-static-ip-addresses-for-openvpn-clients/