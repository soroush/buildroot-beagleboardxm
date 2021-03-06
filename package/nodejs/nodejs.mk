################################################################################
#
# nodejs
#
################################################################################

NODEJS_VERSION = 0.10.31
NODEJS_SOURCE = node-v$(NODEJS_VERSION).tar.gz
NODEJS_SITE = http://nodejs.org/dist/v$(NODEJS_VERSION)
NODEJS_DEPENDENCIES = host-python host-nodejs zlib \
    $(call qstrip,$(BR2_PACKAGE_NODEJS_MODULES_ADDITIONAL_DEPS))
HOST_NODEJS_DEPENDENCIES = host-python host-zlib
NODEJS_LICENSE = MIT (core code); MIT, Apache and BSD family licenses (Bundled components)
NODEJS_LICENSE_FILES = LICENSE

ifeq ($(BR2_PACKAGE_OPENSSL),y)
	NODEJS_DEPENDENCIES += openssl
endif

# nodejs build system is based on python, but only support python-2.6 or
# python-2.7. So, we have to enforce PYTHON interpreter to be python2.
define HOST_NODEJS_CONFIGURE_CMDS
	# Build with the static, built-in OpenSSL which is supplied as part of
	# the nodejs source distribution.  This is needed on the host because
	# NPM is non-functional without it, and host-openssl isn't part of
	# buildroot.
	(cd $(@D); \
		$(HOST_CONFIGURE_OPTS) \
		PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(HOST_DIR)/usr/bin/python2 ./configure \
		--prefix=$(HOST_DIR)/usr \
		--without-snapshot \
		--without-dtrace \
		--without-etw \
		--shared-zlib \
	)
endef

define HOST_NODEJS_BUILD_CMDS
	$(HOST_MAKE_ENV) PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(MAKE) -C $(@D) \
		$(HOST_CONFIGURE_OPTS)
endef

define HOST_NODEJS_INSTALL_CMDS
	$(HOST_MAKE_ENV) PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(MAKE) -C $(@D) install \
		$(HOST_CONFIGURE_OPTS)
endef

ifeq ($(BR2_i386),y)
NODEJS_CPU=ia32
else ifeq ($(BR2_x86_64),y)
NODEJS_CPU=x64
else ifeq ($(BR2_mipsel),y)
NODEJS_CPU=mipsel
else ifeq ($(BR2_arm),y)
NODEJS_CPU=arm
# V8 needs to know what floating point ABI the target is using.  There's also
# a 'hard' option which we're not exposing here at the moment, because
# buildroot itself doesn't really support it at present.
ifeq ($(BR2_SOFT_FLOAT),y)
NODEJS_ARM_FP=soft
else
NODEJS_ARM_FP=softfp
endif
endif

define NODEJS_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CXX)" \
		PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(HOST_DIR)/usr/bin/python2 ./configure \
		--prefix=/usr \
		--without-snapshot \
		--shared-zlib \
		$(if $(BR2_PACKAGE_OPENSSL),--shared-openssl,--without-ssl) \
		$(if $(BR2_PACKAGE_NODEJS_NPM),,--without-npm) \
		--without-dtrace \
		--without-etw \
		--dest-cpu=$(NODEJS_CPU) \
		$(if $(NODEJS_ARM_FP),--with-arm-float-abi=$(NODEJS_ARM_FP)) \
		--dest-os=linux \
	)
endef

define NODEJS_BUILD_CMDS
	$(TARGET_MAKE_ENV) PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CXX)"
endef

#
# Build the list of modules to install based on the booleans for
# popular modules, as well as the "additional modules" list.
#
NODEJS_MODULES_LIST= $(call qstrip,\
	$(if $(BR2_PACKAGE_NODEJS_MODULES_EXPRESS),express) \
	$(if $(BR2_PACKAGE_NODEJS_MODULES_COFFEESCRIPT),coffee-script) \
	$(BR2_PACKAGE_NODEJS_MODULES_ADDITIONAL))

#
# We can only call NPM if there's something to install.
#
ifneq ($(NODEJS_MODULES_LIST),)
define NODEJS_INSTALL_MODULES
	# If you're having trouble with module installation, adding -d to the
	# npm install call below and setting npm_config_rollback=false can both
	# help in diagnosing the problem.
	(cd $(TARGET_DIR)/usr/lib && mkdir -p node_modules && \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CXX)" \
		npm_config_arch=$(NODEJS_CPU) \
		npm_config_nodedir=$(BUILD_DIR)/nodejs-$(NODEJS_VERSION) \
		$(HOST_DIR)/usr/bin/npm install \
		$(NODEJS_MODULES_LIST) \
	)
endef
endif

define NODEJS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) PYTHON=$(HOST_DIR)/usr/bin/python2 \
		$(MAKE) -C $(@D) install \
		DESTDIR=$(TARGET_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CXX)"
	$(NODEJS_INSTALL_MODULES)
endef

# node.js configure is a Python script and does not use autotools
$(eval $(generic-package))
$(eval $(host-generic-package))
