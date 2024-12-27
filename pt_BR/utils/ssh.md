# Documentação de SSH

- [Documentação de SSH](#documentação-de-ssh)
  - [Utilização do SSH](#utilização-do-ssh)
    - [Descrição](#descrição)
    - [Pré-requisitos para utilizar o SSH](#pré-requisitos-para-utilizar-o-ssh)
    - [Utilização do comando `ssh`](#utilização-do-comando-ssh)
    - [Executar apenas um comando com SSH](#executar-apenas-um-comando-com-ssh)
  - [Registrando uma chave SSH](#registrando-uma-chave-ssh)
    - [Descrição](#descrição-1)
    - [Criando as chaves de autenticação](#criando-as-chaves-de-autenticação)
    - [Registrando a chave](#registrando-a-chave)
    - [Configurando o arquivo `~/.ssh/config`](#configurando-o-arquivo-sshconfig)
    - [Executar apenas um comando com a chave](#executar-apenas-um-comando-com-a-chave)


## Utilização do SSH

### Descrição

O protocolo [SSH][ssh] (Secure Shell) é um método para executar/acessar outras máquina através da rede.

Na sessão [Utilização do SSH](#utilização-do-ssh) iremos abordar o uso básico de como acessar outras máquinas.

### Pré-requisitos para utilizar o SSH

Primeiramente será necessária uma máquina externa ao seu sistema para utilizar o protocolo, ela pode ser tanto uma máquina virtual quanto uma física.

Já dentro da máquina, primeiramente verifique se o serviço [SSH][ssh] ou a porta `22` está permitido no firewall. Para isso, será necessário usar o comando `firewall-cmd`, se não souber como fazer isso, consulte a documentação do [firewall-cmd](firewall-cmd.md).

Agora com o acesso a máquina e o [SSH][ssh] permitido, será necessário anotar o usuário em que está logado, sua senha e o IP da máquina. É possível descobrir seu IP através do comando `ip a`.

### Utilização do comando `ssh`

Agora com o nome de usuário e o IP da máquina, execute o seguinte comando para realizar o SSH:

```bash
ssh <nome do usuário>@<IP da máquina>
# Exemplo:
# ssh root@192.160.0.164
```

Após executar o comando assima, é possível que aparece algo como a mensagem a seguir:

```txt
The authenticity of host '<IP da máquina> (<IP da máquina>)' can't be established.
ECDSA key fingerprint is SHA256:<>.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Confirme com `yes` ou com oque aparecer para você. Essa mensagem apenas aparece na primeira vês que executar o `SSH`, após isso, a máquina estará registrada no arquivo `~/.ssh/known_hosts`, não mais sendo necessário essa confirmação.

Após confirmar com a senha do usuário, já deve ser possível executar comandos na máquina.

### Executar apenas um comando com SSH

Também é possível utilizar o apenas um comando, para isso, apenas coloque o comando desejado no final do comando anteriormente introduzido, como no exemplo a seguir:

```bash
ssh user@192.160.0.164 systemctl status grafana-server
```

A partir do final do IP informado, será considerado o comando que deseja executar, no caso assim `systemctl status grafana-server`.

## Registrando uma chave SSH

### Descrição

A utilização do ssh com o método padrão é um processo um quanto demorado, logo que é necessário o usuário, a senha e o IP da máquina, porém, podemos usar uma chave de autenticação para facilitar nossa vida. Essa sessão tem como objetivo ensinar como fazer isso.

### Criando as chaves de autenticação

Primeiramente será necessário gerar as chaves pública e privada, isso é possível usando o comando abaixo:

```bash
ssh-keygen
```

Ao executá-lo, aparecerá a seguinte mensagem:

```txt
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa):
```

Se preferir, você poderá mudar o nome do arquivo onde será salvo as chaves, por padrão será no `~/.ssh/id_rsa.pub` e `~/.ssh/id_rsa`.

> [!TIP]
> Se escolher um específico, é recomendado comocá-lo na pasta `~/.ssh`, logo que ele será salvo no seu diretório atual

E após isso, aparecerá a opção de colocar uma senha de segurança nos arquivos da chave como no exemplo abaixo:

```txt
Enter passphrase (empty for no passphrase):
```

Se não quiser colocar uma senha, apenas pressione `Enter` nessa etapa e em sua confirmação.

> [!TIP]
> Recomanda-se não colocar um senha nas chaves por questão de praticidade, mas se for de seu interesse ter uma camada de segurança maior, é uma opção.

Após aparecerá o seguinte output na tela:

```text
SHA256:HIyEjEfDMs+WQeDlPpgbjNpuebxMr98ufOPR2H/EV90 root@localhost.localdomain
The key's randomart image is:
+---[RSA 3072]----+
|  .B=..          |
| .+o*o o         |
|  .*.o. o       o|
| o +=  . .      E|
|. =.o   S    .  .|
|.. o .   +    o .|
|. oo..  o o  . . |
| .ooo.o.o. .  .  |
| ...++o=+.  ..   |
+----[SHA256]-----+
```

Pronto, agora deverá ter dois arquivos, uma chave com final `.pub`, sendo ela a chave pública, e uma sem, sendo essa a chave privada.

### Registrando a chave

Para utilizar as chaves de autenticação no `ssh` é preciso que chave pública esteja registradas dentro do arquivo `~/.ssh/authorized_keys`, para isso é possível usar o comando `ssh-copy-id` para facilitar esse processo, para isso será necessário usar o nome de usuário, IP e o arquivo da chave privada, como no exemplo abaixo:

```bash
ssh-copy-id -i chave.pub user@192.160.0.164
```

> [!IMPORTANT]
> Certifique-se de utilizar a chave pública no comando acima, a privada não deve ser compartilhada para nenhuma outra máquina.

Depois de confirmar com a senha do usuário escolhido sua chave deverá estar dentro do arquivo `~/.ssh/authorized_keys`.

### Configurando o arquivo `~/.ssh/config`

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

Também é possível utilizar o apenas um comando, para isso, apenas coloque o comando desejado no final do comando anteriormente introduzido, como no exemplo a seguir:

```bash
ssh maquina_teste systemctl status grafana-server
```


<!--- Links de documentação e referências  --->
[ssh]:https://pt.wikipedia.org/wiki/Secure_Shell
[rocky]:https://docs.rockylinux.org/release_notes/9_3/
