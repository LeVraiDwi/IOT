#!/bin/bash

echo "Deploying yml file !"
kubectl apply -f /vagrant/confs/deployment.yml

echo "Deploying app1 service !"
kubectl apply -f /vagrant/confs/app1/service.yml

echo "Deploying app2 service !"
kubectl apply -f /vagrant/confs/app2/service.yml

echo "Deploying app3 service !"
kubectl apply -f /vagrant/confs/app3/service.yml

echo "Deploying ingress !"
kubectl apply -f /vagrant/confs/ingress.yml

echo "Updating /etc/hosts file !"
echo "192.168.56.110 app1.com" | sudo tee -a /etc/hosts
echo "192.168.56.110 app2.com" | sudo tee -a /etc/hosts
echo "192.168.56.110 app3.com" | sudo tee -a /etc/hosts