```xml
<network>
  <name>bridged_libvirt</name>
  <uuid>128ceb48-d054-4a3e-9583-459dd6ed4827</uuid>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
```
# PASSOS UTILIZAÇÃO

```bash
# Instalação
sudo dnf in libvirt

sudo dnf in libvirt-daemon-kvm qemu-kvm

sudo dnf install @virtualization

# Não é necessário
sudo dnf group install --with-optional virtualization

sudo systemctl enable --now libvirtd
```

doc

```bash
cd /var/lib/libvirt/network

vim bridged_libvirt.xml

sudo virsh net-define --file bridged_libvirt.xml --validate

virsh net-list --all

virsh net-start --network bridged_libvirt

virsh net-autostart --network bridged_libvirt

virsh net-autostart --network default --disable

virsh net-destroy --network default
```