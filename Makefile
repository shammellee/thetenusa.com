.PHONY: all clean $(DEV_DEPS) $(PROD_DEPS) test

# CONFIG
SHELL    := /bin/bash
MAKEFLAGS = -j 3  # limit parallel recipe execution

# COLORS
COLORS.RED     := \033[31m
COLORS.GREEN   := \033[32m
COLORS.YELLOW  := \033[33m
COLORS.BLUE    := \033[34m
COLORS.MAGENTA := \033[35m
COLORS.CYAN    := \033[36m
COLORS.NORMAL  := \033[0m

# PATHS
SRC.DIR            := src
BUILD.DIR          := public
SUPPORT.DIR        := support

SRC.COFFEE_DIR      = $(SRC.DIR)/coffee
SRC.FONT_DIR        = $(SRC.DIR)/fonts
SRC.IMG_DIR         = $(SRC.DIR)/img
SRC.JADE_DIR        = $(SRC.DIR)/jade
SRC.JADE_INC_DIR    = $(SRC.JADE_DIR)/inc
SRC.JSON_DIR        = $(SRC.DIR)/json
SRC.STYLUS_DIR      = $(SRC.DIR)/styl
SRC.STYLUS_INC_DIR  = $(SRC.STYLUS_DIR)/inc
SRC.VENDOR_DIR      = $(SRC.DIR)/vendor

BUILD.CSS_NAME     := css
BUILD.FONT_NAME    := fonts
BUILD.IMG_NAME     := img
BUILD.JS_NAME      := js
BUILD.CSS_DIR       = $(BUILD.DIR)/$(BUILD.CSS_NAME)
BUILD.FONT_DIR      = $(BUILD.DIR)/$(BUILD.FONT_NAME)
BUILD.IMG_DIR       = $(BUILD.DIR)/$(BUILD.IMG_NAME)
BUILD.JS_DIR        = $(BUILD.DIR)/$(BUILD.JS_NAME)
BUILD.DIRS          = $(BUILD.DIR)
BUILD.DIRS         += $(BUILD.CSS_DIR)
BUILD.DIRS         += $(BUILD.FONT_DIR)
BUILD.DIRS         += $(BUILD.IMG_DIR)
BUILD.DIRS         += $(BUILD.JS_DIR)

# DEPENDENCIES
DEV_DEPS  := dev.dirs dev.setup dev.coffee dev.jade dev.styl
PROD_DEPS  = $(DEV_DEPS:dev.%=prod.%)
NPM.PKGS  := coffee-script@1.9.0
NPM.PKGS  += stylus@0.50.0
NPM.PKGS  += jade@1.9.2
NPM.PKGS  += nib@1.1.0
NPM.PKGS  += uglify-js@2.4.19
BREW.PKGS := cairo

# COMMANDS
BREW_INSTALL.CMD    = brew install $(BREW_INSTALL.FLAGS)
BREW_INSTALL.FLAGS :=

CLEAN.CMD           = rm $(CLEAN.FLAGS)
CLEAN.FLAGS        := -rf

COFFEE.CMD          = coffee $(COFFEE.FLAGS)
COFFEE.FLAGS       := --compile --no-header

JADE.CMD            = jade $(JADE.FLAGS)
JADE.FLAGS         := 

LIVE.CMD            = while true; do clear; $1; sleep 1; done

MKDIRS.CMD          = mkdir $(MKDIRS.FLAGS)
MKDIRS.FLAGS       := -p

NPM_INSTALL.CMD     = npm install $(NPM_INSTALL.FLAGS)
NPM_INSTALL.FLAGS  :=

STYLUS.CMD          = stylus $(STYLUS.FLAGS)
STYLUS.FLAGS       := --use 'nib'
STYLUS.FLAGS       += --include-css

UGLIFY.CMD          = uglifyjs $(UGLIFY.FLAGS)
UGLIFY.FLAGS       := --mangle
UGLIFY.FLAGS       += --compress

all: prod

livetree:
	./$(SUPPORT.DIR)/live_build_tree

livestatus:
	./$(SUPPORT.DIR)/live_git_status

livelog:
	./$(SUPPORT.DIR)/live_git_log

# DEPENDENCIES
deps:
	$(BREW_INSTALL.CMD) $(BREW.PKGS)
	$(NPM_INSTALL.CMD) $(NPM.PKGS)

# DEVELOPMENT
dev: | $(DEV_DEPS)

dev.dirs:
	$(MKDIRS.CMD) $(BUILD.DIRS)

dev.setup: dev.dirs
	cp $(SRC.IMG_DIR)/* $(BUILD.IMG_DIR)/
	cp $(SRC.FONT_DIR)/* $(BUILD.FONT_DIR)/
	cp $(SRC.VENDOR_DIR)/*.js $(BUILD.JS_DIR)/

dev.coffee: dev.setup
	$(COFFEE.CMD) --watch --output $(BUILD.JS_DIR) $(SRC.COFFEE_DIR)

dev.jade: dev.setup
	$(JADE.CMD) --obj $(SRC.JSON_DIR)/dev.json --watch $(SRC.JADE_DIR)/*.jade --out $(BUILD.DIR)

dev.styl: dev.setup
	$(STYLUS.CMD) --watch $(SRC.STYLUS_DIR) --out $(BUILD.CSS_DIR)

# PRODUCTION
prod: | $(PROD_DEPS)
	@echo -e '$(COLORS.GREEN)Build complete!$(COLORS.NORMAL)'

prod.dirs:
	@$(MKDIRS.CMD) $(BUILD.DIRS)

prod.setup: prod.dirs
	@echo -e '$(COLORS.YELLOW)Copying static assets...$(COLORS.NORMAL)'
	@cp $(SRC.IMG_DIR)/* $(BUILD.IMG_DIR)/
	@cp $(SRC.FONT_DIR)/* $(BUILD.FONT_DIR)/
	@cp $(SRC.VENDOR_DIR)/*.js $(BUILD.JS_DIR)/

prod.coffee:
	@echo -e '$(COLORS.YELLOW)Compiling CoffeeScript...$(COLORS.NORMAL)'
	@$(COFFEE.CMD) --output $(BUILD.JS_DIR) $(SRC.COFFEE_DIR) > /dev/null
	@#$(UGLIFY.CMD) [<files to uglify>] --output $(BUILD.JS_DIR)/theTen.min.js > /dev/null

prod.jade:
	@echo -e '$(COLORS.YELLOW)Compiling Jade...$(COLORS.NORMAL)'
	@$(JADE.CMD) --obj $(SRC.JSON_DIR)/prod.json $(SRC.JADE_DIR)/*.jade --out $(BUILD.DIR) > /dev/null

prod.styl:
	@echo -e '$(COLORS.YELLOW)Compiling Stylus...$(COLORS.NORMAL)'
	@$(STYLUS.CMD) --compress $(SRC.STYLUS_DIR) --out $(BUILD.CSS_DIR) > /dev/null

clean:
	@echo -e '\033[33mCleaning project...\033[0m'
	@$(CLEAN.CMD)\
		$(BUILD.DIR)\
		node_modules\
		*.log
	@echo -e '\033[32mProject clean!\033[0m'
