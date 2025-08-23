
# IOT  
## Storage / Stockage

🇫🇷 **Pour éviter les problèmes de stockage sur les machines de l'école**, il faut modifier les emplacements de stockage par défaut de **Vagrant** et **VirtualBox**.  
🇬🇧 **To avoid storage issues on school machines**, you should change the default storage paths for **Vagrant** and **VirtualBox**.

---

### VAGRANT_HOME

🇫🇷 Définit où Vagrant enregistre ses données :  
🇬🇧 Defines where Vagrant stores its data:

- fichiers de box / box files  
- métadonnées de box / box metadata  
- fichiers de log / log files  
- données temporaires (comme l'extraction de box) / temporary data (like box extraction)  
- plugins  

🔧 Modifier via une variable d’environnement / Set using an environment variable:

```bash
export VAGRANT_HOME=/tmp
```

---

### VBOX_USER_HOME

🇫🇷 Définit où VirtualBox enregistre ses fichiers par défaut :  
🇬🇧 Defines where VirtualBox stores its default data:

- dossier par défaut des VM (.vbox, .vmdk) / default VM folder (where .vbox and .vmdk files are stored)  
- fichiers de configuration / configuration files  
- logs  

🔧 Modifier via une variable d’environnement / Set using an environment variable:

```bash
export VBOX_USER_HOME=/tmp
```

---

### Changer le dossier par défaut des machines VirtualBox  
🇫🇷 Définir où les nouvelles VM seront créées (config, disques, snapshots, etc.)  
🇬🇧 Set the folder where new VirtualBox VMs will be created (config, disks, snapshots, etc.)

```bash
VBoxManage setproperty machinefolder /tmp/vbox
```

---

## Vagrantfile

---

### Box

🇫🇷 Les *boxes* dans Vagrant sont des images pré-packagées servant de base pour créer de nouveaux environnements.  
🇬🇧 Boxes in Vagrant are pre-packaged images used to build new environments.

📦 Exemple avec Debian :  
```ruby
config.vm.box = "debian/bookworm64"
```

---

### Machines

🇫🇷 Pour définir une machine virtuelle :  
🇬🇧 To define a virtual machine:

```ruby
config.vm.define "Name" do |node|
  # contenu / content
end
```

🇫🇷 À l’intérieur, on peut définir les caractéristiques de la machine : réseau, disques, nom, SSH, etc.  
🇬🇧 Inside, you can define VM characteristics: network, disks, name, SSH, etc.

🛠 Exemple :  
```ruby
node.vm.hostname = "tcosseS"
node.vm.network "private_network", ip: "192.168.56.110"
node.vm.disk :disk, size: "10GB", primary: true
node.ssh.insert_key = true
```

---

### Provider Settings / Paramètres du fournisseur

🇫🇷 `node.vm.provider` est utilisé pour personnaliser les paramètres de la machine virtuelle selon le fournisseur (VirtualBox, Docker, etc.)  
🇬🇧 `node.vm.provider` is used to customize VM settings for the selected provider (VirtualBox, Docker, etc.)

❗ Le nom du fournisseur doit être correct (ex : `"virtualbox"`, `"vmware_desktop"`, `"docker"`)  
❗ Provider name must be correct (e.g., `"virtualbox"`, `"vmware_desktop"`, `"docker"`)

🛠 Exemple :  
```ruby
node.vm.provider "virtualbox" do |vb|
  vb.name = "tcosse-server"
  vb.memory = 512
  vb.cpus = 1
end
```

💡 On peut définir plusieurs machines dans un même Vagrantfile.  
💡 You can define multiple machines in the same Vagrantfile.

---

## Commandes pratiques / Useful Commands

🚀 **Lancer la VM** *(remonte l’arborescence jusqu’au premier `Vagrantfile` trouvé)*  
**Launch the VM** (searches upward for the first `Vagrantfile`):

if needed, enable KVM :

```bash
	lsmod | grep kvm

	# Unload KVM modules
	sudo modprobe -r kvm_intel   # For Intel CPUs
	sudo modprobe -r kvm_amd     # For AMD CPUs  
	sudo modprobe -r kvm
```

```bash
vagrant up
```

🗑️ **Supprimer une box** / **Remove a box**  
```bash
vagrant box remove debian/bookworm64
```

🛑 **Détruire une VM Vagrant** / **Destroy the VM**  
```bash
vagrant destroy -f
```

🔐 **Connexion SSH à une machine définie** / **SSH into a named VM**  
```bash
vagrant ssh NomMachine
```

```bash
sudo journalctl -u k3s-agent -f
```
