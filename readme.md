# EXCHANGE 2016 CU17 INSTALLATION

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmodzilla99%2FExchange2016Azure%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


This template deploys a VM with ADDS and Exchange 2016 CU17 installed.



| Endpoint        | Version           | Validated  |
| ------------- |:-------------:| -----:|
| Microsoft Azure      | - | YES |


## Deployed resources

The following resources are deployed as part of the solution
####[Exchange 2016 Non-HA]
[Deploys a VM, install pre-requisites, downloads Exchange 2016 ISO, install Exchange 2016 on a seperate disk drive (E:) and create Mailbox on a seperate disk drive (F:)]
+ **Public IP Address**: Allows connection to a VM
+ **Network Security Group**: 
+ **Storage Account**: VHDs, Result blobs storage
+ **Network Interface**: 
+ **Virtual Network**: 
+ **Virtual Machine**: To run Jetstress test
+ **DSC Extension**: Install Exchange 2016




