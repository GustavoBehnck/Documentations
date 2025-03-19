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
    - [Registering a SSH key](#registering-a-ssh-key)
    - [Configuring the `~/.ssh/config` file](#configuring-the-sshconfig-file)
    - [Execute a single command using the key.](#execute-a-single-command-using-the-key)

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

### Registering a SSH key
***
To use the authentication keys with `ssh`, the public key must be registered in the `~/.ssh/authorized_keys` file of the machine you want to access. To facilitate this process, you can use the `ssh-copy-id` command. For this, you will need to provide the username, IP address, and the path to the private key file, as shown in the example below:

```bash
ssh-copy-id -i key.pub user@192.160.0.164
```

> [!IMPORTANT]
> Make sure to use the public key in the command above; the private key should not be shared with any other machine.

After confirming with the user's password, your key should be added to the `~/.ssh/authorized_keys` file.

### Configuring the `~/.ssh/config` file
***
With the public key already inside the `authorized_keys` file of the desired machine, you need to configure **your** `~/.ssh/config` file.

> [!WARNING]
> This file is not created by default in the system, if needed, run the command `touch ~/.ssh/config` to create it.

To do it, add the following template to the file, customizing it according to your situation:

```bash
Host test_machine            
	HostName 192.160.0.164
	User user
	IdentityFile ~/.ssh/private_key
```

> [!NOTE]
> - test_machine = Desired name to use in SSH
> - 192.160.0.164 = IP of the machine that you want to connect
> - user = Username to connect to
> - ~/.ssh/chave = File path of the private key in your system

After adding the template with the correct information, you should now be able to SSH using the specified name, as shown in the example below:

```bash
ssh test_machine # Use the name you configure in the ~/.ssh/config file
```

### Execute a single command using the key.
***
It is also possible to use a single command. To do this, simply place the desired command at the end of the previously introduced command, as in the following example:

```bash
ssh test_machine systemctl status grafana-server
```


<!--- Links de documentação e referências  --->
[ssh]:https://pt.wikipedia.org/wiki/Secure_Shell
[rocky]:https://docs.rockylinux.org/release_notes/9_3/
