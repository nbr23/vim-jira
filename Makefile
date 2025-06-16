INSTALL_SCRIPT = install.sh
JIRA_CONFIG = $(HOME)/.jiraconfig
VIM_PLUGIN_DIR = $(HOME)/.vim/plugin

.PHONY: install clean uninstall

install:
	@chmod +x $(INSTALL_SCRIPT)
	@./$(INSTALL_SCRIPT)

uninstall:
	@echo "Removing JIRA plugin..."
	@rm -f $(VIM_PLUGIN_DIR)/jira.vim
	@echo "Plugin removed (config file preserved)"
