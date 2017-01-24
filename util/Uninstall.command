#!/bin/bash
#
# Short:    Uninstall LoginHookWarden - command-line equivalent of the package
# Author:   Mark J Swift
# Version:  1.0.2
# Modified: 23-Jan-2017
#
#
# Called as follows:    
#   Uninstall.command [<root_dirpath>]

# ---

# Full souce of this script
sv_ThisScriptFilePath="${0}"

# Path to this script
sv_ThisScriptDirPath="$(dirname "${sv_ThisScriptFilePath}")"

# Change working directory
cd "${sv_ThisScriptDirPath}"

# Filename of this script
sv_ThisScriptFileName="$(basename "${sv_ThisScriptFilePath}")"

# ---

# Filename without extension
GLB_sv_ThisScriptName="$(echo ${sv_ThisScriptFileName} | sed 's|\.[^.]*$||')"

# Path to project files
GLB_sv_ProjectDirPath="$(dirname "${sv_ThisScriptDirPath}")"

# Include the CommonLib
. "${GLB_sv_ProjectDirPath}/lib/CommonLib"

# Exit if something went wrong unexpectedly
if test -z "${GLB_sv_ProjectName}"
then
  exit 0
fi

# ---

# Where we should install
sv_RootDirPath="${1}"

if [ "${sv_RootDirPath}" = "/" ]
then
  sv_RootDirPath=""
fi

# ---

if [ "${GLB_bv_ThisUserIsAdmin}" = "false" ]
then
  echo >&2 "ERROR: You must be an admin to run this software."
  exit 0
fi

# ---

if [ "${GLB_sv_ThisUserName}" != "root" ]
then
  echo ""
  echo "If asked, enter the password for user '"${GLB_sv_ThisUserName}"'"
  echo ""
  sudo "${sv_ThisScriptFilePath}" "${sv_RootDirPath}"

else

  if test -z "${sv_RootDirPath}"
  then

    GLB_nf_logmessage "NOTE: Uninstalling ${GLB_sv_ProjectName}."

    if test -n "$(launchctl list | grep -i "${GLB_sv_ProjectSignature}.CheckHooks")"
    then

      if test -f "${sv_RootDirPath}"/Library/LaunchDaemons/${GLB_sv_ProjectSignature}.CheckHooks.plist
      then
        launchctl unload "${sv_RootDirPath}"/Library/LaunchDaemons/${GLB_sv_ProjectSignature}.CheckHooks.plist
      else
        GLB_nf_logmessage "NOTE: You will need to reboot to completely uninstall ${GLB_sv_ProjectName}."
      fi
    fi

  fi
  
  # remove old LauncDaemon
  if test -f "${sv_RootDirPath}"/Library/LaunchDaemons/${GLB_sv_ProjectSignature}.CheckHooks.plist
  then
    rm -f "${sv_RootDirPath}"/Library/LaunchDaemons/${GLB_sv_ProjectSignature}.CheckHooks.plist
  fi

  # Remove old config
  if test -z "${sv_RootDirPath}"
  then
    sv_MasterLoginHookFilePath="/usr/local/${GLB_sv_ProjectName}/scripts/MasterLoginHook"
    sv_CurrentLoginHookFilePath="$(defaults read com.apple.loginwindow LoginHook)"
    if [ "${sv_CurrentLoginHookFilePath}" = "${sv_MasterLoginHookFilePath}" ]
    then
      defaults write com.apple.loginwindow LoginHook ""

      # Check all login hooks, and re-instate the most recent
      if test -e "${GLB_sv_ProjectConfig}/LoginHooks"
      then
        while read sv_LoginHookLinkName
        do
          # Get the filepath of the script that the hook link points to
          sv_LoginHookFilePath="$(stat -f "%Y" "${GLB_sv_ProjectConfig}/LoginHooks/${sv_LoginHookLinkName}")"
          if test -n "${sv_LoginHookFilePath}"
          then
            if test -e "${sv_LoginHookFilePath}"
            then
              # The Hook link is OK - so re-instate it
              GLB_nf_logmessage "NOTE: Restoring LoginHook '${sv_LoginHookFilePath}'"
              defaults write com.apple.loginwindow LoginHook "${sv_LoginHookFilePath}"
              break
            fi
          fi
        done < <(ls -1t "${GLB_sv_ProjectConfig}/LoginHooks")
      fi
    fi

    sv_MasterLogoutHookFilePath="/usr/local/${GLB_sv_ProjectName}/scripts/MasterLogoutHook"

    sv_CurrentLogoutHookFilePath="$(defaults read com.apple.loginwindow LogoutHook)"
    if [ "${sv_CurrentLogoutHookFilePath}" = "${sv_MasterLogoutHookFilePath}" ]
    then
      defaults write com.apple.loginwindow LogoutHook ""

      # Check all logout hooks, and re-instate the most recent
      if test -e "${GLB_sv_ProjectConfig}/LogoutHooks"
      then
        while read sv_LogoutHookLinkName
        do
          # Get the filepath of the script that the hook link points to
          sv_LogoutHookFilePath="$(stat -f "%Y" "${GLB_sv_ProjectConfig}/LogoutHooks/${sv_LogoutHookLinkName}")"
          if test -n "${sv_LogoutHookFilePath}"
          then
            if test -e "${sv_LogoutHookFilePath}"
            then
             # The Hook link is OK - so re-instate it
             GLB_nf_logmessage "NOTE: Restoring LogoutHook '${sv_LogoutHookFilePath}'"
             defaults write com.apple.loginwindow LogoutHook "${sv_LogoutHookFilePath}"
            fi
          fi
        done < <(ls -1t "${GLB_sv_ProjectConfig}/LogoutHooks")
      fi

    fi

    # Remove the config files
    rm -fR "${GLB_sv_ProjectConfig}"
  fi

  # remove old install
  if test -d "${sv_RootDirPath}"/usr/local/${GLB_sv_ProjectName}
  then
    rm -fR "${sv_RootDirPath}"/usr/local/${GLB_sv_ProjectName}
  fi
  
  if test -z "${sv_RootDirPath}"
  then
    pkgscripts 2>/dev/null --forget "${LW_sv_LabWardenSignature}"
  else
    pkgscripts 2>/dev/null --forget "${LW_sv_LabWardenSignature}" --volume "${sv_RootDirPath}"
  fi

fi

exit 0
