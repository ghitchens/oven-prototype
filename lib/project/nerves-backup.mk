sdk_repo = git@github.com:nerves-project/nerves-sdk.git

ERL_LIB = $(NERVES_SDK_SYSROOT)/usr/lib/erlang/lib
ELX_LIB = $(NERVES_ROOT)/buildroot/output/host/usr/lib/elixir/lib
REL2FW = $(NERVES_ROOT)/scripts/rel2fw.sh

#sdk = /home/build/sdks/alix-elixir-generic

sdk = ~/sdks/$(sdk_config)

# compute semantic version#.   Based on elixir model, i.e. having a VERSION file

datestamp_sh = grep - VERSION > /dev/null && date -u +-%y%j-%H%M
datestamp_minor = date -u +%s
#SEM_VER = $(shell cat VERSION)+$(shell $(datestamp_minor))
SEM_VER = $(shell cat VERSION)$(shell $(datestamp_sh))

BUILD_VERSION_FILE = _build/VERSION
BUILD_VERSION = $(shell cat $(BUILD_VERSION_FILE))

FIRMWARE_FILENAME = $(project_id)-$(BUILD_VERSION).fw
IMAGE_FILENAME = $(project_id)-$(BUILD_VERSION).img
FIRMWARE_TARGET = _images/$(FIRMWARE_FILENAME)
IMAGE_TARGET = _images/$(IMAGE_FILENAME)

info: 
	@echo "SDK is "$(sdk)
	@echo "\nFirmare Information:\n"
	@echo "Project ID\t"$(project_id)
	@echo "Source version\t"$(SEM_VER)
ifneq ("$(wildcard _build/VERSION)","")
	@echo "Current build\t"`cat _build/VERSION`
	@echo "           on\t"`cat _build/DATE`
	@echo
else
	@echo "Current Build\tNone\n"
endif

toolchain: nerves
	@echo "nerves is Built"
	
$(sdk)/.stamp_cloned:
	echo "bake: setting up sdk "$(sdk)
	mkdir -p $(sdk)
	git clone $(sdk_repo) $(sdk)
	touch $(sdk)/.stamp_cloned
	
$(sdk)/.stamp_configured: $(sdk)/.stamp_cloned
	make -C $(sdk) $(sdk_config)_defconfig
	touch $(sdk)/.stamp_configured
#	rm -rf $(sdk)/config
#	mkdir -p $(sdk)/config
#	cp -r config/nerves/* _nerves/config
#	cp config/nerves.config _nerves/configs/current_defconfig
#cd -C $(sdk)

$(sdk)/.stamp_built: $(sdk)/.stamp_configured
	make -C $(sdk)
	touch $(sdk)/.stamp_built

nerves_reconfig: 
	rm $(sdk)/.stamp_configured

nerves: $(sdk)/.stamp_built
	
toolchain_env: $(sdk)/.stamp_built
	@echo $(sdk)/nerves-env.sh
	
		
################################## app #####################################

# lib/*.ex lib/echo/*.ex src/*.erl mix.exs
_build/.stamp_built: $(sdk)/.stamp_built 
	mkdir -p _build
	echo $(SEM_VER) > _build/VERSION
	date -u --rfc-3339='seconds' > _build/DATE
	mix deps.get
	project_id=$(project_id) BUILD_DATE=`cat _build/DATE` BUILD_VER=`cat _build/VERSION` mix compile
	touch _build/.stamp_built
	
app: _build/.stamp_built
	
################################# firmware ##################################

_rel/.stamp_built: _build/.stamp_built
	relx --system_libs $(ERL_LIB) -l $(ELX_LIB)
	touch _rel/.stamp_built

_images/.stamp_built: _build/.stamp_built _rel/.stamp_built
	@echo Building $(FIRMWARE_FILENAME)...
	rm -rf _images
	mkdir _images
	touch _images/$(IMAGE_FILENAME)
	$(REL2FW) _rel/$(project_id) tmp.fw $(IMAGE_FILENAME)
	markdown CHANGELOG.md > _images/release.html
	cd _images; unzip tmp.fw; mv data/rootfs.ext2 data/rootfs.img; zip -9 $(FIRMWARE_FILENAME) release.html data/bzImage data/rootfs.img
	elixir deps/echo/embed/mk_firmware_json.exs $(project_id) `cat _build/VERSION` "`cat _build/DATE`" _images/$(FIRMWARE_FILENAME) $(FW_KEY)> _images/firmware.json
	cd _images; zip -9 -u $(FIRMWARE_FILENAME) firmware.json
	touch --date="$(shell cat _build/DATE)" $(FIRMWARE_TARGET)
	@echo Built firmware: $(FIRMWARE_FILENAME) dated: `cat _build/DATE`
	touch _images/.stamp_built
	
release:  _rel/.stamp_built
	
firmware: _images/.stamp_built


################################ deployments ################################

_images/.stamp_uploaded: _images/.stamp_built
	scp -p $(FIRMWARE_TARGET) $(FIRMWARE_SCP_DEST)/$(FIRMWARE_FILENAME)
	touch _images/.stamp_uploaded
	
upload: _images/.stamp_uploaded

################################## uplink ####################################

BRANCH=dev

uplink: _images/.stamp_uploaded
	ssh $(FIRMWARE_SCP_USER)@$(FIRMWARE_REPO) "cd $(FIRMWARE_REPO_DIR); ln -fs $(FIRMWARE_FILENAME) $(BRANCH).fw"
	@echo Firmware $(FIRMWARE_TARGET) uploaded to $(FIRMWARE_REPO) and linked as $(BRANCH).fw

################################### cleaning ##################################

fwclean:
	rm -rf _images _rel
	
clean: fwclean
	rm -fr _build

distclean: clean
	-rm -fr ebin deps $(sdk)
