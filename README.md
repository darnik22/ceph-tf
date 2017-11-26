# Terraform files for creating a Ceph cluster on OTC

## Configuring
In order to build your Ceph cluster you need to:
* provide your openstack credentials by editting parameter.tvars
* provide (or generate with ssh-keygen) RSA key files keys/id_rsa and keys/id_rsa.pub
* eventually change values in varaibles.tf

## Running
Build your Ceph cluster issuing:
```
terraform init
terraform apply -var-file parameter.tvars
```

## Accessing your Ceph cluster
After a successful built the public IP of the cluster management node is displayed. Use it to login:
```ssh -i keys/id_rsa ubuntu@THE_IP```

Check that Ceph is running:
```
sudo ceph -s
```

## Example command flow
```
git clone
cd ceph-tf
mkdir keys
ssh-keygen -f keys/id_rsa
vi parameter.tvars
vi variables.tf
terraform init
terraform apply -var-file parameter.tvars
ssh -i keys/id_rsa ubuntu@THE_IP_OF_MGT
sudo ceph -s
```

