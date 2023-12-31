# Prep options that are needed for each platform.

# This option allows for networking support with StepMania.
option(WITH_NETWORKING "Build with networking support." ON)

# This option quiets warnings that are a part of external projects.
option(WITH_EXTERNAL_WARNINGS
       "Build with warnings for all components, not just StepMania." OFF)

# This option is not yet working, but will likely default to ON in the future.
option(WITH_LTO
       "Build with Link Time Optimization (LTO)/Whole Program Optimization."
       OFF)

# This option handles if we use SSE2 processing.
option(WITH_SSE2 "Build with SSE2 Optimizations." ON)

# This option may go away in the future: if it does, JPEG will always be
# required.
option(WITH_JPEG "Build with JPEG Image Support." ON)

# Turn this on to set this to a specific release mode.
option(WITH_FULL_RELEASE "Build as a proper, full release." OFF)

# Turn this option off to not use the GPL exclusive components.
option(WITH_GPL_LIBS "Build with GPL libraries." ON)

# Turn this option off to disable using WAV files with the game. Note that it is
# recommended to keep this on.
set(WITH_WAV ON)

# Turn this option off to disable using MP3 files with the game.
option(WITH_MP3 "Build with MP3 Support." ON)

# Turn this option off to disable using OGG files with the game.
set(WITH_OGG ON)

# Turn this option on to log every segment added or removed.
option(WITH_LOGGING_TIMING_DATA
       "Build with logging all Add and Erase Segment calls." OFF)

option(WITH_SDL "Build with SDL" OFF)

if(MSVC)
  # Turn this option on to enable using the Texture Font Generator.
  set(WITH_TEXTURE_GENERATOR ON)
endif()

if(WIN32)
elseif(LINUX)
  option(WITH_CRYSTALHD_DISABLED "Build FFMPEG without Crystal HD support." OFF)
  option(WITH_TTY "Build with Linux TTY Input Support." OFF)
  option(WITH_PROFILING "Build with Profiling Support." OFF)
  option(WITH_GLES2 "Build with OpenGL ES 2.0 Support." ON)
  option(WITH_GTK3 "Build with GTK3 Support." ON)
  option(WITH_PARALLEL_PORT "Build with Parallel Lights I/O Support." OFF)
  option(WITH_CRASH_HANDLER "Build with Crash Handler Support." ON)
  option(WITH_XINERAMA
         "Build using libXinerama to query for monitor numbers (if available)."
         ON)
  option(WITH_ALSA "Build with ALSA support" ON)
  option(WITH_PULSEAUDIO "Build with PulseAudio support" ON)
  option(WITH_JACK "Build with JACK support" OFF)
  option(WITH_XRANDR "Build with Xrandr support" ON)
  option(WITH_LIBXTST "Build with libXtst support" ON)
  option(WITH_X11 "Build with X11 support" ON)
endif()
