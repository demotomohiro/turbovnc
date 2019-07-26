# This file is included from the top-level CMakeLists.txt.  We just store it
# here to avoid cluttering up that file.

if(UNIX AND NOT APPLE)
	set(DEFAULT_PKGNAME ${CMAKE_PROJECT_NAME_LC})
else()
	set(DEFAULT_PKGNAME ${CMAKE_PROJECT_NAME})
endif()
set(PKGNAME ${DEFAULT_PKGNAME} CACHE STRING
	"Distribution package name (default: ${DEFAULT_PKGNAME})")
set(PKGVENDOR "The VirtualGL Project" CACHE STRING
	"Vendor name to be included in distribution package descriptions (default: The VirtualGL Project)")
set(PKGURL "http://www.${CMAKE_PROJECT_NAME}.org" CACHE STRING
	"URL of project web site to be included in distribution package descriptions (default: http://www.${CMAKE_PROJECT_NAME}.org)")
set(PKGEMAIL "information@${CMAKE_PROJECT_NAME}.org" CACHE STRING
	"E-mail of project maintainer to be included in distribution package descriptions (default: information@${CMAKE_PROJECT_NAME}.org")
string(TOLOWER ${PKGNAME} PKGNAME_LC)
set(PKGID "com.virtualgl.${PKGNAME_LC}" CACHE STRING
	"Globally unique package identifier (reverse DNS notation) (default: com.virtualgl.${PKGNAME_LC})")


###############################################################################
# Linux RPM and DEB
###############################################################################

if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND
	(TVNC_BUILDHELPER OR TVNC_BUILDSERVER))

set(RPMARCH ${CMAKE_SYSTEM_PROCESSOR})
if(CPU_TYPE STREQUAL "x86_64")
	set(DEBARCH amd64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "armv7*")
	set(DEBARCH armhf)
elseif(CPU_TYPE STREQUAL "arm64")
	set(DEBARCH ${CPU_TYPE})
elseif(CPU_TYPE STREQUAL "arm")
	set(DEBARCH armel)
elseif(CMAKE_SYSTEM_PROCESSOR_LC STREQUAL "ppc64le")
	set(DEBARCH ppc64el)
else()
	set(DEBARCH ${CMAKE_SYSTEM_PROCESSOR})
endif()
message(STATUS "RPM architecture = ${RPMARCH}, DEB architecture = ${DEBARCH}")

configure_file(release/makerpm.in pkgscripts/makerpm)
configure_file(release/rpm.spec.in pkgscripts/rpm.spec @ONLY)

add_custom_target(rpm sh pkgscripts/makerpm
	SOURCES pkgscripts/makerpm)

configure_file(release/makesrpm.in pkgscripts/makesrpm)

add_custom_target(srpm sh pkgscripts/makesrpm
	SOURCES pkgscripts/makesrpm
	DEPENDS dist)

configure_file(release/makedpkg.in pkgscripts/makedpkg)
configure_file(release/deb-control.in pkgscripts/deb-control)

add_custom_target(deb sh pkgscripts/makedpkg
	SOURCES pkgscripts/makedpkg)

endif() # Linux


###############################################################################
# Windows installer (Inno Setup)
###############################################################################

if(WIN32)

if(BITS EQUAL 64)
	set(INST_NAME ${CMAKE_PROJECT_NAME}-${VERSION}-x64)
	set(INST_DEFS -DWIN64)
else()
	set(INST_NAME ${CMAKE_PROJECT_NAME}-${VERSION}-x86)
endif()

set(INST_DEPENDS java)
if(TVNC_BUILDHELPER)
	set(INST_DEFS ${INST_DEFS} "-DTURBOVNCHELPER")
	set(INST_DEPENDS ${INST_DEPENDS} turbovnchelper)
endif()
if(TVNC_INCLUDEJRE)
	set(INST_DEFS ${INST_DEFS} "-DINCLUDEJRE")
	set(INST_DEPENDS ${INST_DEPENDS} jre)
endif()

if(MSVC_IDE)
	set(INSTALLERDIR ${CMAKE_CFG_INTDIR})
	set(INST_DEFS ${INST_DEFS} "-DBUILDDIR=${INSTALLERDIR}\\")
else()
	set(INSTALLERDIR .)
	set(INST_DEFS ${INST_DEFS} "-DBUILDDIR=")
endif()

configure_file(release/installer.iss.in pkgscripts/installer.iss)

add_custom_target(installer
	iscc -o${INSTALLERDIR} ${INST_DEFS} -F${INST_NAME} pkgscripts/installer.iss
	DEPENDS ${INST_DEPENDS}
	SOURCES pkgscripts/installer.iss)

endif() # WIN32


###############################################################################
# Mac DMG
###############################################################################

if(APPLE AND TVNC_BUILDVIEWER AND TVNC_BUILDHELPER)

set(OSX_APP_CERT_NAME "" CACHE STRING
	"Name of the Developer ID Application certificate (in the macOS keychain) that should be used to sign the TurboVNC Viewer app & DMG.  Leave this blank to generate an unsigned app/DMG.")
set(OSX_INST_CERT_NAME "" CACHE STRING
	"Name of the Developer ID Installer certificate (in the macOS keychain) that should be used to sign the TurboVNC installer package.  Leave this blank to generate an unsigned package.")

string(REGEX REPLACE "/" ":" CMAKE_INSTALL_MACPREFIX ${CMAKE_INSTALL_PREFIX})
string(REGEX REPLACE "^:" "" CMAKE_INSTALL_MACPREFIX
	${CMAKE_INSTALL_MACPREFIX})

set(JVM_RUNTIME_KEY "")
if(TVNC_INCLUDEJRE)
	set(JVM_RUNTIME_KEY "\n\t<key>JVMRuntime</key>\n\t<key>jre</key>")
endif()
set(EAWT_ADD_MODULES "")
if(TVNC_INCLUDEJRE)
	set(EAWT_ADD_MODULES "\n\t\t<string>--add-exports</string>\n\t\t<string>java.desktop/com.apple.eawt=VncViewer</string>")
endif()
configure_file(release/makemacpkg.in pkgscripts/makemacpkg @ONLY)
configure_file(release/makemacapp.in pkgscripts/makemacapp)
configure_file(release/Distribution.xml.in pkgscripts/Distribution.xml)
configure_file(release/Info.plist.in pkgscripts/Info.plist)
configure_file(release/Package.plist.in pkgscripts/Package.plist)
configure_file(release/uninstall.in pkgscripts/uninstall)
configure_file(release/uninstall.applescript.in
	pkgscripts/uninstall.applescript)

add_custom_target(dmg sh pkgscripts/makemacpkg
	SOURCES pkgscripts/makemacpkg)

endif() # APPLE


###############################################################################
# Generic
###############################################################################

add_custom_target(dist
	COMMAND git archive --prefix=${CMAKE_PROJECT_NAME_LC}-${VERSION}/ HEAD |
		gzip > ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME_LC}-${VERSION}.tar.gz
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

configure_file(release/maketarball.in pkgscripts/maketarball)

add_custom_target(tarball sh pkgscripts/maketarball
	SOURCES pkgscripts/maketarball)
