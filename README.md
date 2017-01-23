
# LoginHookWarden

![Logo](images/LoginHookWarden.jpg "Logo")



## Brief

Facilitate multiple Login and Logout scripts transparently.

## Introduction

LoginHookWarden is a simple script that transparently manages the LoginHook and LogoutHook settings to allow multiple login scripts - this means:

	More than one login and logout script can be installed at the same time...

You should note that login scripts are deprecated technology, and Apple has a section about "Customizing Login and Logout" in its [Daemons and Services Programming Guide](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CustomLogin.html "Daemons and Services Programming Guide") that recommends that you avoid Login Scripts in favour of Authenticated Plug-Ins. 

Here is a brief extract:

 
	Important: There are numerous reasons to avoid using login and logout scripts:
	Login and logout scripts are a deprecated technology...
	Only one of each script can be installed at a time...

However login scripts are really useful to sysadmins. So if you don't mind using deprecated technology, and you have multiple login and logout scripts that all want to use the same hooks - then you might want to consider LoginHookWarden.

If instead, you want to use Authenticated Plug-Ins to run custom code at Login, you could try the [LoginScriptPlugin](https://github.com/MagerValp/LoginScriptPlugin "LoginScriptPlugin") by [MagerValp](https://github.com/MagerValp/ "MagerValp"). 


## Installation

Download the LoginHookWarden zip archive from <https://github.com/execriez/LoginHookWarden>

* Unzip the archive on a Mac workstation.
* Double-click "LoginHookWarden.pkg" from the "SupportFiles" directory.

The installer will install the following files and directories:

* /Library/LaunchDaemons/com.github.execriez.LoginHookWarden.CheckHooks.plist
* /usr/LoginHookWarden/

There's no need to reboot.

Existing Login and Logout hooks will still work after installation, even though the existing LoginHook and LogoutHook settings are overwitten.

The installer will fail if LoginHookWarden is already installed, or if the installer determines that another process is managing LoginHooks.

After installation, you can write to the relevant com.apple.loginwindow key value several times, to create several login and logout hooks - all of which will be serviced.

## Uninstall

* Double-click "LoginHookWarden-Uninstaller.pkg" from the "SupportFiles" directory.

The uninstaller will uninstall the following files and directories:

  /Library/Preferences/SystemConfiguration/com.github.execriez.LoginHookWarden/
  /Library/LaunchDaemons/com.github.execriez.LoginHookWarden.CheckHooks.plist
  /usr/LoginHookWarden/

There's no need to reboot.

If custom Login and Logout hooks have been installed, then the most recent ones will be restored into the com.apple.loginwindow hooks after the uninstall.

After the uninstall LoginHookWarden everything go back to normal, and there can be only one LoginHook and one LogoutHook.
	
##Adding a custom login hook

Adding a custom LoginHook or LogoutHook is done as you would expect, by using the defaults command to write a value to the relevant com.apple.loginwindow key as follows:

* defaults write com.apple.loginwindow LoginHook PATH-SCRIPT
* defaults write com.apple.loginwindow LogoutHook PATH-SCRIPT

LoginHookWarden watches for modifications to the file "/private/var/root/Library/Preferences/com.apple.loginwindow.plist" via a WatchPaths LaunchDaemon. It then transparently manages the hooks itself.

##Removing a custom login hook

If there is only one custom LoginHook and LogoutHook, then everything works as normal.

i.e, to remove the LoginHook or LogoutHook, you simply write a null value to the relevant com.apple.loginwindow key as follows:

* defaults write com.apple.loginwindow LoginHook ""
* defaults write com.apple.loginwindow LogoutHook ""

If there is more than one custom LoginHook and LogoutHook, then removing one is not as transparent.

With more than one custom hook, setting the relevant com.apple.loginwindow key value to null has no effect. This is because LoginHookWarden does not know which hook to remove.

Instead, you need to either delete the custom LOGIN-SCRIPT/LOGOUT-SCRIPT, or delete the link to the script from the following folders: 

* /Library/Preferences/SystemConfiguration/com.github.execriez.LoginHookWarden/LoginHooks/
* /Library/Preferences/SystemConfiguration/com.github.execriez.LoginHookWarden/LogoutHooks/

Once the script, or the link to the script has been removed, the hook will no longer be serviced.

## How it works

LoginHookWarden watches for modifications to the file "/private/var/root/Library/Preferences/com.apple.loginwindow.plist" via a WatchPaths LaunchDaemon. 

If it determines that a new LoginHook or LogoutHook has been set, it reads the new value(s) from com.apple.loginwindow, and creates a symbolic link to the each script in the following folder(s):

* /Library/Preferences/SystemConfiguration/com.github.execriez.LoginHookWarden/LoginHooks/
* /Library/Preferences/SystemConfiguration/com.github.execriez.LoginHookWarden/LogoutHooks/

LoginHookWarden then overwrites the values in com.apple.loginwindow with it's own LoginHook and LogoutHook code. This code runs every custom login hook that has a symbolic link in the LoginHook or LogoutHook folders above. 

Hooks are run concurrently, so one hook does not need to wait for another to finish before executing.

If the code determines that a symbolic link is broken, it will remove it from the relevant folder and the custom hook will no longer be serviced

This allows multiple custom login hooks to be set and serviced.

## Logs

Logs are written to the following file:

* /Library/Logs/com.github.execriez.LoginHookWarden.log

A typical log file looks something like this:

	20 Jan 2017 14:50:35 CheckHooks: NOTE: Checking com.apple.loginwindow for changes
	20 Jan 2017 14:50:35 CheckHooks: ATTENTION: Installing LoginHook '/usr/local/LabWarden/lib/LoginHook'
	20 Jan 2017 14:50:35 CheckHooks: ATTENTION: Installing LogoutHook '/usr/local/LabWarden/lib/LogoutHook'
	20 Jan 2017 14:50:36 CheckHooks: NOTE: Checking com.apple.loginwindow for changes
	20 Jan 2017 14:50:54 CheckHooks: NOTE: Checking com.apple.loginwindow for changes
	20 Jan 2017 14:55:22 MasterLoginHook: NOTE: Running for user 'local'
	20 Jan 2017 14:55:22 MasterLoginHook: ATTENTION: Running LoginHook '/usr/local/LabWarden/lib/LoginHook local'
	20 Jan 2017 14:56:33 MasterLogoutHook: NOTE: Running for user 'local'
	20 Jan 2017 14:56:33 MasterLogoutHook: ATTENTION: Running LogoutHook '/usr/local/LabWarden/lib/LogoutHook local'

You can use the log file to check if your custom hook is being serviced.

## History

1.0.2 - 23 JAN 2017

* Added code to remove a custom hook if there is only one, and you write null to the relevant com.apple.loginwindow LoginHook or LogoutHook.

* Updated the readme in the installer and uninstaller.

1.0.1 - 22 JAN 2017

* First public release.

