file(MAKE_DIRECTORY "${SM_SRC_DIR}/generated")

# Keep the module path local for easier grabbing.
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# Main project is below.

include(CMakeData-arch.cmake)
include(CMakeData-rage.cmake)
include(CMakeData-os.cmake)
include(CMakeData-actor.cmake)
include(CMakeData-screen.cmake)
include(CMakeData-data.cmake)
include(CMakeData-gtk.cmake)
include(CMakeData-file-types.cmake)
include(CMakeData-globals.cmake)
include(CMakeData-singletons.cmake)

list(APPEND SMDATA_ALL_FILES_SRC
            ${SMDATA_GLOBAL_FILES_SRC}
            ${SMDATA_GLOBAL_SINGLETON_SRC}
            ${SMDATA_ALL_ACTORS_SRC}
            ${SMDATA_ALL_ARCH_SRC}
            ${SMDATA_ALL_DATA_SRC}
            ${SMDATA_ALL_RAGE_SRC}
            ${SMDATA_ALL_SCREENS_SRC}
            ${SMDATA_OS_SRC}
            ${SMDATA_FILE_TYPES_SRC})
list(APPEND SMDATA_ALL_FILES_HPP
            ${SMDATA_GLOBAL_FILES_HPP}
            ${SMDATA_GLOBAL_SINGLETON_HPP}
            ${SMDATA_ALL_ACTORS_HPP}
            ${SMDATA_ALL_ARCH_HPP}
            ${SMDATA_ALL_DATA_HPP}
            ${SMDATA_ALL_RAGE_HPP}
            ${SMDATA_ALL_SCREENS_HPP}
            ${SMDATA_OS_HPP}
            ${SMDATA_FILE_TYPES_HPP})

if(NOT APPLE)
  list(APPEND SMDATA_ALL_FILES_SRC "Main.cpp")
  source_group("" FILES "Main.cpp")
endif()

set(SM_NAME_RELEASE "StepMania")
set(SM_NAME_DEBUG "StepMania-debug")
set(SM_NAME_MINSIZEREL "StepMania-min-size")
set(SM_NAME_RELWITHDEBINFO "StepMania-release-symbols")

# TODO: Make this actually be data and not an executable.
if(APPLE)
  # Configure generated files here.
  configure_file("${SM_XCODE_DIR}/Info.plist.in.xml"
                "${SM_XCODE_DIR}/Info.StepMania.plist")
  configure_file("${SM_XCODE_DIR}/plistHelper.in.hpp"
                "${SM_XCODE_DIR}/plistHelper.hpp")

  set(MACOSX_BUNDLE_BUNDLE_NAME ${SM_EXE_NAME})
  add_executable("${SM_EXE_NAME}"
                 MACOSX_BUNDLE
                 ${SMDATA_ALL_FILES_SRC}
                 ${SMDATA_ALL_FILES_HPP})
  set_target_properties("${SM_EXE_NAME}" PROPERTIES MACOSX_BUNDLE TRUE)
else()
  add_executable("${SM_EXE_NAME}" ${SMDATA_ALL_FILES_SRC}
                 ${SMDATA_ALL_FILES_HPP})
endif()

target_precompile_headers("${SM_EXE_NAME}"
  PRIVATE
    global.h)

# Providing a CACHE option for this, since this is a nice convenience that
# some users might want.
#
# Default is ON, which means the installation should be self-contained. This
# is because StepMania is general software that should "just work" and be easy
# to setup. It's not a C/C++ library or executable that is actively trying to
# fail if it is badly configured.
#
# However, there should always be an option to turn this OFF, since in some
# situations consumer code might want to e.g. provide all of the dependencies
# themselves, such as in the case of a package manager.
option(exe_INSTALL_RUNTIME_DEPENDENCIES
  "If ON, install any runtime dependency that this executable depends on along with it."
  ON)
