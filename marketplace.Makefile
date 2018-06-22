ifndef __MARKETPLACE_MAKEFILE__

__MARKETPLACE_MAKEFILE__ := included


makefile_dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
include $(makefile_dir)/common.Makefile

DRIVER_IMAGE ?= gcr.io/google-marketplace-tools/k8s/test_driver

.build/marketplace: | .build
	mkdir -p "$@"


.build/marketplace/deployer: | .build/marketplace
	mkdir -p "$@"


.build/marketplace/deployer/envsubst: $(MARKETPLACE_TOOLS_PATH)/marketplace/deployer_util/* \
                                      $(MARKETPLACE_TOOLS_PATH)/marketplace/deployer_envsubst_base/* \
                                      .build/marketplace/delete_deprecated \
                                      | .build/marketplace/deployer
	$(call print_target)
	cd $(MARKETPLACE_TOOLS_PATH) \
	&& docker build \
	    --tag "gcr.io/cloud-marketplace-tools/k8s/deployer_envsubst" \
	    -f marketplace/deployer_envsubst_base/Dockerfile \
	    .
	@touch "$@"


.build/marketplace/deployer/helm: $(MARKETPLACE_TOOLS_PATH)/marketplace/deployer_util/* \
                                  $(MARKETPLACE_TOOLS_PATH)/marketplace/deployer_helm_base/* \
                                  .build/marketplace/delete_deprecated \
                                  | .build/marketplace/deployer
	$(call print_target)
	cd $(MARKETPLACE_TOOLS_PATH) \
	&& docker build \
	    --tag "gcr.io/cloud-marketplace-tools/k8s/deployer_helm" \
	    -f marketplace/deployer_helm_base/Dockerfile \
	    .
	@touch "$@"


.build/marketplace/driver: $(MARKETPLACE_TOOLS_PATH)/marketplace/driver/* \
                           $(MARKETPLACE_TOOLS_PATH)/scripts/* \
                           .build/marketplace
	$(call print_target, $@)
	cd $(MARKETPLACE_TOOLS_PATH) \
	&& docker build \
	    --tag "$(DRIVER_IMAGE)" \
	    -f marketplace/driver/Dockerfile \
	    .
	@touch "$@"


.build/marketplace/delete_deprecated: | .build/marketplace
	@docker images --format '{{.Repository}}' \
	    | sort | uniq \
	    | grep gcr.io/google-marketplace-tools/ \
	    | xargs -I {} -r -n 1 printf '\n\033[93m\033[1m{} is DEPRECATED. Please update your Dockerfile\033[0m\n\n'
	@docker images --format '{{.Repository}}:{{.Tag}}' \
	    | grep gcr.io/google-marketplace-tools/ \
	    | grep -v -e '<[Nn]one>' \
	    | xargs -r docker rmi
	@touch "$@"


endif
