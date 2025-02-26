project(js-dos)
cmake_minimum_required(VERSION 3.6)

set(X86 false)
set(X86_64 false)
set(BUILD_NATIVE_LIBZIP false)
set(OPT_FLAGS "-Oz -fno-exceptions -w -Werror=return-type -flto=thin")

if(${EMSCRIPTEN})
	set(OPT_FLAGS "${OPT_FLAGS} -s")

	add_definitions(-DEMSCRIPTEN)

	set(USE_PORTS "-s USE_ZLIB=1")	
	set(CMAKE_C_FLAGS "${OPT_FLAGS} ${USE_PORTS}")
	set(CMAKE_CXX_FLAGS "${OPT_FLAGS} ${USE_PORTS}")
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} \
		${USE_PORTS} \
		${OPT_FLAGS} \
		-s TOTAL_STACK=1MB \
		-s MALLOC=emmalloc \
		--emit-symbol-map \
		-s ASSERTIONS=0 \
		-s SAFE_HEAP=0 \
		-s TOTAL_MEMORY=67108864 \
		-s ALLOW_MEMORY_GROWTH=1 \
		-s EXIT_RUNTIME=1 \
		-s INVOKE_RUN=0 \
		-s MODULARIZE=1 \
		-s FORCE_FILESYSTEM=1 \
		-s EXTRA_EXPORTED_RUNTIME_METHODS=\"['addRunDependency', 'removeRunDependency','FS', 'FS_createPath', 'FS_createPreloadedFile', \
			'FS_createDataFile', 'lengthBytesUTF8', 'stringToUTF8', 'UTF16ToString', 'UTF8ToString', 'callMain']\" \
                -s EXPORTED_FUNCTIONS=\"['_main', '_malloc', '_free', '_abort']\" \
		-s ERROR_ON_UNDEFINED_SYMBOLS=1")
else()
	set(OPT_FLAGS "${OPT_FLAGS} -O0 -g")

	if (MINGW)
		set(X86_64 true)
		set(OPT_FLAGS "")
	else()
		set(CMAKE_C_COMPILER "/usr/bin/clang")
		set(CMAKE_CXX_COMPILER "/usr/bin/clang++")
	endif()

	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OPT_FLAGS}")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OPT_FLAGS}")
#	add_definitions(-DC_DEBUG=1 -DC_HEAVY_DEBUG=1)
endif()

include_directories("${CMAKE_CURRENT_LIST_DIR}/src/protocol")

include("${CMAKE_CURRENT_LIST_DIR}/native/libzip/libzip.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/native/dosbox-jsdos/dosbox-jsdos.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/native/dosbox-jsdos/sokol/sokol.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/native/dosbox-jsdos/dhry2/dhry2.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/native/dosbox-jsdos/sdl/sdl.cmake")

include("${CMAKE_CURRENT_LIST_DIR}/src/dos/dosbox/dosbox.cmake")
