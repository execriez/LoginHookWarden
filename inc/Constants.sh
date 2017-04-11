#!/bin/bash
#
# Short:    Constants (shell)
# Author:   Mark J Swift
# Version:  1.0.3
# Modified: 11-Apr-2017
#

# Only run the code if it hasn't already been run
if test -z "${GLB_sv_ProjectName}"
then

  # 'Constants' sets the following globals:
  #
  #  GLB_sv_ProjectName                     - Project name (LoginHookWarden)
  #  GLB_sv_ProjectInitials                 - Project initials (LHW)
  #  GLB_sv_ProjectDeveloper                - Project developer (com.github.execriez)
  #  GLB_sv_ProjectVersion                  - Project version (i.e. 1.0.3)
  #
  #  GLB_sv_ProjectSignature                - Project signature (com.github.execriez.LoginHookWarden)
  #  GLB_sv_ProjectMajorVersion             - Project major version (i.e. 1)
  #
  #  GLB_sv_ProjectConfigDirPath                   - Where the projects configs and prefs are stored
  #
  #  GLB_iv_MaxLogSizeBytes                 - How big the log file can get in bytes
  #  GLB_iv_LogLevelTrap                    - The default logging level
  #
  #  GLB_iv_MsgLevelEmerg                   - (0) Emergency, system is unusable
  #  GLB_iv_MsgLevelAlert                   - (1) Alert, should be corrected immediately
  #  GLB_iv_MsgLevelCrit                    - (2) Critical, critical conditions (some kind of failure in the systems primary function)
  #  GLB_iv_MsgLevelErr                     - (3) Error, error conditions
  #  GLB_iv_MsgLevelWarn                    - (4) Warning, may indicate that an error will occur if no action is taken
  #  GLB_iv_MsgLevel                        - (5) Notice, events that are unusual, but not error conditions
  #  GLB_iv_MsgLevelInfo                    - (6) Informational, normal operational messages that require no action
  #  GLB_iv_MsgLevelDebug Debug             - (6) Debug, information useful for developing and debugging
  #
  #  GLB_iv_MaxRunTimeSecs                  - Max time a login/logout hook can run before we quit
  #

  # ---

  GLB_sv_ProjectName="LoginHookWarden"
  GLB_sv_ProjectInitials="LHW"
  GLB_sv_ProjectDeveloper="com.github.execriez"
  GLB_sv_ProjectVersion="1.0.3"

  # ---

  # Set the maximum log size
  GLB_iv_MaxLogSizeBytes=81920

  # ---

  # Set the time that a hook can run before its terminated
  GLB_iv_MaxRunTimeSecs=60

  # --- The following constants never change ---
  
  GLB_iv_MsgLevelEmerg=0
  GLB_iv_MsgLevelAlert=1
  GLB_iv_MsgLevelCrit=2
  GLB_iv_MsgLevelErr=3
  GLB_iv_MsgLevelWarn=4
  GLB_iv_MsgLevelNotice=5
  GLB_iv_MsgLevelInfo=6
  GLB_iv_MsgLevelDebug=7

  # ---

fi