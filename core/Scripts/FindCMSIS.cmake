# if(STM32_CHIP_TYPE OR STM32_CHIP)
    # if(NOT STM32_CHIP_TYPE)
        # stm32_get_chip_type(${STM32_CHIP} STM32_CHIP_TYPE)
        # if(NOT STM32_CHIP_TYPE)
            # message(FATAL_ERROR "Unknown chip: ${STM32_CHIP}. Try to use STM32_CHIP_TYPE directly.")
        # endif()
        # message(STATUS "${STM32_CHIP} is ${STM32_CHIP_TYPE} device")
    # endif()
    # string(TOLOWER ${STM32_CHIP_TYPE} STM32_CHIP_TYPE_LOWER)
# endif()

if(NOT STM32_FAMILY)
  message(FATAL_ERROR "Unknown STM32_FAMILY, please check it!")
endif()

#-------------------------------------------------------------------------------------------------
# 构造出 STM32_ARCH_NUM (m4 m7)
#-------------------------------------------------------------------------------------------------
string(REGEX REPLACE "^([fF]|[lL]|[sS]|[tT]|[wW]|[xX][pP])([0-9])+$" "m\\2" STM32_ARCH_NUM ${STM32_FAMILY})
if(STM32_ARCH_NUM STREQUAL STM32_FAMILY OR NOT STM32_ARCH_NUM)
  message(FATAL_ERROR "STM32_ARCH_NUM error,please check it!")
endif()

string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
string(TOLOWER ${STM32_PRODUCT_TYPE} STM32_PRODUCT_TYPE_LOWER)

#-------------------------------------------------------------------------------------------------
# 构造标识产品子系列的后缀
#-------------------------------------------------------------------------------------------------
if(STM32_FAMILY STREQUAL "F4")
  if(STM32_DEVICE_SUBFAMILY STREQUAL "401")
    set(STM32_SUFFIX_EXTRA "xc")
    message(STATUS "you working on STM32F401 with stm32f401xc.h and you have another choice about xe")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "410")
    set(STM32_SUFFIX_EXTRA "cx")
    message(STATUS "you working on STM32F401 with stm32f401cx.h and you have another choices about rx tx")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "411")
    set(STM32_SUFFIX_EXTRA "xe")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "412")
    set(STM32_SUFFIX_EXTRA "cx")
    message(STATUS "you working on STM32F401 with stm32f401cx.h and you have another choices about rx vx zx")
  else()
    set(STM32_SUFFIX_EXTRA "xx")
  endif()
elseif(STM32_FAMILY STREQUAL "F7")
  set(STM32_SUFFIX_EXTRA "xx")
endif()

#-------------------------------------------------------------------------------------------------
# 通用头文件
#-------------------------------------------------------------------------------------------------
set(CMSIS_COMMON_HEADERS
    arm_common_tables.h
    arm_const_structs.h
    arm_math.h
    core_cmFunc.h
    core_cmInstr.h
    core_cmSimd.h
    core_c${STM32_ARCH_NUM}.h
    )

#-------------------------------------------------------------------------------------------------
# 设备相关的头文件
#-------------------------------------------------------------------------------------------------
set(CMSIS_DEVICE_HEADERS
  stm32${STM32_FAMILY_LOWER}xx.h
  system_stm32${STM32_FAMILY_LOWER}xx.h
  stm32${STM32_PRODUCT_TYPE_LOWER}${STM32_DEVICE_SUBFAMILY}${STM32_SUFFIX_EXTRA}.h
  )

#-------------------------------------------------------------------------------------------------
# 设备相关的源文件
#-------------------------------------------------------------------------------------------------
set(CMSIS_DEVICE_SOURCES
  system_stm32${STM32_FAMILY_LOWER}xx.c
  )

#-------------------------------------------------------------------------------------------------
# 设备相关的启动源文件
#-------------------------------------------------------------------------------------------------
set(CMSIS_STARTUP_SOURCE
  startup_stm32${STM32_PRODUCT_TYPE_LOWER}${STM32_DEVICE_SUBFAMILY}${STM32_SUFFIX_EXTRA}.s
  )

#-------------------------------------------------------------------------------------------------
# 获取通用头文件的路径
#-------------------------------------------------------------------------------------------------
find_path(CMSIS_COMMON_INCLUDE_DIR NAMES ${CMSIS_COMMON_HEADERS}
  HINTS ${STM32Cube_ARCHIVE_FULLDIR}/Drivers/CMSIS/Include
  NO_DEFAULT_PATH
  )

find_path(CMSIS_DEVICE_INCLUDE_DIR NAMES ${CMSIS_DEVICE_HEADERS}
  HINTS ${STM32Cube_ARCHIVE_FULLDIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Include
  NO_DEFAULT_PATH
  )

set(CMSIS_INCLUDE_DIRS
  ${CMSIS_COMMON_INCLUDE_DIR}
  ${CMSIS_DEVICE_INCLUDE_DIR}
  )

#-------------------------------------------------------------------------------------------------
# 获取启动源文件
#-------------------------------------------------------------------------------------------------
foreach(cmp ${CMSIS_STARTUP_SOURCE})
  set(CMSIS_STARTUP_SOURCE_FILE CMSIS_STARTUP_SOURCE_FILE-NOTFOUND)
  find_file(CMSIS_STARTUP_SOURCE_FILE NAMES ${cmp}
    HINTS ${STM32Cube_ARCHIVE_FULLDIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Source/Templates/gcc
    NO_DEFAULT_PATH)
  if(CMSIS_STARTUP_SOURCE_FILE)
    message(STATUS "Found ${CMSIS_STARTUP_SOURCE_FILE}")
    list(APPEND CMSIS_SOURCES ${CMSIS_STARTUP_SOURCE_FILE})
  endif()
endforeach()

#-------------------------------------------------------------------------------------------------
# 获取设备相关的源文件
#-------------------------------------------------------------------------------------------------
foreach(cmp ${CMSIS_DEVICE_SOURCES})
  set(CMSIS_DEVICE_SOURCE_FILE CMSIS_DEVICE_SOURCE_FILE-NOTFOUND)
  find_file(CMSIS_DEVICE_SOURCE_FILE NAMES ${cmp}
    HINTS ${STM32Cube_ARCHIVE_FULLDIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Source/Templates
    NO_DEFAULT_PATH)
  if(CMSIS_DEVICE_SOURCE_FILE)
    message(STATUS "Found ${CMSIS_DEVICE_SOURCE_FILE}")
    list(APPEND CMSIS_SOURCES ${CMSIS_DEVICE_SOURCE_FILE})
  endif()

endforeach()

#-------------------------------------------------------------------------------------------------
# 删除列表中重复的项目
#-------------------------------------------------------------------------------------------------
list(REMOVE_DUPLICATES CMSIS_INCLUDE_DIRS)
list(REMOVE_DUPLICATES CMSIS_SOURCES)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMSIS DEFAULT_MSG CMSIS_INCLUDE_DIRS CMSIS_SOURCES)
