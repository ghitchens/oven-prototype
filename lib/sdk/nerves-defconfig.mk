sdk = ~/sdks/$(sdk_type)/$(sdk_config)
sdk_repo = https://github.com/nerves-project/nerves-sdk.git

$(sdk)/.stamp_cloned:
	echo "oven: setting up sdk $(sdk)"
	mkdir -p $(sdk)
	git clone $(sdk_repo) $(sdk)
	touch $(sdk)/.stamp_cloned
	
$(sdk)/.stamp_configured: $(sdk)/.stamp_cloned
	make -C $(sdk) $(sdk_config)
	touch $(sdk)/.stamp_configured

$(sdk)/.stamp_built: $(sdk)/.stamp_configured
	make -C $(sdk)
	touch $(sdk)/.stamp_built

sdk: $(sdk)/.stamp_built
	
env: $(sdk)/.stamp_built
	@echo $(sdk)/nerves-env.sh	
