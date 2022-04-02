# Setup script
# - Executes Terraform
# - Executes build and push of Docker image
pushd terraform
terraform init
terraform apply -auto-approve
popd 
pushd docker 
sh push_to_ecr.sh
popd 