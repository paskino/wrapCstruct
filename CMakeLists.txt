#   Copyright 2018 CCPi
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

cmake_minimum_required(VERSION 3.0)
project(wrapCstruct)

option (BUILD_PYTHON_WRAPPER "Build Python Wrappers" OFF)
option (CONDA_BUILD "Conda Build" OFF)
set (CMAKE_BUILD_TYPE "Release")




find_package(PythonInterp REQUIRED)
if (PYTHONINTERP_FOUND)
  message ("Current Python " ${PYTHON_VERSION_STRING} " found " ${PYTHON_EXECUTABLE})
endif()
if (CONDA_BUILD)
else()
set(PYTHON_DEST_DIR "" CACHE PATH "Directory of the Matlab wrappers")
  if (PYTHON_DEST_DIR)
   set(PYTHON_DEST "${PYTHON_DEST_DIR}")
  else() 
    set(PYTHON_DEST "${CMAKE_INSTALL_PREFIX}/python")
  endif()
  message(STATUS "Python wrappers will be installed in " ${PYTHON_DEST})
endif()

find_package(PythonInterp)
find_package(PythonLibs)
if (PYTHONINTERP_FOUND)
  message(STATUS "Found PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}")
  message(STATUS "Python version ${PYTHON_VERSION_STRING}")
endif()
if (PYTHONLIBS_FOUND)
  message(STATUS "Found PYTHON_INCLUDE_DIRS=${PYTHON_INCLUDE_DIRS}")
  message(STATUS "Found PYTHON_LIBRARIES=${PYTHON_LIBRARIES}")
endif()

if (PYTHONINTERP_FOUND)
    message("Python found " ${PYTHON_EXECUTABLE})
    set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
    set(SETUP_PY    "${CMAKE_CURRENT_BINARY_DIR}/setup.py")
    #set(DEPS        "${CMAKE_CURRENT_SOURCE_DIR}/module/__init__.py")
    set (DEPS       "${CMAKE_BINARY_DIR}/functions/")
    set(OUTPUT      "${CMAKE_CURRENT_BINARY_DIR}/build/timestamp")

    configure_file(${SETUP_PY_IN} ${SETUP_PY})
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/run_test.py ${CMAKE_CURRENT_BINARY_DIR}/run_test.py)

    message("Core binary dir " ${CMAKE_BINARY_DIR}/Core/${CMAKE_BUILD_TYPE})
    
    if (CONDA_BUILD)
      add_custom_command(OUTPUT ${OUTPUT}
                       COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/src ${CMAKE_CURRENT_BINARY_DIR}/src
                       COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/tomophantom ${CMAKE_CURRENT_BINARY_DIR}/tomophantom
                       COMMAND ${CMAKE_COMMAND} -E env CIL_VERSION=${CIL_VERSION}
                                                       PREFIX=${CMAKE_SOURCE_DIR}/Core 
                                                       LIBRARY_INC=${CMAKE_SOURCE_DIR}/Core 
                                                       LIBRARY_LIB=${CMAKE_BINARY_DIR}/Core
                                                       ${PYTHON_EXECUTABLE} ${SETUP_PY} install
                       COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}
                       DEPENDS  cildvc_shared)
      add_custom_target(PythonWrapper ALL DEPENDS ${OUTPUT})

    else()
	  message("Library should be in ${CMAKE_BINARY_DIR}/Core/${CMAKE_BUILD_TYPE}")
      add_custom_command(OUTPUT ${OUTPUT}
                       COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/src ${CMAKE_CURRENT_BINARY_DIR}/src
                       COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/ccpi ${CMAKE_CURRENT_BINARY_DIR}/ccpi
                       COMMAND ${CMAKE_COMMAND} -E env CIL_VERSION=${CIL_VERSION}
                                                       PREFIX=${CMAKE_SOURCE_DIR}/Core 
                                                       LIBRARY_INC=${CMAKE_SOURCE_DIR}/Core 
                                                       LIBRARY_LIB=${CMAKE_BINARY_DIR}/Core/${CMAKE_BUILD_TYPE}
                                                       ${PYTHON_EXECUTABLE} ${SETUP_PY} build_ext --inplace
                       COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}
					   DEPENDS  cildvc_shared
                       )
      add_custom_target(PythonWrapper ALL DEPENDS ${OUTPUT})
      install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/ccpi 
              DESTINATION ${PYTHON_DEST})
    endif()
    
    
    

    #install(CODE "execute_process(COMMAND ${PYTHON} ${SETUP_PY} install)")
endif()