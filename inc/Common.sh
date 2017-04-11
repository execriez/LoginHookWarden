#!/bin/bash
#
# Short:    Common routines (shell)
# Version:  1.0.3
# Modified: 11-Apr-2017
#

# Only run the code if it hasn't already been run
if test -z "${GLB_sv_ProjectSignature}"
then

  # 'CommonLib' defines the following globals:
  #
  #  GLB_sv_ThisScriptFilePath                       - Full source path of running script
  #  GLB_sv_ThisScriptDirPath                        - Directory location of running script
  #  GLB_sv_ThisScriptFileName                       - filename of running script
  #  GLB_sv_ThisScriptName                           - Filename without extension
  #  GLB_iv_ThisScriptPID                            - Process ID of running script
  #
  #  GLB_sv_ThisUserName                             - The name of the user that is running this script
  #  GLB_iv_ThisUserID                               - The user ID of the user that is running this script
  #  GLB_bv_ThisUserIsAdmin                          - Whether the user running this script is an admin ("true" or "false")
  #
  # 'CommonLib' defines the following functions:
  #
  #  GLB_sf_LogLevel <loglevel>                      - Convert log level integer into log level text
  #  GLB_nf_logmessage <loglevel> <messagetxt>       - Output message text to the log file
  #
  #  GLB_if_GetPlistArraySize <plistfile> <property> - Get an array property size from a plist file
  #
  #  Key:
  #    GLB_ - global variable/function
  #
  #    bv_  - string variable with the values "true" or "false"
  #    iv_  - integer variable
  #    sv_  - string variable
  #
  #    nf_  - null function    (doesn't return a value)
  #    bf_  - boolean function (returns string values "true" or "false"
  #    if_  - integer function (returns an integer value)
  #    sf_  - string function  (returns a string value)

  # ---

  # Include the contants, only if they are not already loaded
  if test -z "${GLB_sv_ProjectName}"
  then
    . "${GLB_sv_ProjectDirPath}/inc/Constants.sh"
  fi

  # ---

  # Convert log level integer into log level text
  GLB_sf_LogLevel()   # loglevel
  {  
    local iv_LogLevel
    local sv_LogLevel
  
    iv_LogLevel=${1}
  
    case ${iv_LogLevel} in
    0)
      sv_LogLevel="Emergency"
      ;;
    
    1)
      sv_LogLevel="Alert"
      ;;
    
    2)
      sv_LogLevel="Critical"
      ;;
    
    3)
      sv_LogLevel="Error"
      ;;
    
    4)
      sv_LogLevel="Warning"
      ;;
    
    5)
    sv_LogLevel="Notice"
    ;;
    
    6)
      sv_LogLevel="Information"
      ;;
    
    7)
      sv_LogLevel="Debug"
      ;;
    
    *)
      sv_LogLevel="Unknown"
      ;;
    
    esac
  
    echo ${sv_LogLevel}
  }

  # Save a message to the log file
  GLB_nf_logmessage()   # loglevel messagetxt
  {  
    local iv_HalfLen
    local iv_LogLevel
    local sv_Message
    local sv_LogLevel
  
    iv_LogLevel=${1}
    sv_Message="${2}"
      
    if [ ${iv_LogLevel} -le ${GLB_iv_LogLevelTrap} ]
    then
      sv_LogLevel="$(GLB_sf_LogLevel ${iv_LogLevel})"

      # Check if we need to start a new log
      if test -e "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.log"
      then
        if [ $(stat -f "%z" "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.log") -gt ${GLB_iv_MaxLogSizeBytes} ]
        then
          mv -f "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.log" "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.previous.log"
        fi
      fi

      echo "$(date '+%d %b %Y %H:%M:%S') ${GLB_sv_ThisScriptFileName}[${GLB_iv_ThisScriptPID}]: ${sv_LogLevel}: ${sv_Message}"  >> "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.log"
      echo >&2 "$(date '+%d %b %Y %H:%M:%S') ${GLB_sv_ThisScriptFileName}[${GLB_iv_ThisScriptPID}]: ${sv_LogLevel}: ${sv_Message}"
    fi
  }

  GLB_if_GetPlistArraySize()   # plistfile property - given an array property name, returns the size of the array 
  {
    local sv_PlistFilePath
    local sv_PropertyName

    sv_PlistFilePath="${1}"
    sv_PropertyName="${2}"

    /usr/libexec/PlistBuddy 2>/dev/null -c "Print ':${sv_PropertyName}'" "${sv_PlistFilePath}" | grep -E "^ " | grep -E "$(/usr/libexec/PlistBuddy 2>/dev/null -c "Print ':${sv_PropertyName}'" "${sv_PlistFilePath}" | grep -E "^ " | head -n1 | sed "s|\(^[ ]*\)\([^ ]*.*\)|\^\1\\[\^ }\]|")" | wc -l | sed "s|^[ ]*||"
  }

  # -- Get some info about this project

  GLB_sv_ProjectSignature="$(echo ${GLB_sv_ProjectDeveloper}.${GLB_sv_ProjectName} | tr [A-Z] [a-z])"
  GLB_sv_ProjectMajorVersion="$(echo "${GLB_sv_ProjectVersion}" | cut -d"." -f1)"

  GLB_sv_ProjectConfig="/Library/Preferences/SystemConfiguration/${GLB_sv_ProjectSignature}/V${GLB_sv_ProjectMajorVersion}"

  # -- Get some info about this script

  # Get Process ID of this script
  GLB_iv_ThisScriptPID=$$

  # Full source of this script
  GLB_sv_ThisScriptFilePath="${0}"

  # Get dir of this script
  GLB_sv_ThisScriptDirPath="$(dirname "${GLB_sv_ThisScriptFilePath}")"

  # Get filename of this script
  GLB_sv_ThisScriptFileName="$(basename "${GLB_sv_ThisScriptFilePath}")"

  # Filename without extension
  GLB_sv_ThisScriptName="$(echo ${GLB_sv_ThisScriptFileName} | sed 's|\.[^.]*$||')"

  # -- Get some info about the running user

  # Get name of user running this script
  GLB_sv_ThisUserName="$(whoami)"

  # Get ID of user running this script
  GLB_iv_ThisUserID="$(id -u ${GLB_sv_ThisUserName})"

  # Check if the user running this script is an admin (returns "true" or "false")
  if [ "$(dseditgroup -o checkmember -m "${GLB_sv_ThisUserName}" -n . admin | cut -d" " -f1)" = "yes" ]
  then
    GLB_bv_ThisUserIsAdmin="true"
  else
    GLB_bv_ThisUserIsAdmin="false"
  fi

  # ---

  # Set the logging level
  GLB_iv_LogLevelTrap=${GLB_iv_MsgLevelInfo}

  # Decide where the log files go, and create the config directory
  if [ "${GLB_sv_ThisUserName}" = "root" ]
  then
    GLB_sv_ThisUserLogDirPath="/Library/Logs"
    mkdir -p "${GLB_sv_ProjectConfig}"

  else
    GLB_sv_ThisUserLogDirPath=~/Library/Logs
  
  fi

  mkdir -p "${GLB_sv_ThisUserLogDirPath}"

  # ---

fi