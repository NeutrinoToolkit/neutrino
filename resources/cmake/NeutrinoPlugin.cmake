MACRO(ADD_NEUTRINO_PLUGIN)


    get_filename_component(MY_PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

	set(CMAKE_OSX_DEPLOYMENT_TARGET "10.10" CACHE STRING "Minimum OS X deployment version")

	PROJECT (${MY_PROJECT_NAME} CXX)

	MESSAGE(STATUS "Plugin => ${PROJECT_NAME}")

	include(FindNeutrinoDeps)

	if (APPLE AND NOT DEFINED Qt5_DIR)
		set(Qt5_DIR "/usr/local/opt/qt5/lib/cmake/Qt5")
	endif()

	find_package(Qt5 COMPONENTS Core Gui Sql Widgets Svg PrintSupport UiTools Multimedia MultimediaWidgets OpenGL REQUIRED)

	add_definitions(${QT_DEFINITIONS})
	include_directories(${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR})


	if(APPLE)
		set (LIBRARY_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/../../Neutrino.app/Contents/Resources/plugins")
		set (PLUGIN_INSTALL_DIR "${LIBRARY_OUTPUT_PATH}")
	elseif(LINUX)
		set (LIBRARY_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/../../share/neutrino/plugins")
		set (PLUGIN_INSTALL_DIR "/usr/share/neutrino/plugins")
    elseif(WIN32)
		set (LIBRARY_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/../../bin/plugins")
		set (PLUGIN_INSTALL_DIR "bin/plugins")
	endif()

	set (CMAKE_CXX_FLAGS_DEBUG "-O0 -ggdb -Wall -D__phys_debug=10")
	set (CMAKE_CXX_FLAGS_RELEASE "-O3 -DQT_NO_DEBUG -DQT_NO_WARNING_OUTPUT -DQT_NO_DEBUG_OUTPUT")
	add_compile_options(-std=c++11)


	if (NOT EXISTS ${NEUTRINO_ROOT}/src/neutrino.h)
		message(FATAL_ERROR "Please specify neutrino source tree with -DNEUTRINO_ROOT=<path/to/neutrino>")
	endif()

	# check for nphys
	if (NOT ${NPHYS_PATH} STREQUAL "" AND NOT IS_ABSOLUTE ${NPHYS_PATH})
		message (STATUS "NPHYS_PATH is not absolute, fixing")
		set (ABS_NPHYS_PATH "${CMAKE_BINARY_DIR}/${NPHYS_PATH}")
	endif()

	# find goodies

	add_definitions(-DQT_PLUGIN)

	set(CMAKE_AUTOMOC ON)
	set(CMAKE_AUTOUIC ON)
	set(CMAKE_AUTORCC ON)
	set(CMAKE_INCLUDE_CURRENT_DIR ON)
	set(CMAKE_AUTOUIC_SEARCH_PATHS ${NEUTRINO_ROOT}/UIs)

	# add neutrino deps
	include_directories(${NEUTRINO_ROOT}/nPhysImage)
	include_directories(${NEUTRINO_ROOT}/src) # for base stuff

	# visar needs to borrow some stuff from neutrino tree
	include_directories(${NEUTRINO_ROOT}/src/graphics)

	file(GLOB UIS ${CMAKE_CURRENT_SOURCE_DIR}/*.ui)
	file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*.cc)
	file(GLOB QRCS ${CMAKE_CURRENT_SOURCE_DIR}/*.qrc)




	## add help

	if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

		if(NOT DEFINED PANDOC)
			find_program(PANDOC pandoc REQUIRED)
		endif(NOT DEFINED PANDOC)

		set(README_MD "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
		set(README_HTML "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}README.html")
		set_source_files_properties( ${README_MD} PROPERTIES HEADER_FILE_ONLY TRUE)

		set(PANDOC_QRC ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}pandoc.qrc)

		GET_FILENAME_COMPONENT(my_file_basename ${README_HTML} NAME)
		file(WRITE ${PANDOC_QRC} "<RCC>\n    <qresource>\n")
		file(APPEND ${PANDOC_QRC} "        <file alias=\"${my_file_basename}\">${README_HTML}</file>\n")
		file(APPEND ${PANDOC_QRC} "    </qresource>\n</RCC>")

		add_custom_command(
			OUTPUT ${README_HTML}
			COMMAND ${PANDOC} --metadata title="${MY_PROJECT_NAME}" -s README.md --self-contained -o ${README_HTML}
			MAIN_DEPENDENCY "README.md"
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			)

		add_custom_target(pandoc${PROJECT_NAME} ALL DEPENDS ${README_HTML} SOURCES ${README_MD})
	endif()

	## add translations
	SET(Qt5LinguistTools_DIR "${Qt5_DIR}/../Qt5LinguistTools")
	find_package(Qt5LinguistTools)
	if (Qt5LinguistTools_FOUND)
		SET(LANGUAGES fr_FR it_IT ko_KP)
		SET(LANGUAGE_TS_FILES)
		FOREACH(LANGUAGE ${LANGUAGES})
		    SET(TS_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_${LANGUAGE}.ts")
			if(EXISTS ${TS_FILE})
				SET(LANGUAGE_TS_FILES ${LANGUAGE_TS_FILES} ${TS_FILE})
				qt5_add_translation(qm_files ${TS_FILE})
			else ()
				if (CMAKE_BUILD_TYPE STREQUAL "Debug")
					SET(TS_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_${LANGUAGE}.ts")
					message (STATUS "[Debug] translation file ${TS_FILE} will be created, commit it if you create the translations.")
					qt5_create_translation(qm_files ${SOURCES} ${UIS} ${TS_FILE})
				endif()
			endif()

			ENDFOREACH()

		IF(LANGUAGE_TS_FILES)
		    set(TRANSL_QRC ${CMAKE_CURRENT_BINARY_DIR}/translations.qrc)
			file(WRITE ${TRANSL_QRC} "<RCC>\n    <qresource prefix=\"/translations/\">\n")
			foreach(my_file ${qm_files})
				file(RELATIVE_PATH my_file_relative_path ${CMAKE_CURRENT_BINARY_DIR} ${my_file})
				file(APPEND ${TRANSL_QRC} "        <file>${my_file_relative_path}</file>\n")
			endforeach()
			file(APPEND ${TRANSL_QRC} "    </qresource>\n</RCC>")
			list(LENGTH LANGUAGE_TS_FILES LIST_LENGTH)

			ENDIF(LANGUAGE_TS_FILES)

		endif(Qt5LinguistTools_FOUND)


	QT5_WRAP_UI(nUIs ${NEUTRINO_ROOT}/UIs/neutrino.ui ${NEUTRINO_ROOT}/UIs/nLine.ui ${NEUTRINO_ROOT}/UIs/nObject.ui)
	set_property(SOURCE ${nUIs} PROPERTY SKIP_AUTOGEN ON)

	add_library (${PROJECT_NAME} SHARED ${SOURCES} ${UIS} ${nUIs} ${QRCS} ${TRANSL_QRC} ${PANDOC_QRC} ${README_MD})

	IF(APPLE)
	    set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -undefined dynamic_lookup")
		ENDIF()

		if(WIN32)
		add_dependencies(${PROJECT_NAME} Neutrino)
		set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--allow-shlib-undefined")
		target_link_libraries(${PROJECT_NAME} ${CMAKE_BINARY_DIR}/src/libNeutrino.dll.a;${CMAKE_BINARY_DIR}/nPhysImage/libnPhysImageF.dll.a;${LIBS})
		# to check: --enable-runtime-pseudo-reloc
	endif()

	if (DEFINED LOCAL_LIBS)
		target_link_libraries(${PROJECT_NAME} ${LOCAL_LIBS})
	endif()

	SET(MODULES Core Gui Widgets Svg PrintSupport)
	if (DEFINED LOCAL_MODULES)
		SET(MODULES ${MODULES} ${LOCAL_MODULES})
	endif()

	qt5_use_modules(${PROJECT_NAME} ${MODULES})

	IF(DEFINED PLUGIN_INSTALL_DIR)
	    install(TARGETS ${PROJECT_NAME} DESTINATION ${PLUGIN_INSTALL_DIR})
		ENDIF()

ENDMACRO()


