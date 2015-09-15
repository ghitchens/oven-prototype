sdk = $(OVEN_SDKS)/$(sdk_type)/$(sdk_config)

sdk: $(sdk)/.stamp_built
  @echo "error: missing sdk"
	exit 1
		
env: $(sdk)/.stamp_built
	@echo $(sdk)/nerves-env.sh	
