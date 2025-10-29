# Configurando Bridge para Virtualização

- [Configurando Bridge para Virtualização](#configurando-bridge-para-virtualização)
  - [Criando Bredge](#criando-bredge)
    - [Criando bridge](#criando-bridge)
    - [Criando bridge-slave](#criando-bridge-slave)
    - [Desativar conexão automática da bridge](#desativar-conexão-automática-da-bridge)
    - [Ligando bridge-slave](#ligando-bridge-slave)
  - [Validação e mais](#validação-e-mais)
  - [Referência](#referência)

> [!NOTE]
> Nessa documentação setá usando de base o [Fedora 40][fedora40], se algo estiver fora da sua distribuição, verifique os pacotes faltantes ou como é executado para seu caso.

## Criando Bredge

> [!IMPORTANT]
> Para executar alguns dos comandos abaixo será necessário permissão de `sudo` (superusuário).

### Criando bridge
***

Primeiramene, vamos verificar as redes que está conectado. Para isso execute o commando abaixo:

```shell
nmcli connection show --active
```

A saída do comando deverá aparecer algo como o seguinte 

```text
NAME                UUID                    TYPE      DEVICE  
Wired connection 1  <dado do UUID da rede>  ethernet  enp43s0 
Wifix               <dado do UUID da rede>  wifi      wlp42s0 
lo                  <dado do UUID da rede>  loopback  lo     
```

Na maioria das placa de redes de um computador comum, só se pode conectar uma bridge através de uma conecção via cabo. No caso do exemplo acima, será a conexão `Wired connection 1` com o device `enp43s0` (anote o device da conexão, pois será usado posteriormente).

Agora iremos criar uma bridge com o device `br0`:

```shell
sudo nmcli connection add type bridge ifname br0
```

### Criando bridge-slave
***

Após, temos que criar um `bridge-slave`, ele tem o papel de conectar a bridge com a porta de rede. Para isso, execute o seguinte comando utilizando o device da sua porta de rede cabeada:

```shell
# Lembre-se de trocar o enp43s0 para o seu caso
sudo nmcli connection add type bridge-slave ifname enp43s0 master br0
```

### Desativar conexão automática da bridge
***

Se não desativarmos a conexão automática da bridge, todo `boot` demorará muito para ser realizado, logo que ele esperará o início da bridge para terminar de bootar.

Para desativar a conexão automática da `bridge-slave` e da bridge, execute o seguinte comando:

> [!TIP]
> Para verificar os nomes das redes novamente execute o comando abaixo:
> ```bash
> sudo nmcli connection show
> ```

```shell
# Lembres-se de colocar o nome correto das conexões
sudo nmcli connection modify bridge-slave-enp43s0 autoconnect no
sudo nmcli connection modify bridge-br0 autoconnect no
```

### Ligando bridge-slave
***

Depois de criada, devemos trocar as conexões, logo que a porta de rede apenas aceita uma conexão por vez. Para isso, execute os comandos abaixo para desconectar sua conexão cabeada e conectar nela o `bridge-slave` previamente criado:

```bash
sudo nmcli connection down "Wired connection 1" # Derruba sua conexão cabeada
sudo nmcli connection up bridge-slave-enp43s0   # Sobe o bridge-slave na porta de rede
```

> [!WARNING]
> Se desativou a conexão automática da bridge, você terá que ativar a bridge e o `bridge-slave` sobre que reiniciar a máquina quando for utilizar suas máquinas virtuais


## Validação e mais

Após todas as etapas acima, ao executar o comando `nmcli connection show --active`, você deverá ver algo como baixo:

```
NAME                         UUID            TYPE      DEVICE  
bridge-slave-enp43s0         <UUID da rede>  ethernet  enp43s0 
bridge-br0                   <UUID da rede>  bridge    br0     
lo                           <UUID da rede>  loopback  lo      
```

Após isso, siga a documentação de configuração da rede no libvirt abaixo:

- [Configuração da Rede do Libvirt](/docs/virtualização/config_net_virt.md)

## Referência

- [Managing virtual machines with libvirt](https://doc.opensuse.org/documentation/leap/virtualization/html/book-virtualization/cha-libvirt-host.html#libvirt-networks-bridged-add-nm)
- [Virtualization – Getting Started](https://docs.fedoraproject.org/en-US/quick-docs/virtualization-getting-started/)

<!--- Links de documentação e referências  --->
[fedora40]:https://docs.fedoraproject.org/en-US/releases/f40/