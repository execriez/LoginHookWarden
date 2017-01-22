#!/bin/bash
#
# Short:    Utility script - Build installation package
# Author:   Mark J Swift
# Version:  2.0.1
# Modified: 01-Jan-2017
#
# Called as follows:    
#   MakePackage.command
#

# ---

if_GetPlistArraySize()   # plistfile property - given an array property name, returns the size of the array 
{
  local sv_PlistFilePath
  local sv_PropertyName

  sv_PlistFilePath="${1}"
  sv_PropertyName="${2}"

  /usr/libexec/PlistBuddy 2>/dev/null -c "Print ':${sv_PropertyName}'" "${sv_PlistFilePath}" | grep -E "^ " | grep -E "$(/usr/libexec/PlistBuddy 2>/dev/null -c "Print ':${sv_PropertyName}'" "${sv_PlistFilePath}" | grep -E "^ " | head -n1 | sed "s|\(^[ ]*\)\([^ ]*.*\)|\^\1\\[\^ }\]|")" | wc -l | sed "s|^[ ]*||"
}

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

# Create a temporary directory private to this script
sv_ThisScriptTempDirPath="$(mktemp -dq /tmp/${sv_ThisScriptFileName}-XXXXXXXX)"

# ---

sv_PkgScriptDirPath="${sv_ThisScriptTempDirPath}"/PKG-Scripts
mkdir -p "${sv_PkgScriptDirPath}"

sv_PkgResourceDirPath="${sv_ThisScriptTempDirPath}"/PKG-Resources
mkdir -p "${sv_PkgResourceDirPath}"

sv_PkgRootDirPath="${sv_ThisScriptTempDirPath}"/PKG-Root
mkdir -p "${sv_PkgRootDirPath}"

# ---

# populate the package resource directory
cp -p "${GLB_sv_ProjectDirPath}/images/background.jpg" "${sv_PkgResourceDirPath}/"

# ---

# Create the uninstall package

sv_PkgTitle="${GLB_sv_ProjectName} Uninstaller"
sv_PkgID="${GLB_sv_ProjectSignature}.uninstall"
sv_PkgName="${GLB_sv_ProjectName}-Uninstaller"

# -- Copy the uninstaller
mkdir -p "${sv_PkgScriptDirPath}/lib"
mkdir -p "${sv_PkgScriptDirPath}/util"

cp -p "${GLB_sv_ProjectDirPath}/lib/CommonLib" "${sv_PkgScriptDirPath}/lib/"
cp -p "${GLB_sv_ProjectDirPath}/lib/Constants" "${sv_PkgScriptDirPath}/lib/"
cp -p "${GLB_sv_ProjectDirPath}/util/Uninstall.command" "${sv_PkgScriptDirPath}/util/"

# -- build the preinstall script
cat << 'EOF' > "${sv_PkgScriptDirPath}"/preinstall
#!/bin/bash
"$(dirname "${0}")"/util/Uninstall.command "${2}"
EOF
chmod o+x,g+x,u+x "${sv_PkgScriptDirPath}"/preinstall

# -- create the Welcome text
cat << EOF > "${sv_PkgResourceDirPath}"/Welcome.txt
This package uninstalls ${GLB_sv_ProjectName} and its related resources.

You will be guided through the steps necessary to uninstall this software.
EOF

# -- create the ReadMe text
cp -p "${GLB_sv_ProjectDirPath}/util/Uninstall.txt" "${sv_PkgResourceDirPath}"/ReadMe.txt

# -- build an empty package
pkgbuild --identifier "${sv_PkgID}" --version "${GLB_sv_ProjectVersion}" --nopayload "${sv_ThisScriptTempDirPath}"/${sv_PkgName}.pkg --scripts ${sv_PkgScriptDirPath}
      
# -- Synthesise a temporary distribution.plist file --
productbuild --synthesize --package "${sv_ThisScriptTempDirPath}"/${sv_PkgName}.pkg "${sv_ThisScriptTempDirPath}"/synthdist.plist

# -- add options for title, background, licence & readme --
awk '/<\/installer-gui-script>/ && c == 0 {c = 1; print "<title>'"${sv_PkgTitle}"'</title>\n<background file=\"background.jpg\" mime-type=\"image/jpg\" />\n<welcome file=\"Welcome.txt\"/>\n<readme file=\"ReadMe.txt\"/>"}; {print}' "${sv_ThisScriptTempDirPath}"/synthdist.plist > "${sv_ThisScriptTempDirPath}"/distribution.plist

# -- build the final package --
cd "${sv_ThisScriptTempDirPath}"
productbuild --identifier "${sv_PkgID}" --version "${GLB_sv_ProjectVersion}" --distribution "${sv_ThisScriptTempDirPath}"/distribution.plist --resources "${sv_PkgResourceDirPath}" ~/Desktop/${sv_PkgName}.pkg

# ---

# Create the install package

sv_PkgTitle="${GLB_sv_ProjectName}"
sv_PkgID="${GLB_sv_ProjectSignature}"
sv_PkgName="${GLB_sv_ProjectName}"

