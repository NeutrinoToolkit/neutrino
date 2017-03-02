# this macro to find libraries that trigger components in BOTH neutrino and nPhysImage
# CAVEAT: source inclusion must not be done here (but in FindNeutrinoGuiComponents.cmake or
# in src/CMakeLists.txt)

find_package(OpenMP)
if (OPENMP_FOUND AND NOT "${CMAKE_CXX_FLAGS}" MATCHES "^(${OpenMP_CXX_FLAGS})")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${OpenMP_CXX_FLAGS}")
    add_definitions(-DHAVE_OPENMP)
endif()

find_package(TIFF REQUIRED)
if (TIFF_FOUND)
	include_directories(${TIFF_INCLUDE_DIRS})
	set(LIBS ${LIBS} ${TIFF_LIBRARIES})
	add_definitions(-DHAVE_LIBTIFF)
endif()

# fftw_threads
#find_package(FFTW REQUIRED)
#if (FFTW_FOUND AND FFTW_THREADS_LIB)
#	include_directories(${FFTW_INCLUDE_DIRS})
#	set(LIBS ${LIBS} ${FFTW_LIBRARIES} ${FFTW_THREADS_LIB})
#	add_definitions(-DHAVE_LIBFFTW_THREADS)
#else()
#    message( FATAL_ERROR "You need fftw_threads library" )
#endif()

#fftw
find_library(FFTW NAMES fftw3 fftw3-3 REQUIRED)
if (NOT ${FFTW} STREQUAL "FFTW-NOTFOUND")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        message (STATUS "using FFTW: ${FFTW}")
    endif()
    set(LIBS ${LIBS} ${FFTW})
    add_definitions(-DHAVE_LIBFFTW)
endif()

#in precompiled win dlls the threads are included
if(NOT WIN32)
    # fftw_threads
    find_library(FFTW_THREADS NAMES fftw3_threads REQUIRED)
    if (NOT ${FFTW_THREADS} STREQUAL "FFTW_THREADS-NOTFOUND")
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            message (STATUS "using FFTW_THREADS: ${FFTW_THREADS}")
        endif()
        set(LIBS ${LIBS} ${FFTW_THREADS})
    endif()
endif()

#gsl
find_library(GSL NAMES gsl)
if (NOT ${GSL} STREQUAL "GSL-NOTFOUND")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        message (STATUS "using gsl: ${GSL}")
    endif()
    set(LIBS ${LIBS} ${GSL})
    add_definitions(-DHAVE_LIBGSL)

    FIND_PATH(GSL_INCLUDE_DIR gsl/gsl_math.h
        /usr/local/include/
        /usr/include
    )
    IF (GSL_INCLUDE_DIR)
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            message (STATUS "gsl header dir: ${GSL_INCLUDE_DIR}")
        endif()
        include_directories(BEFORE "${GSL_INCLUDE_DIR}")
    ENDIF (GSL_INCLUDE_DIR)
endif()

# gslcblas
find_library(GSLCBLAS NAMES gslcblas)
if (NOT ${GSLCBLAS} STREQUAL "GSLCBLAS-NOTFOUND")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        message (STATUS "using gslcblas: ${GSL}")
    endif()
    set(LIBS ${LIBS} ${GSLCBLAS})
    add_definitions(-DHAVE_LIBGSLCBLAS)
else()
        message(FATAL_ERROR "Missing gslcblas.")
endif()

# hdf4
find_library (HDF4 NAMES mfhdf)
if (NOT ${HDF4} STREQUAL "HDF4-NOTFOUND")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        message (STATUS "using hdf4: ${HDF4}")
    endif()
    set(LIBS ${LIBS} ${HDF4})
    add_definitions(-DHAVE_LIBMFHDF)
	
    FIND_PATH(HDF4_INCLUDE_DIR hdf.h
  		/usr/local/include/
  		/usr/include
  		/usr/local/include/hdf
  		/usr/include/hdf
    		${CMAKE_FIND_ROOT_PATH}/include
    )

    IF (HDF4_INCLUDE_DIR)
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            message (STATUS "hdf4 header dir: ${HDF4_INCLUDE_DIR}")
        endif()
        include_directories(BEFORE "${HDF4_INCLUDE_DIR}")
    ENDIF (HDF4_INCLUDE_DIR)
