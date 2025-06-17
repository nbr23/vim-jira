INSTALL_SCRIPT = install.sh
JIRA_CONFIG = $(HOME)/.jiraconfig
VIM_PLUGIN_DIR = $(HOME)/.vim/plugin
PYTHON_INSTALL_DIR = /usr/local/bin

.PHONY: install clean uninstall

install:
	@chmod +x $(INSTALL_SCRIPT)
	@./$(INSTALL_SCRIPT)
	@cp vim-jira.py $(PYTHON_INSTALL_DIR)/vim-jira.py

uninstall:
	@echo "Removing JIRA plugin..."
	@rm -f $(VIM_PLUGIN_DIR)/jira.vim
	@echo "Plugin removed (config file preserved)"
