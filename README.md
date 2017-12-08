# Terraform files for creating a Ceph cluster on OTC with oneprovider supporting a space

## Configuring
In order to build your Ceph cluster you need to:
* provide your openstack credentials by editting parameter.tvars
* provide (or generate with ssh-keygen) RSA key files keys/id_rsa and keys/id_rsa.pub
* eventually change values in varaibles.tf

In order to configure oneprovider and oneclient you need to:
* have a registered domain which uses (delegates to) the following nameservers:
  * ns1.open-telekom-cloud.com.
  * ns2.open-telekom-cloud.com.
* have a support token from your onezone
* have an access token from your onezone

Edit variables.tf and set at least the following vars:
* dnszone - your registered domain
* email - your email
* onezone - onezone URL
* token - request space support token
* atoken - access token
* project - project name. It is used to prefix VM names. It should be unique among OTC as it is used to create names of VMs. The provider will have the following FQDN: ${project}-op-01.${dnszone} publicly accessible.

The variables can also be set as command line args.

## Running
Build your Ceph cluster issuing:
```
terraform init
terraform apply -var-file parameter.tvars
```
The oneprovider credentials are displayed in green somewhere in the ugly output of terraform/ansible. The same is stored in ~/onedatify.stdout on the oneprovider node. 

## Accessing your Ceph cluster
After a successful built the public IP of the cluster management node is displayed. Use it to login:
```
ssh -i keys/id_rsa ubuntu@THE_IP
```

Check that Ceph is running:
```
sudo ceph -s
```

## Example command flow
```
git clone https://github.com/darnik22/ceph-tf.git
cd ceph-tf
mkdir keys
ssh-keygen -f keys/id_rsa
vi parameter.tvars
vi variables.tf
terraform init
terraform apply -var-file parameter.tvars
ssh -i keys/id_rsa ubuntu@THE_IP_OF_MGT_NODE
sudo ceph -s
ssh ${project}-client-01
cd onedata/YOUR_SPACE
ls
```

