# find components specific to Neutrino GUI: qwt/qt/additional files here!

find_package(Qwt REQUIRED)
if (QWT_FOUND)
	include_directories(${QWT_INCLUDE_DIRS})
	message(STATUS "qwt link: " ${QWT_LIBRARIES})
	set(LIBS ${LIBS} ${QWT_LIBRARIES})
endif(QWT_FOUND)


if (HDF5_FOUND_COMPLETE)
	# add nHDF5 sources
	list (APPEND SOURCES pans/nHDF5.cc)
	list (APPEND UIS ${UIS} ../UIs/nHDF5.ui)
endif()

if (PYTHONQT_FOUND_COMPLETE)
    MESSAGE(STATUS "adding python wrappers")
	include_directories(python)
	list (APPEND SOURCES python/nPhysPyWrapper.cc python/nPython.cc)	
	list (APPEND UIS ../UIs/nPython.ui)	
endif()


## find qt MUST be LAST to all modifications to SOURCES list
## (otherwise automoc and autoui won't take new sources in account)
set (RESOURCES "${${PROJECT_NAME}_SOURCE_DIR}/resources/neutrino.qrc")

## find qt -- search for 5.x first, fallback to 4.x
find_package(Qt5 COMPONENTS Core Gui Sql Widgets Svg PrintSupport UiTools Multimedia MultimediaWidgets QUIET)
if (Qt5_FOUND)
	# qt5
	SET (USE_QT5 True)
	message(STATUS "Using Qt5: ${Qt5Core_INCLUDE_DIRS}")
        include_directories(${Qt5Core_INCLUDE_DIRS} ${Qt5Gui_INCLUDE_DIRS} ${Qt5Sql_INCLUDE_DIRS} ${Qt5Widgets_INCLUDE_DIRS} ${Qt5Svg_INCLUDE_DIRS} ${Qt5PrintSupport_INCLUDE_DIRS} ${Qt5UiTools_INCLUDE_DIRS} ${Qt5Multimedia_INCLUDE_DIRS} ${Qt5MultimediaWidgets_INCLUDE_DIRS})
	
	add_definitions(-DUSE_QT5)
else()
	# some incompatibilities between 4.x and 5.x
	# qt4
	SET (USE_QT4 True)
	message(STATUS "Qt5 not found, searching for Qt4 instead")
	find_package(Qt4 4.7.0 COMPONENTS QtMain QtCore QtGui QtSQL REQUIRED)
	include(UseQt4)
	include(${QT_USE_FILE})
	
	add_definitions(-DUSE_QT4)
endif()


add_definitions(${QT_DEFINITIONS})
include_directories(${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR})

