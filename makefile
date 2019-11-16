SHELL := /bin/bash

images: imageapp imagedb

image-app:
	packer build -var-file=packer/variables.json packer/app.json

image-db:
	packer build -var-file=packer/variables.json packer/db.json

up-stage:
	cd terraform/stage; terraform apply
	cd ansible; ansible-playbook playbooks/site.yml

down-stage:
	cd terraform/stage; terraform destroy

up-prod:
	cd terraform/prod; terraform apply	
	cd ansible; ansible-playbook -i environment/prod/inventory.gcp.yml playbooks/site.yml
	
down-prod:
	cd terraform/prod; terraform destroy

