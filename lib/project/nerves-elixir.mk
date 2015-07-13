ELIXIR_APP_NAME = $(project_id)

ifeq ($(NERVES_ROOT),)
    $(error Make sure that you source nerves-env.sh first)
endif

ifeq ($(shell grep exrm mix.exs),)
    $(error Please add '{ :exrm, "~> 0.15.0" }' to the deps in mix.exs)
endif

ERL_LIB = $(NERVES_SDK_SYSROOT)/usr/lib/erlang/lib
REL2FW = $(NERVES_ROOT)/scripts/rel2fw.sh

FWUP ?= $(shell which fwup)

all: release

release: rel/nerves_system_libs compile
	@echo "building release"
	mix release
	$(REL2FW) rel/$(ELIXIR_APP_NAME) $(ELIXIR_APP_NAME).fw $(ELIXIR_APP_NAME).img

compile: rel/nerves_system_libs
	@echo "compiling"
	mix deps.get
	mix compile

rel/vm.args rel/relx.config:
	@echo $@ not found. Creating a default version...
	@mkdir -p rel
	@sed "s/APP_NAME/$(ELIXIR_APP_NAME)/" \
	    < $(NERVES_ROOT)/scripts/project-skel/elixir/$@ > $@

rel/nerves_system_libs: rel/vm.args rel/relx.config
	@echo "creating link to erlang system libs"
	ln -sfT $(ERL_LIB) $@

clean: fwclean
	mix clean; rm -fr _build _images rel/$(ELIXIR_APP_NAME)

distclean: clean
	-rm -fr ebin deps