endif()

find_library (DF NAMES df)
if (NOT ${DF} STREQUAL "DF-NOTFOUND")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        message (STATUS "using df: ${DF}")
    endif()
    set(LIBS ${LIBS} ${DF})
    add_definitions(-DHAVE_LIBDF)
endif()


# pgm
find_library(NETPBM NAMES netpbm)
if (NOT ${NETPBM} STREQUAL "NETPBM-NOTFOUND")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        message (STATUS "using netpbm: ${NETPBM}")
    endif()
    set(LIBS ${LIBS} ${NETPBM})
    add_definitions(-DHAVE_LIBNETPBM)

    FIND_PATH(NETPBM_INCLUDE_DIR pgm.h
    /usr/include
    /usr/include/netpbm
    /usr/local/include
    /usr/local/include/netpbm
    ${CMAKE_FIND_ROOT_PATH}/include
    )
    IF (NETPBM_INCLUDE_DIR)
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            message (STATUS "netpbm header dir: ${NETPBM_INCLUDE_DIR}")
        endif()
        include_directories(BEFORE ${NETPBM_INCLUDE_DIR})
    ENDIF (NETPBM_INCLUDE_DIR)

endif()

find_package(JPEG REQUIRED)
if (JPEG_FOUND)
    include_directories(${JPEG_INCLUDE_DIRS})
    set(LIBS ${LIBS} ${JPEG_LIBRARIES})
    add_definitions(-DHAVE_JPEG)
endif()

find_library(CFITS NAMES cfitsio)
if (NOT ${CFITS} STREQUAL "CFITS-NOTFOUND")
    FIND_PATH(CFITS_INCLUDE_DIR fitsio.h
    /usr/include
    /usr/include/netpbm
    /usr/local/include
    /usr/local/include/netpbm
    ${CMAKE_FIND_ROOT_PATH}/include
    ${CMAKE_FIND_ROOT_PATH}/include/cfitsio
    )
    message(STATUS ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${CMAKE_FIND_ROOT_PATH} <<")
    IF (CFITS_INCLUDE_DIR)
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            message(STATUS "using cfits: ${CFITS}")
        endif()
        list(APPEND LIBS ${CFITS})
        add_definitions(-DHAVE_LIBCFITSIO)
        include_directories(BEFORE ${CFITS_INCLUDE_DIR})
    endif()
endif()

# opencl
if (NOT CMAKE_MINOR_VERSION LESS "5")
	find_package(OpenCL QUIET)
else()
    # opencl-config.cmake not available until cmake 3.5.x
    find_library(OpenCL_LIBRARIES NAMES OpenCL)
    find_path(OpenCL_INCLUDE_DIRS opencl.h PATH_SUFFIXES CL)
    if (NOT ${OpenCL_LIBRARIES} STREQUAL "OpenCL_LIBRARIES-NOTFOUND")
        message(STATUS "Found OpenCL")
        set (OpenCL_FOUND true)
    endif()
endif()

if (OpenCL_FOUND)
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        message (STATUS "using OpenCL: ${OpenCL_LIBRARIES}")
    endif()

    include_directories(${OpenCL_INCLUDE_DIRS})
    set(LIBS ${LIBS} ${OpenCL_LIBRARIES})
    add_definitions(-DHAVE_OPENCL)

    find_library (CLFFT NAMES clFFT)
    if (NOT ${CLFFT} STREQUAL "CLFFT-NOTFOUND")
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            message (STATUS "using clFFT: ${CLFFT}")
        endif()
        set(LIBS ${LIBS} ${CLFFT})
        add_definitions(-DHAVE_LIBCLFFT)
    endif()
endif()
