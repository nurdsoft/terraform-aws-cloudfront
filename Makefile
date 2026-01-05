## -----------------------------------------------------------------------------
## Make targets to provide a consistent user experience when running Terraform.
## -----------------------------------------------------------------------------

# Static variables.
TF_PLAN_FILEPATH=plan.tfplan
TERRAFORM=terraform
COMP?=simple-cdn-with-s3
TF_DIR=examples/${COMP}

define DEFAULT_PLAN_ARGS
-no-color -input=false \
-out=${TF_PLAN_FILEPATH}
endef

define DEFAULT_APPLY_ARGS
--auto-approve -input=false
endef

# Avoid name collisions between targets and files.
.PHONY: help fmt init validate plan apply plan-destroy destroy clean 

# A target to format and present all supported targets with their descriptions.
help: Makefile
	@sed -n 's/^##//p' $<

## fmt          : Run terraform fmt.
fmt:
	${TERRAFORM} -chdir=${TF_DIR} fmt -check=true -diff

## init         : Run terraform init.
init:
	${TERRAFORM} -chdir=${TF_DIR} init

## validate     : Run terraform validate.
validate:
	${TERRAFORM} -chdir=${TF_DIR} validate -no-color

## plan         : Run terraform plan for the provided service.
plan: clean init validate
	${TERRAFORM} -chdir=${TF_DIR} plan ${DEFAULT_PLAN_ARGS}

## apply        : Run terraform apply for the provided service.
apply: plan
	${TERRAFORM} -chdir=${TF_DIR} apply ${DEFAULT_APPLY_ARGS}

## plan-destroy : Run terraform plan destroy for the provided service.
plan-destroy: clean 
	${TERRAFORM} -chdir=${TF_DIR} plan -destroy ${DEFAULT_PLAN_ARGS}

## destroy      : Run terraform destroy for the provided service.
destroy: 
	${TERRAFORM} -chdir=${TF_DIR} destroy -auto-approve

## clean        : Find and remove all the temporary files
clean:
	@find . -name ".terraform" -type d -print0 | xargs -0 -I {} rm -rf "{}"
	@find . -name ".terraform.lock.hcl" -type f -print0 | xargs -0 -I {} rm -rf "{}"
	@find . -name "plan.tfplan" -type f -print0 | xargs -0 -I {} rm -rf "{}"

## docs         : Generate documentation for the module.
docs:
	@terraform-docs markdown .