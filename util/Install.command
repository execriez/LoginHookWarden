#!/bin/bash
#
# Short:    Install LoginHookWarden - command-line equivalent of the package
# Author:   Mark J Swift
# Version:  1.0.2
# Modified: 23-Jan-2017
#
#
# Called as follows:    
#   Install.command [<root_dirpath>]

# ---

# Full souce of this script
sv_ThisScriptFilePath="${0}"

# Path to this script
sv_ThisScriptDirPath="$(dirname "${sv_ThisScriptFilePath}")"

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

if [ "${GLB_sv_ProjectDirPath}" = "${sv_RootDirPath}/usr/local/${GLB_sv_ProjectName}" ]
then
  echo >&2 "ERROR: You cannot install to the folder that you are installing from. Copy the folder somewhere else and try again."
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
    "${GLB_sv_ProjectDirPath}/lib/PreInstall"
    iv_Error="$?"
    if [ "${iv_Error}" != "0" ]
    then
      GLB_nf_logmessage "NOTE: cancelling install of ${GLB_sv_ProjectName}."
      exit ${iv_Error}
    fi

    GLB_nf_logmessage "NOTE: installing ${GLB_sv_ProjectName}."
  fi

  # Create a temporary directory private to this script
  sv_ThisScriptTempDirPath="$(mktemp -dq /tmp/Install-XXXXXXXX)"

  # -- Copy the main payload
  mkdir -p "${sv_ThisScriptTempDirPath}/${GLB_sv_ProjectName}"
  cp -pR "${GLB_sv_ProjectDirPath}/" "${sv_ThisScriptTempDirPath}/${GLB_sv_ProjectName}/"

  # -- Remove any unwanted files
  find "${sv_ThisScriptTempDirPath}/${GLB_sv_ProjectName}" -iname .DS_Store -exec rm -f {} \;
  rm -fR "${sv_ThisScriptTempDirPath}/${GLB_sv_ProjectName}/.git"
  rm -fR "${sv_ThisScriptTempDirPath}/${GLB_sv_ProjectName}/SupportFiles"

  # -- Copy into place
  cp -pR "${sv_ThisScriptTempDirPath}/${GLB_sv_ProjectName}/" "${sv_RootDirPath}"/usr/local/${GLB_sv_ProjectName}/
  chown -R root:wheel "${sv_RootDirPath}"/usr/local/${GLB_sv_ProjectName}
  chmod -R 755 "${sv_RootDirPath}"/usr/local/${GLB_sv_ProjectName}

  # -- Create the LaunchDaemon
  cat << EOF > ${sv_ThisScriptTempDirPath}/${GLB_sv_ProjectSignature}.CheckHooks.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>${GLB_sv_ProjectSignature}.CheckHooks</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/${GLB_sv_ProjectName}/scripts/CheckHooks</string>
	</array>
	<key>WatchPaths</key>
	<array>
		<string>/private/var/root/Library/Preferences/com.apple.loginwindow.plist</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF
  cp ${sv_ThisScriptTempDirPath}/${GLB_sv_ProjectSignature}.CheckHooks.plist "${sv_RootDirPath}"/Library/LaunchDaemons/
  chown root:wheel "${sv_RootDirPath}"/Library/LaunchDaemons/${GLB_sv_ProjectSignature}.CheckHooks.plist
  chmod 644 "${sv_RootDirPath}"/Library/LaunchDaemons/${GLB_sv_ProjectSignature}.CheckHooks.plist

  if test -z "${sv_RootDirPath}"
  then
    "${GLB_sv_ProjectDirPath}/lib/PostInstall"
    iv_Error="$?"
    if [ "${iv_Error}" != "0" ]
    then
      GLB_nf_logmessage "NOTE: cancelling install of ${GLB_sv_ProjectName}."
      exit ${iv_Error}
    fi
  fi

fi
