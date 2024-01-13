# Prep options that are needed for each platform.

# Turn this on to set this to a specific release mode.
option(WITH_FULL_RELEASE "Build as a proper, full release." OFF)

# Turn this option off to not use the GPL exclusive components.
option(WITH_GPL_LIBS "Build with GPL libraries." ON)

# Turn this option on to log every segment added or removed.
option(WITH_LOGGING_TIMING_DATA
       "Build with logging all Add and Erase Segment calls." OFF)

option(WITH_SDL "Build with SDL" OFF)

if(WIN32)
elseif(LINUX)
  option(WITH_CRYSTALHD_DISABLED "Build FFMPEG without Crystal HD support." OFF)
  option(WITH_TTY "Build with Linux TTY Input Support." OFF)
  option(WITH_PROFILING "Build with Profiling Support." OFF)
  option(WITH_GLES2 "Build with OpenGL ES 2.0 Support." ON)
  set(WITH_GTK3 ON)
  option(WITH_PARALLEL_PORT "Build with Parallel Lights I/O Support." OFF)
  option(WITH_CRASH_HANDLER "Build with Crash Handler Support." ON)
  option(WITH_XINERAMA
         "Build using libXinerama to query for monitor numbers (if available)."
         ON)
  option(WITH_ALSA "Build with ALSA support" ON)
  set(WITH_Pulseaudio ON)
  option(WITH_JACK "Build with JACK support" OFF)
  option(WITH_XRANDR "Build with Xrandr support" ON)
  option(WITH_Xtst "Build with libXtst support" ON)
  option(WITH_X11 "Build with X11 support" ON)
endif()