if (exe_INSTALL_RUNTIME_DEPENDENCIES)
  # On Windows, DLLs need to be in the same directory as the executable for it
  # to run. This is not a perfect solution because 1) this is inconsistent with
  # what happens on Unix-like systems (where the shared libraries would need to
  # be installed in one of the directories specified in the RPATH), 2) a
  # package manager like vcpkg would want to manage the dependencies themselves
  # (that's what they are there for right?), and 3) because it's possible that
  # something else provides the same DLL file, so packaging the DLLs would mean
  # that the DLLs that end up in the final installation tree would depend on
  # installation order, which sounds pretty bad.
  install(FILES "$<TARGET_RUNTIME_DLLS:${SM_EXE_NAME}>"
	  DESTINATION bin)
endif()

set_target_properties("${SM_EXE_NAME}"
                      PROPERTIES OUTPUT_NAME
                                 "${SM_NAME_RELEASE}"
                                 RELEASE_OUTPUT_NAME
                                 "${SM_NAME_RELEASE}"
                                 DEBUG_OUTPUT_NAME
                                 "${SM_NAME_DEBUG}"
                                 MINSIZEREL_OUTPUT_NAME
                                 "${SM_NAME_MINSIZEREL}"
                                 RELWITHDEBINFO_OUTPUT_NAME
                                 "${SM_NAME_RELWITHDEBINFO}")

# Required for usage of tomcrypt and tommath.
sm_add_compile_definition("${SM_EXE_NAME}" LTC_NO_ASM)
sm_add_compile_definition("${SM_EXE_NAME}" CMAKE_POWERED)

# Compilation flags per project here.
sm_add_compile_definition("${SM_EXE_NAME}" $<$<CONFIG:Debug>:DEBUG>)
sm_add_compile_definition("${SM_EXE_NAME}" $<$<CONFIG:Release>:RELEASE>)
sm_add_compile_definition("${SM_EXE_NAME}" $<$<CONFIG:MinSizeRel>:MINSIZEREL>)
sm_add_compile_definition("${SM_EXE_NAME}"
                          $<$<CONFIG:RelWithDebInfo>:RELWITHDEBINFO>)

set_target_properties("${SM_EXE_NAME}"
                      PROPERTIES OUTPUT_NAME_DEBUG
                                 "${SM_NAME_DEBUG}"
                                 OUTPUT_NAME_MINSIZEREL
                                 "${SM_NAME_MINSIZEREL}"
                                 OUTPUT_NAME_RELWITHDEBINFO
                                 "${SM_NAME_RELWITHDEBINFO}")

# Libraries & targets that are optional but were found and should be linked`
# against. E.g., a library may be required only on Linux but not on Windows or
# MacOS.
set(SM_EXE_OPTIONAL_LINK_LIBS_PRIVATE)

if(WIN32)
  sm_add_compile_definition("${SM_EXE_NAME}" WINDOWS)
  sm_add_compile_definition("${SM_EXE_NAME}" _WINDOWS) # TODO: Remove this
                                                       # potential duplicate.
  sm_add_compile_definition("${SM_EXE_NAME}" _CRT_SECURE_NO_WARNINGS)
  sm_add_compile_definition("${SM_EXE_NAME}" _WINSOCK_DEPRECATED_NO_WARNINGS)

  set_target_properties("${SM_EXE_NAME}"
                        PROPERTIES RUNTIME_OUTPUT_DIRECTORY
                                   "${SM_PROGRAM_DIR}"
                                   RUNTIME_OUTPUT_DIRECTORY_RELEASE
                                   "${SM_PROGRAM_DIR}"
                                   RUNTIME_OUTPUT_DIRECTORY_DEBUG
                                   "${SM_PROGRAM_DIR}"
                                   RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL
                                   "${SM_PROGRAM_DIR}"
                                   RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO
                                   "${SM_PROGRAM_DIR}")

