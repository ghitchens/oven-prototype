# nerves.mk 	bakeware.io makefile for Frank Hunleth's "Nerves" SDK
#
# sdk_type	should always be "nerves" for now
# sdk_recipe	type of configuration for nerves
#
# (C) 2015 bakeware.io - not an open source project at this time

config_root = /usr/local/lib/bake/nerves-cookbook
config_dir = $(config_root)/$(sdk_recipe)
sdk = ~/sdks/$(sdk_type)/$(sdk_recipe)
sdk_repo = https://github.com/nerves-project/nerves-sdk.git

$(sdk)/.stamp_cloned:
	echo "bake: setting up sdk "$(sdk)
	mkdir -p $(sdk)
	git clone $(sdk_repo) $(sdk)
	touch $(sdk)/.stamp_cloned
	
$(sdk)/.stamp_configured: $(sdk)/.stamp_cloned
	rm -rf $(sdk)/config
	mkdir -p $(sdk)/config
	cp -r $(config_dir)/nerves/* $(sdk)/config
	cp $(config_dir)/nerves.config $(sdk)/configs/current_defconfig
	make -C $(sdk) current_defconfig
	touch $(sdk)/.stamp_configured

$(sdk)/.stamp_built: $(sdk)/.stamp_configured
	make -C $(sdk)
	touch $(sdk)/.stamp_built

sdk: $(sdk)/.stamp_built
	
env: $(sdk)/.stamp_built
	@echo $(sdk)/nerves-env.sh	
