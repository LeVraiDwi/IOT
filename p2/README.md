# K3s et Trois Applications Simples

## Vue d'ensemble du projet

Ce projet est un exercice utilisant K3s pour déployer trois applications web et effectuer le routage basé sur le nom d'hôte.

### Prérequis
- 1 machine virtuelle 
- K3s (mode serveur)
- Vagrant + VirtualBox

### Architecture
```
Client → 192.168.56.110 (K3s + Traefik)
                ↓
        ┌─────────────────┐
        │   Ingress       │
        │   (Traefik)     │
        └─────────────────┘
                ↓
┌─────────────┬─────────────┬─────────────┐
│   app1.com  │   app2.com  │   default   │
│   (app1)    │   (app2)    │   (app3)    │
│   1 replica │  3 replicas │   1 replica │
└─────────────┴─────────────┴─────────────┘
```

## Étapes de configuration

### 1. Démarrage de la machine virtuelle
```bash
# se déplacer dans le dossier p2
cd p2

# démarrer la box Vagrant
vagrant up

# se connecter à la VM via ssh
vagrant ssh tcosseS
```

### 2. Vérification de K3s
```bash
# confirmer l'état du nœud
kubectl get nodes -o wide

# vérifier les ressources du namespace kube-system
kubectl get all -n kube-system

# vérifier les ressources du namespace par défaut
kubectl get all
```

### 3. Déploiement des applications
```bash
# exécuter le script de déploiement + applique l'ingress et configure /etc/hosts
/vagrant/scripts/deploy.sh
```

Ce script exécute les opérations suivantes :
- Création des déploiements (app1, app2, app3)
- Création des services
- Configuration de l'Ingress
- Mise à jour du fichier /etc/hosts

## Procédure de test

### 1. Vérification de l'accès à chaque application
```bash
# accès à app1.com
curl -H "Host:app1.com" 192.168.56.110
curl -v app1.com

# accès à app2.com
curl -H "Host:app2.com" 192.168.56.110
curl -v app2.com

# accès à app3.com
curl -H "Host:app3.com" 192.168.56.110
curl -v app3.com

# accès par défaut (affiche app3)
curl 192.168.56.110

# access avec Host precise
curl -v --resolve app1.com:80:192.168.56.110 http://app1.com
curl -v --resolve app2.com:80:192.168.56.110 http://app2.com
curl -v --resolve app3.com:80:192.168.56.110 http://app3.com
```

### 2. Vérification dans le navigateur
Accéder dans le navigateur à :
- ~~http://app1.com~~ -> Please check with curl command
- ~~http://app2.com~~ -> Please check with curl command
- ~~http://app3.com~~ -> Please check with curl command
- http://192.168.56.110 -> **app3.com**

## Fichiers de configuration

### Fichiers principaux
- `Vagrantfile` - Configuration de la machine virtuelle
- `confs/deployment.yml` - Déploiements des 3 applications
- `confs/ingress.yml` - Configuration de l'Ingress Traefik
- `confs/app*/service.yml` - Configuration des services pour chaque application
- `confs/app*/index.html` - Fichiers HTML de chaque application
- `scripts/deploy.sh` - Script de déploiement

### Configuration des applications
- **app1**: 1 réplica
- **app2**: 3 réplicas (répartition de charge)
- **app3**: 1 réplica (par défaut)



## <<< Notes >>>

- app2 est configuré avec 3 réplicas et effectue une répartition de charge
- La redirection automatique vers HTTPS est désactivée
- L'accès par défaut (sans nom d'hôte) affiche app3 