# SSH Use Documentaion

- [SSH Use Documentaion](#ssh-use-documentaion)
  - [SSH Utiization](#ssh-utiization)
    - [Description](#description)
    - [Prerequisites for Using SSH](#prerequisites-for-using-ssh)
    - [Utilization of `ssh` command](#utilization-of-ssh-command)
    - [Execute a single command with SSH.](#execute-a-single-command-with-ssh)
  - [Registering an SSH Key](#registering-an-ssh-key)
    - [Description](#description-1)
    - [Creating Authentication Keys](#creating-authentication-keys)
    - [Registrando a chave](#registrando-a-chave)
    - [Configurando o arquivo `~/.ssh/config`](#configurando-o-arquivo-sshconfig)
    - [Executar apenas um comando com a chave](#executar-apenas-um-comando-com-a-chave)

## SSH Utiization

### Description
***
The [SSH][ssh] (Secure Shell) protocol is a method for executing/accessing other machines over the network.

In the [SSH Utilization](#ssh-utiization) section, we will cover the basic usage of how to access other machines.

### Prerequisites for Using SSH
***
First, an external machine to your system will be required to use the protocol; it can be either a virtual machine or a physical one.

Once inside the machine, first check if the [SSH][ssh] service or port `22` is allowed in the firewall. To do this, you will need to use the `firewall-cmd` (or the `ufw` depending on OS) command. If you are unsure how to do this, consult the documentation for [firewall-cmd](firewall-cmd.md).

Now that you have access to the machine and [SSH][ssh] is allowed, you will need to note the user you are logged in as, your password, and the machine's IP address. You can find your IP address using the command `ip a`.

### Utilization of `ssh` command
***
Now, with the username and the IP address of the machine, execute the following command to establish the SSH connection:

```bash
ssh <username>@<IP address>
# Exemplo:
# ssh root@192.160.0.164
```

After executing the command above, you will be prompted with the following text:

```txt
The authenticity of host '<IP address> (<IP address>)' can't be established.
ECDSA key fingerprint is SHA256:<>.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Confirm with `yes` or whatever appears for you. This message only appears the first time you run `SSH`. After that, the machine will be registered in the `~/.ssh/known_hosts` file, and this confirmation will no longer be necessary.

To conclude, you will be prompted to enter the user password to log in. Once you enter it, you can execute any command you would use on your computer, but now remotely.

### Execute a single command with SSH.
***
It is also possible to use a single command. To do this, simply place the desired command at the end of the previously introduced command, as in the following example:

```bash
ssh user@192.160.0.164 systemctl status grafana-server
```

Starting from the end of the provided IP address, the command you wish to execute will be considered, in this case, `systemctl status grafana-server`.

## Registering an SSH Key

### Description
***
Using SSH with the standard method can be somewhat slow, as it requires the username, password, and IP address of the machine. However, we can use an authentication key to make our lives easier. This section aims to teach you how to do that.

### Creating Authentication Keys
***
First, you will need to generate the public and private keys. This can be done using the command below:

```bash
ssh-keygen
```

When you execute it, you will be prompted to change the file name/directory:

```txt
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa):
```

If you prefer, you can change the name of the file where the keys will be saved. By default, they will be located at `~/.ssh/id_rsa.pub` and `~/.ssh/id_rsa`.

> [!TIP]
> If you choose a specific one, it is recommended to place it in the `~/.ssh` folder, as it will be saved in your current directory.

After that, you will be prompted to set a security password for the key files, as shown in the example below:

```txt
Enter passphrase (empty for no passphrase):
```

If you do not want to set a password, simply press `Enter` at this stage and again for confirmation.

> [!TIP]
> It is recommended not to set a password on the keys for convenience; however, if you prefer an additional layer of security, it is an option.

A similar output will be displayed to you like below:

```text
SHA256:HIyEjEfDMs+WQelPpgbjNpuebxMr98ufOPR2H/EV90 root@localhost.localdomain
The key's randomart image is:
+---[RSA 3072]----+
|  .B=..          |
| .+o*o o         |
|  .*.o.         o|
| o +=  . .      E|
|. =.o   S    .  .|
|.. o .   +    o .|
|. oo..  o o  . . |
| .ooo.o.o. .  .  |
| ...++o=+.  ..   |
+----[SHA256]-----+
```

Now you should have two files: one key with the `.pub` extension, which is the public key, and one without an extension, which is the private key.

### Registrando a chave
***
Para utilizar as chaves de autenticação no `ssh` é preciso que chave pública esteja registradas dentro do arquivo `~/.ssh/authorized_keys`, para isso é possível usar o comando `ssh-copy-id` para facilitar esse processo, para isso será necessário usar o nome de usuário, IP e o arquivo da chave privada, como no exemplo abaixo:

```bash
ssh-copy-id -i chave.pub user@192.160.0.164
```

> [!IMPORTANT]
> Certifique-se de utilizar a chave pública no comando acima, a privada não deve ser compartilhada para nenhuma outra máquina.

Depois de confirmar com a senha do usuário escolhido sua chave deverá estar dentro do arquivo `~/.ssh/authorized_keys`.

### Configurando o arquivo `~/.ssh/config`
***
Com a chave pública já dentro do `authorized_keys` da máquina desejada. É preciso configurar o arquivo `~/.ssh/config`.

> [!WARNING]
> Esse arquivo não é criado por padrão no sistema, portanto execute o comando `touch .ssh/config` para criá-lo.

Para isso, adicione dentro dele o seguinte template customizando de acordo com a sua situação:

```
Host maquina_teste
	HostName 192.160.0.164
	User user
	IdentityFile ~/.ssh/chave
```

> [!NOTE]
> - maquina_teste = Nome desejado para usar no ssh
> - 192.160.0.164 = IP da máquina
> - user = Usuário da máquina
> - ~/.ssh/chave = Caminho da chave privada

Após adicionar o template com as informações corretas, já deve ser possível fazer ssh com o nome colocado, como no exemplo abaixo:

```bash
ssh maquina_teste # Coloque o nome que colocou no ~/.ssh/config
```

### Executar apenas um comando com a chave
***
Também é possível utilizar o apenas um comando, para isso, apenas coloque o comando desejado no final do comando anteriormente introduzido, como no exemplo a seguir:

```bash
ssh maquina_teste systemctl status grafana-server
```


<!--- Links de documentação e referências  --->
[ssh]:https://pt.wikipedia.org/wiki/Secure_Shell
[rocky]:https://docs.rockylinux.org/release_notes/9_3/
