# nerves-custom.mk 
#
# (C) 2015 bakeware.io - not an open source project at this time

sdk = ~/sdks/$(sdk_type)/$(sdk_custom_id)
sdk_repo = https://github.com/nerves-project/nerves-sdk.git

$(sdk)/.stamp_cloned:
	echo "bake: setting up sdk "$(sdk)
	mkdir -p $(sdk)
	git clone $(sdk_repo) $(sdk)
	touch $(sdk)/.stamp_cloned
	
$(sdk)/.stamp_configured: $(sdk)/.stamp_cloned
	rm -rf $(sdk)/config
	mkdir -p $(sdk)/config
	cp -r  bake/config/* $(sdk)/config
	cp bake/nerves.config $(sdk)/configs/current_defconfig
	make -C $(sdk) current_defconfig
	touch $(sdk)/.stamp_configured

$(sdk)/.stamp_built: $(sdk)/.stamp_configured
	make -C $(sdk)
	touch $(sdk)/.stamp_built

sdk: $(sdk)/.stamp_built
	
env: $(sdk)/.stamp_built
	@echo $(sdk)/nerves-env.sh	
