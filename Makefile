Tool := bau
Src  := bau.sh

BlueDir := /usr/local/bluemarble

InstallBinDir    := $(BlueDir)/bin
InstallPluginDir := $(BlueDir)/lib/bau
InstallHelperDir := $(BlueDir)/lib/bau


CP := cp
CPFLAGS := -fp
CHMOD := chmod

default : $(Tool)

install : \
	$(InstallBinDir)/$(Tool) \
	$(InstallPluginDir)/Prune.plugin  \
	$(InstallPluginDir)/MakeScript.plugin  \
	$(InstallPluginDir)/MakeProgram.plugin \
	$(InstallPluginDir)/MakeLibrary.plugin \
	$(InstallPluginDir)/InstallFile.plugin \
	$(InstallHelperDir)/bt-makescript-helper.sh

# install bt/bau

$(InstallBinDir)/$(Tool) : $(Tool)
	$(CP) $(CPFLAGS) $< $@ 
	$(CHMOD) -w $@
$(Tool) : $(Src)
	$(CP) $(CPFLAGS) $< $@
	$(CHMOD) +x $@


# install the plug-ins

PLUGINS += MakeScript.plugin
PLUGINS += MakeProgram.plugin
PLUGINS += MakeLibrary.plugin

$(InstallPluginDir)/Prune.plugin : plugins/Prune.plugin
$(InstallPluginDir)/MakeScript.plugin : plugins/MakeScript.plugin
$(InstallPluginDir)/MakeProgram.plugin : plugins/MakeProgram.plugin
$(InstallPluginDir)/MakeLibrary.plugin : plugins/MakeLibrary.plugin
$(InstallPluginDir)/InstallFile.plugin : plugins/InstallFile.plugin

$(InstallPluginDir)/%.plugin : plugins/%.plugin
	$(CP) $(CPFLAGS) $< $@ 
	$(CHMOD) -w $@

# install the helper scripts

HELPERS += helpers/bt-makescript-helper.sh

$(InstallHelperDir)/bt-makescript-helper.sh : helpers/bt-makescript-helper.sh

$(InstallHelperDir)/%.sh : helpers/%.sh
	$(CP) $(CPFLAGS) $< $@ 
	$(CHMOD) -w $@

#
# End of makefile
#
