# Firewall nftables 

nftables é um subsistema do kernel Linux que fornece filtragem e classificação de pacotes de rede /datagramas/quadros, nftables substitui as partes legadas do iptables do Netfilter.

Para nosso caso, utilizamos o nftables para administrar permissões de firewall no alpine, por conta de de ser um gerenciador de firewall leve, é interessante para o propósito do alpine.

> [!WARNING]
> Para as etapas nessa documentação é preciso ter permissões de root ou estar logado como, certifique-se de ter esse acesso antes de continuar.

## Arquivo de conjunto de regras

O nftables é gerenciado a partir de arquivos de regras, é possível criar um aquivo `.nft` dentro da pasta `/etc/nftables.d` para fazer essa configuração, abaixo está um template simples de um arquivo `/etc/nftables.d/config.nft`:

```Perl
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow loopback interface
        iif "lo" accept

        # Accept already established/related connections
        ct state established,related accept

        # allow ssh,http,https
        tcp dport {ssh,http,https} accept

        # Optional: log dropped packets (for debugging)
        # log prefix "nftables: " flags all counter

        drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

## Aplicando alterações

Após ter seu arquivo já configurado, use o seguinte comando para aplicar seu novo conjunto de regras no nftables:

```bash
nft -f /etc/nftables.d/config.nft
```

## Verificando

Após isso utilize o seguinte comando para listar o conjunto de regras aplicados atualmente no nftables:

```bash
nft list ruleset
```

Também é interessante acessar uma porta que está em teoria bloqueada para confirmar que as regras estão sendo devidamentes aplicadas.

## Limpar regras

Se quiser limpar os conjuntos de regras atualmente aplicados, utilize o comando abaixo:

```bash
nft flush ruleset
```

Após o comando, não deve haver mais nenhuma regra aplicada

## Proteção a partir de uma subrede

É possível fazer uma proteção de uma porta apenas para uma subrede específica, no caso abaixo estamos protegendo a porta 8000/tcp para todos na rede 10.8.50.0 com a máscara de 255.255.255.0:

```bash
ip saddr 10.8.50.0/24 tcp dport 8000 accept
```
