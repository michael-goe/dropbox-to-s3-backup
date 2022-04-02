# Backup Dropbox to S3

Based on [Marco Lancini's aws-gdrive-backups](https://github.com/marco-lancini/utils/tree/main/terraform/aws-gdrive-backups) but for Dropbox and with simplified, quasi-automatic setup and using only vanilla AWS Terraform module. 

This modules automates the backup of your Dropbox files in S3, thereby adding another layer of protection against data loss. It utilizes rclone within an ECS task to fetch data from Dropbox and saves an archive of it in a S3 bucket with a configurable lifecycle configured for Standard -> Glacier -> Deep Archive with expiration. 


*DISCLAIMER: Using this will incur costs in your AWS account (obviously).*
# Setup steps

## Prerequisites: Dropbox, rclone and AWS
### Create a Dropbox API key 
You need an API key for authorizing AWS with Dropbox. 
* Go to [Dropbox Developer page](https://www.dropbox.com/developers/) -> App console
* Create new app
 . Choose an API: Select "Scoped access"
 . "Choose the type of access you need": Either "App Folder" or "Full Dropbox" depending on what you want to backup
 . "Name your app": Arbitrary name
* Configure newly created app on "Permissions" page to only have read permission _files.content.read_ as well as pre-set _files.metadata.read_ and *account_info.read* 

### Generate rconfig configuration
Follow the rclone documentation on configuring an Dropbox endpoint at https://rclone.org/dropbox/

### Create an AWS SSM secret
This is the only manual AWS step and will allow the ECS task to safely authorize. 
* Go to AWS Systems Manager
* Go to Parameter Store
* Create a parameter called DROPBOX_RCLONE_CONFIG (or name of your choice, just be sure to change the configuration as described below) as type SecureString with the Dropbox entry of your generated rconfig as the value, e.g.
```
[dropbox]
type = dropbox
client_id = <your_client_id>
client_secret = <your_client_secret>
token = {"access_token":"...","token_type":"bearer","refresh_token":"...","expiry":"..."}
```


## Configuration
Adjust the parameters in terraform/variables.tf. All parameters have a default except for *s3_bucket_name* which must be globally unique and *email_address* which is used for sending notifications about backup events. If you do not wish to receive mail notifications, simply ignore the opt-in mail that AWS will send.

## Setup
Make sure you are signed in to the AWS CLI, have the Docker daemon running for building the ECS task image and have Terraform installed. 

Execute setup.sh to create the necessary AWS infrastructure using Terraform. 