# -- Create the main payload
mkdir -p "${sv_PkgRootDirPath}"/Library/LaunchAgents
mkdir -p "${sv_PkgRootDirPath}"/Library/LaunchDaemons
mkdir -p "${sv_PkgRootDirPath}"/usr/local

"${sv_ThisScriptDirPath}/install.command" "${sv_PkgRootDirPath}"

# -- Copy the License text

# populate the package resource directory
cp -p "${GLB_sv_ProjectDirPath}/LICENSE" "${sv_PkgResourceDirPath}"/License.txt

# -- create the Welcome text
cat << EOF > "${sv_PkgResourceDirPath}"/Welcome.txt
${GLB_sv_ProjectName} ${GLB_sv_ProjectVersion}

This package installs ${GLB_sv_ProjectName} and its related resources.

You can read the instructions on-line at https://github.com/execriez/${GLB_sv_ProjectName}/README.md or after installation at /usr/local/${GLB_sv_ProjectName}/README.md

You will be guided through the steps necessary to install this software.
EOF

# -- create the ReadMe text
cp -p "${GLB_sv_ProjectDirPath}/util/Install.txt" "${sv_PkgResourceDirPath}"/ReadMe.txt

# -- Copy required utils
mkdir -p "${sv_PkgScriptDirPath}/lib"
mkdir -p "${sv_PkgScriptDirPath}/util"

cp -p "${GLB_sv_ProjectDirPath}/lib/CommonLib" "${sv_PkgScriptDirPath}/lib/"
cp -p "${GLB_sv_ProjectDirPath}/lib/Constants" "${sv_PkgScriptDirPath}/lib/"
cp -p "${GLB_sv_ProjectDirPath}/lib/PreInstall" "${sv_PkgScriptDirPath}/lib/"
cp -p "${GLB_sv_ProjectDirPath}/lib/PostInstall" "${sv_PkgScriptDirPath}/lib/"
cp -p "${GLB_sv_ProjectDirPath}/util/Uninstall.command" "${sv_PkgScriptDirPath}/util/"

# -- build the preinstall script
cat << 'EOF' > "${sv_PkgScriptDirPath}"/preinstall
#!/bin/bash
"$(dirname "${0}")"/lib/PreInstall "${2}"
EOF
chmod o+x,g+x,u+x "${sv_PkgScriptDirPath}"/preinstall

# -- build the postinstall script
cat << 'EOF' > "${sv_PkgScriptDirPath}"/postinstall
#!/bin/bash
"$(dirname "${0}")"/lib/PostInstall "${2}"
EOF
chmod o+x,g+x,u+x "${sv_PkgScriptDirPath}"/postinstall

# -- build a component plist
pkgbuild --analyze --root ${sv_PkgRootDirPath} "${sv_ThisScriptTempDirPath}"/component.plist

# -- set BundleIsRelocatable to 'false' in the component plist bundles. (We want the install to be put where we say)
iv_BundleCount=$(if_GetPlistArraySize "${sv_ThisScriptTempDirPath}"/component.plist ":")
for (( iv_LoopCount=0; iv_LoopCount<${iv_BundleCount}; iv_LoopCount++ ))
do
  /usr/libexec/PlistBuddy -c "Set ':${iv_LoopCount}:BundleIsRelocatable' 'false'" "${sv_ThisScriptTempDirPath}"/component.plist
done

# -- build a deployment package
pkgbuild --component-plist "${sv_ThisScriptTempDirPath}"/component.plist --root ${sv_PkgRootDirPath} --identifier "${sv_PkgID}" --version "${GLB_sv_ProjectVersion}" --ownership preserve --install-location / "${sv_ThisScriptTempDirPath}"/${sv_PkgName}.pkg --scripts ${sv_PkgScriptDirPath}

# -- Synthesise a temporary distribution.plist file --
productbuild --synthesize --package "${sv_ThisScriptTempDirPath}"/${sv_PkgName}.pkg "${sv_ThisScriptTempDirPath}"/synthdist.plist

# -- add options for title, background, licence & readme --
awk '/<\/installer-gui-script>/ && c == 0 {c = 1; print "<title>'"${sv_PkgTitle}"'</title>\n<background file=\"background.jpg\" mime-type=\"image/jpg\" />\n<welcome file=\"Welcome.txt\"/>\n<license file=\"License.txt\"/>\n<readme file=\"ReadMe.txt\"/>"}; {print}' "${sv_ThisScriptTempDirPath}"/synthdist.plist > "${sv_ThisScriptTempDirPath}"/distribution.plist

# -- build the final package --
cd "${sv_ThisScriptTempDirPath}"
productbuild --identifier "${sv_PkgID}" --version "${GLB_sv_ProjectVersion}" --distribution "${sv_ThisScriptTempDirPath}"/distribution.plist --resources "${sv_PkgResourceDirPath}" ~/Desktop/${sv_PkgName}.pkg

# ---

cd "${sv_ThisScriptDirPath}"

rm -fR "${sv_ThisScriptTempDirPath}"

fi