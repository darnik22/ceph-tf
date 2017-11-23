# Terraform files for creating a Ceph cluster on OTC

## Configuration
In order to build your Ceph cluster you need to:
* provide your openstack credentials by editting parameter.tvars
* provide (or generate with ssh-keygen) RSA key files keys/id_rsa and keys/id_rsa.pub
* eventually change values in varaibles.tf

## Running
Build your Ceph cluster issuing:
terraform init
terraform apply -var-file parameter.tvars

## Accessing
After a successful built the public IP of the cluster management node is displayed. Use it to login:
ssh -i keys/id_rsa ubuntu@THE_IP

Check that Ceph is running:
sudo ceph -s