elseif(APPLE)
  sm_add_compile_definition("${SM_EXE_NAME}" BACKTRACE_METHOD_X86_DARWIN)
  sm_add_compile_definition("${SM_EXE_NAME}" MACOSX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
  set_target_properties(
    "${SM_EXE_NAME}"
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY
      "${SM_RESOURCE_DIR}"
      RUNTIME_OUTPUT_DIRECTORY_RELEASE
      "${SM_RESOURCE_DIR}"
      RUNTIME_OUTPUT_DIRECTORY_DEBUG
      "${SM_RESOURCE_DIR}"
      RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL
      "${SM_RESOURCE_DIR}"
      RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO
      "${SM_RESOURCE_DIR}"
      MACOSX_BUNDLE_INFO_PLIST
      "${SM_XCODE_DIR}/Info.StepMania.plist"
      XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY
      "libc++"
      XCODE_ATTRIBUTE_INFOPLIST_FILE
      "${SM_XCODE_DIR}/Info.StepMania.plist"
      XCODE_ATTRIBUTE_INFOPLIST_PREPROCESS
      "YES"
      XCODE_ATTRIBUTE_INFOPLIST_PREPROCESSOR_DEFINITIONS[variant=Release]
      "RELEASE"
      XCODE_ATTRIBUTE_INFOPLIST_PREPROCESSOR_DEFINITIONS[variant=Debug]
      "DEBUG"
      XCODE_ATTRIBUTE_INFOPLIST_PREPROCESSOR_DEFINITIONS[variant=MinSizeRel]
      "MINSIZEREL"
      XCODE_ATTRIBUTE_INFOPLIST_PREPROCESSOR_DEFINITIONS[variant=RelWithDebInfo]
      "RELWITHDEBINFO"
      XCODE_ATTRIBUTE_INFOPLIST_PREFIX_HEADER
      "${SM_XCODE_DIR}/plistHelper.hpp"
      XCODE_ATTRIBUTE_GCC_PREFIX_HEADER
      "${CMAKE_CURRENT_SOURCE_DIR}/archutils/Darwin/StepMania.pch"
      XCODE_ATTRIBUTE_GCC_ENABLE_CPP_EXCEPTIONS
      "NO"
      XCODE_ATTRIBUTE_LIBRARY_SEARCH_PATHS
      "${SM_XCODE_DIR}/Libraries")
      # XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS
      # "${SM_XCODE_DIR}/StepMania.entitlements")
      
  set(APPLE_BUNDLE_RESOURCES
    "${SM_RESOURCE_DIR}/Announcers"
    "${SM_RESOURCE_DIR}/BackgroundEffects"
    "${SM_RESOURCE_DIR}/BackgroundTransitions"
    "${SM_RESOURCE_DIR}/BGAnimations"
    "${SM_RESOURCE_DIR}/Characters"
    "${SM_RESOURCE_DIR}/Courses"
    "${SM_RESOURCE_DIR}/Data"
    "${SM_RESOURCE_DIR}/NoteSkins"
    "${SM_RESOURCE_DIR}/Scripts"
    "${SM_RESOURCE_DIR}/Songs"
    "${SM_RESOURCE_DIR}/Themes"
  )
  
  target_sources("${SM_EXE_NAME}" PUBLIC ${APPLE_BUNDLE_RESOURCES})
  set_source_files_properties(${APPLE_BUNDLE_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

  sm_add_compile_definition("${SM_EXE_NAME}" _XOPEN_SOURCE)

  if(${HAS_FFMPEG})
    sm_add_compile_definition("${SM_EXE_NAME}" HAVE_FFMPEG)
  endif()

  if(CMAKE_BUILD_TYPE EQUAL "Debug")
    set(SM_APP_RELEASE_NAME "${SM_NAME_DEBUG}")
  elseif(CMAKE_BUILD_TYPE EQUAL "MinSizeRel")
    set(SM_APP_RELEASE_NAME "${SM_NAME_MINSIZEREL}")
  elseif(CMAKE_BUILD_TYPE EQUAL "RelWithDebInfo")
    set(SM_APP_RELEASE_NAME "${SM_NAME_RELWITHDEBINFO}")
  else()
    set(SM_APP_RELEASE_NAME "${SM_NAME_RELEASE}")
  endif()
  if(WITH_FULL_RELEASE)
    string(CONCAT SM_NAME_VERSION
                  "${SM_EXE_NAME}"
                  "-"
                  "${SM_VERSION_TRADITIONAL}")
    set(SM_DMG_VERSION "${SM_VERSION_TRADITIONAL}")
  else()
    string(CONCAT SM_NAME_VERSION
                  "${SM_EXE_NAME}"
                  "-"
                  "${SM_VERSION_FULL}")
    set(SM_DMG_VERSION "${SM_VERSION_FULL}")
  endif()
  set(SM_DMG_RELEASE_NAME "${SM_NAME_VERSION}-mac.dmg")

  add_custom_target(dmg
                    COMMAND pushd ${SM_RESOURCE_DIR}\; mkdir -p dmgtmpdir\; cd
                            dmgtmpdir\; mkdir -p ${SM_NAME_VERSION}\; cd
                            ${SM_NAME_VERSION}\; mkdir -p ${SM_NAME_VERSION}\; cd
                            ${SM_NAME_VERSION}\; cp -R
                            "${SM_RESOURCE_DIR}/Announcers" .\; cp -R
                            "${SM_RESOURCE_DIR}/BackgroundEffects" .\; cp -R
                            "${SM_RESOURCE_DIR}/BackgroundTransitions" .\; cp -R
                            "${SM_RESOURCE_DIR}/BGAnimations" .\; cp -R
                            "${SM_RESOURCE_DIR}/Characters" .\; cp -R
                            "${SM_RESOURCE_DIR}/Courses" .\; cp -R
                            "${SM_RESOURCE_DIR}/Data" .\; cp -R
                            "${SM_RESOURCE_DIR}/Docs" .\; cp -R
                            "${SM_RESOURCE_DIR}/Manual" .\; cp -R
                            "${SM_RESOURCE_DIR}/NoteSkins" .\; cp -R
                            "${SM_RESOURCE_DIR}/Scripts" .\; cp -R
                            "${SM_RESOURCE_DIR}/Songs" .\; cp -R
                            "${SM_RESOURCE_DIR}/Themes" .\; cp -R
                            "${SM_RESOURCE_DIR}/${SM_APP_RELEASE_NAME}.app" .\; cd
                            ${SM_RESOURCE_DIR}\; hdiutil create
                            "${SM_DMG_RELEASE_NAME}" -VOLNAME
                            "StepMania ${SM_DMG_VERSION}" -SRCFOLDER
                            "dmgtmpdir/${SM_NAME_VERSION}/" -OV\; rm -fR
                            dmgtmpdir\; popd\;)

  # Add the ability to copy the resource file.
  add_custom_command(TARGET "${SM_EXE_NAME}" POST_BUILD
                     COMMAND ${CMAKE_COMMAND} -E make_directory
                             "$<TARGET_FILE_DIR:StepMania>/../Resources"
                     COMMAND ${CMAKE_COMMAND} -E copy
                             "${SM_XCODE_DIR}/smicon.icns"
                             "$<TARGET_FILE_DIR:StepMania>/../Resources/"
                     COMMAND ${CMAKE_COMMAND} -E copy
                             "${SM_XCODE_DIR}/Hardware.plist"
                             "$<TARGET_FILE_DIR:StepMania>/../Resources/")
else() # Linux
  set_target_properties("${SM_EXE_NAME}"
                        PROPERTIES RUNTIME_OUTPUT_DIRECTORY
                                   "${SM_RESOURCE_DIR}"
                                   RUNTIME_OUTPUT_DIRECTORY_RELEASE
                                   "${SM_RESOURCE_DIR}"
                                   RUNTIME_OUTPUT_DIRECTORY_DEBUG
                                   "${SM_RESOURCE_DIR}"
                                   RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL
                                   "${SM_RESOURCE_DIR}"
                                   RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO
                                   "${SM_RESOURCE_DIR}")

  if(${WITH_CRASH_HANDLER})
    sm_add_compile_definition("${SM_EXE_NAME}" CRASH_HANDLER)
    if(LINUX)
      # used only in the ArchHooks_Unix.cpp file
      if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86" OR CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        sm_add_compile_definition("${SM_EXE_NAME}" BACKTRACE_METHOD_X86_LINUX)
        sm_add_compile_definition("${SM_EXE_NAME}"
                                BACKTRACE_METHOD_TEXT="x86 custom backtrace")
      else()
        sm_add_compile_definition("${SM_EXE_NAME}"
                                BACKTRACE_METHOD_TEXT="no backtrace")
      endif()
      sm_add_compile_definition(
        "${SM_EXE_NAME}" BACKTRACE_LOOKUP_METHOD_TEXT="backtrace_symbols")
      if(${DL_FOUND})
        sm_add_compile_definition("${SM_EXE_NAME}"
                                  BACKTRACE_LOOKUP_METHOD_DLADDR)
      else()
        sm_add_compile_definition("${SM_EXE_NAME}"
                                  BACKTRACE_LOOKUP_METHOD_BACKTRACE_SYMBOLS)
      endif()
    endif()
  endif()
  if(${HAS_PTHREAD})
    sm_add_compile_definition("${SM_EXE_NAME}" HAVE_LIBPTHREAD)

    message("Host processor is ${CMAKE_SYSTEM_PROCESSOR}")
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
      message("Host processor is 64bit X86")
      sm_add_compile_definition("${SM_EXE_NAME}" CPU_X86_64)
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86"
           OR CMAKE_SYSTEM_PROCESSOR MATCHES "i686")
      message("Host processor is 32bit X86")
      sm_add_compile_definition("${SM_EXE_NAME}" CPU_X86)
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
      message("Host processor is 64bit ARM")
      sm_add_compile_definition("${SM_EXE_NAME}" CPU_AARCH64)
    else()
      message("Unrecognized host processor type")
    endif()
  endif()
  if(${HAS_FFMPEG})
    sm_add_compile_definition("${SM_EXE_NAME}" HAVE_FFMPEG)
  endif()
  if(${HAS_XRANDR})
    sm_add_compile_definition("${SM_EXE_NAME}" HAVE_XRANDR)
  endif()
  if(${HAS_Xtst})
    sm_add_compile_definition("${SM_EXE_NAME}" HAVE_LIBXTST)
  endif()
  if(${HAS_XINERAMA})
    sm_add_compile_definition("${SM_EXE_NAME}" HAVE_XINERAMA)
  endif()

  if(BSD)
    sm_add_compile_definition("${SM_EXE_NAME}" BSD)
  endif()

  if(GTK3_FOUND)
    sm_add_compile_definition("${SM_EXE_NAME}" HAVE_GTK)
    list(APPEND SM_EXE_OPTIONAL_LINK_LIBS_PRIVATE GTK3::GTK3)
  endif()

  sm_add_compile_definition("${SM_EXE_NAME}" UNIX)
  if("${CMAKE_SYSTEM}" MATCHES "Linux")
    sm_add_compile_definition("${SM_EXE_NAME}" LINUX)
  endif()
endif()

set_property(TARGET "${SM_EXE_NAME}" PROPERTY FOLDER "Internal Libraries")

if(UNIX)
  list(APPEND SM_EXE_OPTIONAL_LINK_LIBS_PRIVATE
    Iconv::Iconv)
endif()

if(WIN32)
  list(APPEND SMDATA_LINK_LIB
              "dbghelp.lib"
              "setupapi.lib"
              "hid.lib")

  sm_add_link_flag("${SM_EXE_NAME}" "/LIBPATH:\"${SM_EXTERN_DIR}/ffmpeg/${SM_WIN32_ARCH}/lib\"")
  sm_add_link_flag("${SM_EXE_NAME}"
                   "/LIBPATH:\"${SM_SRC_DIR}/archutils/Win32/ddk/${SM_WIN32_ARCH}\"")
  sm_add_link_flag("${SM_EXE_NAME}" "/ERRORREPORT:SEND")
  sm_add_link_flag("${SM_EXE_NAME}" "/SAFESEH:NO")
  sm_add_link_flag("${SM_EXE_NAME}" "/NOLOGO")
  sm_add_link_flag("${SM_EXE_NAME}" "/NODEFAULTLIB:wininet.lib")
  sm_add_link_flag("${SM_EXE_NAME}" "/NODEFAULTLIB:msimg32.lib")
  sm_add_link_flag("${SM_EXE_NAME}" "/NODEFAULTLIB:libci.lib")
  set_target_properties("${SM_EXE_NAME}"
                        PROPERTIES LINK_FLAGS_DEBUG "/NODEFAULTLIB:msvcrt.lib")
  set_target_properties("${SM_EXE_NAME}"
                        PROPERTIES LINK_FLAGS_RELEASE "/SUBSYSTEM:WINDOWS")
  set_target_properties("${SM_EXE_NAME}"
                        PROPERTIES LINK_FLAGS_MINSIZEREL "/SUBSYSTEM:WINDOWS")

elseif(APPLE)
  # The following were removed from SMDATA_LINK_LIB to "match" StepMania's
  # pbxproj. ${MAC_FRAME_APPKIT} ${MAC_FRAME_FOUNDATION} "ffmpeg"

  list(INSERT SMDATA_LINK_LIB
              0
              ${MAC_FRAME_ACCELERATE}
              ${MAC_FRAME_CARBON}
              ${MAC_FRAME_COCOA}
              ${MAC_FRAME_IOKIT}
              ${MAC_FRAME_OPENGL}
              ${MAC_FRAME_COREFOUNDATION}
              ${MAC_FRAME_AUDIOTOOLBOX}
              ${MAC_FRAME_AUDIOUNIT}
              ${MAC_FRAME_COREAUDIO}
              ${MAC_FRAME_CORESERVICES}
              ${MAC_FRAME_SYSTEM})
else() # Unix / Linux TODO: Remember to find and locate the zip archive files.
  if(HAS_FFMPEG)
    if(Va_FOUND)
      list(APPEND SMDATA_LINK_LIB ${Va_LIBRARY})
    endif()
  endif()

  if(${DL_FOUND})
    list(APPEND SMDATA_LINK_LIB ${DL_LIBRARIES})
  endif()

  list(APPEND SMDATA_LINK_LIB "${OPENGL_LIBRARY}")
  list(APPEND SMDATA_LINK_LIB "${CMAKE_THREAD_LIBS_INIT}")

  if(HAS_ALSA)
    list(APPEND SM_EXE_OPTIONAL_LINK_LIBS_PRIVATE ALSA::ALSA)
  endif()

  if(HAS_JACK)
    list(APPEND SMDATA_LINK_LIB ${JACK_LIBRARIES})
  endif()

  if(HAS_OSS)
    # No mention of OSS libraries.
    sm_add_compile_definition("${SM_EXE_NAME}" "HAVE_OSS_VERSION=1")
  endif()

  if(X11_FOUND)
    list(APPEND SMDATA_LINK_LIB
      # Needed by X11 libraries, so needs to come first
      ${Xrandr_LIBRARIES}
      ${X11_LIBRARIES})
  endif()

  if(SDL2_FOUND)
    list(APPEND SMDATA_LINK_LIB ${SDL2_LIBRARY})
    sm_add_compile_definition("${SM_EXE_NAME}" HAVE_SDL)
  endif()

  if(Xtst_FOUND)
    list(APPEND SMDATA_LINK_LIB ${Xtst_LIBRARY})
  endif()

  list(APPEND SMDATA_LINK_LIB ${XINERAMA_LIBRARIES})

  list(REMOVE_DUPLICATES SMDATA_LINK_LIB)
endif()

target_include_directories("${SM_EXE_NAME}"
  PRIVATE
    ${FFMPEG_INCLUDE_DIRS})
target_link_directories("${SM_EXE_NAME}"
  PRIVATE
    ${FFMPEG_LIBRARY_DIRS})
target_link_libraries("${SM_EXE_NAME}"
  PRIVATE
    ${SMDATA_LINK_LIB}
    ${SM_EXE_OPTIONAL_LINK_LIBS_PRIVATE}
    BZip2::BZip2
    ${FFMPEG_LIBRARIES}
    GLEW::GLEW
    JPEG::JPEG
    JsonCpp::JsonCpp
    Mad::Mad
    Microsoft.GSL::GSL
    Ogg::ogg
    PNG::PNG
    Vorbis::vorbis
    Vorbis::vorbisfile
    prj2::lua
    prj2::lib2
    unofficial::pcre::pcre
    unofficial::pcre::pcre16
    unofficial::pcre::pcre32
    unofficial::pcre::pcrecpp
    ZLIB::ZLIB)
if(WIN32)
  # When compiling in C++ >= c++17, we have an ambiguity
  # between std::byte (introduced in C++17) and ::byte of the Windows header
  # "rpcndr.h". Defining _HAS_STD_BYTE=0 removes ::byte from rpcndr.h .
  # https://studiofreya.com/2018/01/06/visual-studio-2017-with-cpp17-and-boost/#stdbyte-ambiguous-symbol-and-rpcndr.h
  target_compile_definitions("${SM_EXE_NAME}"
    PRIVATE "_HAS_STD_BYTE=0")
endif()
set_target_properties("${SM_EXE_NAME}" PROPERTIES
  # The StepMania executable defines symbols like 'CreateSurface' which
  # are needed by shared libraries like 'GtkModule.so', so we have to
  # add this property (similar to linker's "-export-dynamic" flag) to make
  # the executable export its symbols so that the shared libraries can find
  # them. See:
  # https://stackoverflow.com/a/3623388/2252948
  ENABLE_EXPORTS ON)
list(APPEND SM_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
            "${SM_SRC_DIR}/generated")
if(NOT APPLE)
  if(NOT MSVC)
    if(X11_FOUND)
      list(APPEND SM_INCLUDE_DIRS "${X11_INCLUDE_DIR}")
    endif()
    if(PCRE_FOUND)
      list(APPEND SM_INCLUDE_DIRS "${PCRE_INCLUDE_DIR}")
    endif()
    if(DL_FOUND)
      list(APPEND SM_INCLUDE_DIRS "${DL_INCLUDE_DIR}")
    endif()
  endif()
else()
  list(APPEND SM_INCLUDE_DIRS "archutils/Unix")
endif()

target_include_directories("${SM_EXE_NAME}" PUBLIC ${SM_INCLUDE_DIRS})

if(WIN32)
  set(SM_INSTALL_DESTINATION ".")
else()
  # On Linux and MacOS, 'Songs/' and other directories need to be within the
  # directory where the executable is; see the
  # "ArchHooks::MountInitialFilesystems()" functions within the files
  # ArchHooks_MacOSX.mm and ArchHooks_Unix.cpp.
  set(SM_INSTALL_DESTINATION bin)
endif()

if(WIN32)
  set(SM_FULL_INSTALLATION_PATH_LIST "${SM_INSTALL_DESTINATION}" "bin")
  sm_join("${SM_FULL_INSTALLATION_PATH_LIST}" "/" SM_FULL_INSTALLATION_PATH)
endif()
install(TARGETS "${SM_EXE_NAME}"
  DESTINATION "${SM_FULL_INSTALLATION_PATH}"
  # There is another option, RUNTIME_DEPENDENCIES, which directly copies the
  # dependencies (e.g. used shared libraries) without having to create a
  # dependency set, and which is mutually exclusive to RUNTIME_DEPENDENCY_SET.
  # That option is easier to install the dependencies with, since it doesn't
  # additionally require using install(RUNTIME_DEPENDENCY_SET).
  #
  # However, using RUNTIME_DEPENDENCY_SET instead means it's easier to let the
  # user choose (usually via CMake cache variables) whether to install the
  # runtime dependencies or not. Many projects let the user choose because,
  # in some situations, the user might prefer to provide them.
  #
  # This is, in my experience, either because the project doesn't want to make
  # assumptions about the user's setup, or for some licensing reasons. E.g., in
  # practice, LGPL-3.0 allows the project to be used in closed source only if
  # the LGPL-3.0 libraries are built as shared libraries and the project gives
  # instructions on how a user can replace the version of these shared
  # libraries. In a situation like this, the closed-source project that uses
  # this library might choose not to provide these runtime libraries and
  # therefore have a CMake build which chooses not to.
  RUNTIME_DEPENDENCY_SET sm_rt_dependencies)
if(exe_INSTALL_RUNTIME_DEPENDENCIES)
  # Windows has to be treated specifically: for some reason,
  # install(RUNTIME_DEPENDENCY_SET) causes hundreds of runtime dependencies
  # that are acually system libraries to not be found, like:
  # - AzureAttestManager.dll
  # - api-ms-win-appmodel-advertisingid-l1-1-0.dll
  # - ext-ms-mf-pal-l2-1-0.dll
  #
  # See: https://discourse.cmake.org/t/get-runtime-dependencies-has-difficulties-with-windows-api-sets/1768
  if(WIN32)
    # Not sure where in this buildsystem we cause StepMania.exe to need the
    # DLL versions of the FFPMEG libraries, but CMake is unaware of this and
    # therefore does not install them. Until we figure this out, we'll have
    # to install the libraries manually.
    install(FILES
      "${SM_PROGRAM_DIR}/avcodec-60.dll"
      "${SM_PROGRAM_DIR}/avformat-60.dll"
      "${SM_PROGRAM_DIR}/avutil-58.dll"
      "${SM_PROGRAM_DIR}/swresample-4.dll"
      "${SM_PROGRAM_DIR}/swscale-7.dll"
      "${SM_PROGRAM_DIR}/libpng16.dll"
      DESTINATION bin)
  else()
    install(RUNTIME_DEPENDENCY_SET sm_rt_dependencies
      # https://discourse.cmake.org/t/cmake-error-at-cmake-install-cmake-file-multiple-conflicting-paths-found-for/8950/2?u=anthonyd973
      POST_EXCLUDE_REGEXES "${CMAKE_INSTALL_PREFIX}"
      RUNTIME DESTINATION bin
      LIBRARY DESTINATION lib
      COMPONENT prj2-rtdeps)
  endif()
endif()
if(NOT APPLE)
  if(UNIX OR LINUX)
    install(FILES "${SM_RESOURCE_DIR}/GtkModule.so"
            DESTINATION "${SM_INSTALL_DESTINATION}")
  endif()
  install(DIRECTORY "${SM_RESOURCE_DIR}/Announcers"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/BGAnimations"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/Themes"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/Characters"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/Scripts"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/Courses"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/BackgroundEffects"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/Data"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/BackgroundTransitions"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/Docs"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/NoteSkins"
          DESTINATION "${SM_INSTALL_DESTINATION}")
  install(DIRECTORY "${SM_RESOURCE_DIR}/Songs/Kevin MacLeod"
          DESTINATION "${SM_INSTALL_DESTINATION}/Songs")
  install(FILES "${SM_RESOURCE_DIR}/Songs/instructions.txt"
          DESTINATION "${SM_INSTALL_DESTINATION}/Songs")
endif()

# Properties used only when building shared libraries.
#
# For Apple and Unix-like platforms (although maybe not Cygwin?), an RPATH
# metadata variable can be set inside the linked executable/library to specify
# a search path for dependant shared libraries. However, this cannot be a
# relative path because it would be relative to where the executable is run
# from, which isn't what we want. So instead we specify a special string to
# make the path relative to where the executable is located.
#
# Note that we use CACHE variables here. This is to allow whoever is
# configuring the CMake build to override the values if they want to, while
# still providing a sane default.
if(APPLE)
  # There is also "@rpath" that is a bit more flexible, but really the equivalent
  # of "$ORIGIN" for Unix is "@executable_path".
  set("SM_EXE_INSTALL_RPATH" @executable_path/../lib CACHE STRING "RPATH to use for this target.")
elseif(UNIX AND NOT CYGWIN)
  # "$ORIGIN" is a special string that means "the directory containing the
  # executable that is running".
  set("SM_EXE_INSTALL_RPATH" $ORIGIN/../lib CACHE STRING "RPATH to use for this target.")
elseif(WIN32)
  # DLL platforms don't support RPATH.
  set("SM_EXE_INSTALL_RPATH" "")
else()
  # Nothing to do
endif()

set_target_properties("${SM_EXE_NAME}"
  PROPERTIES
    INSTALL_RPATH "${SM_EXE_INSTALL_RPATH}")
