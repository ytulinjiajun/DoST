#-------------------------------------------------------------------------------------------------
# 配置支持的 STM32 型号:  STM_CHIP, 诸如 STM32F407ZGT6
# STM32_PRODUCT_TYPE: F
# STM32_DEVICE_SUBFAMILY: 407
# STM32_PIN_COUNT: Z --> 144 pins
# STM32_FLASH_MEMORY_SIZE: G --> 1024KB
# STM32_PIN_PACKAGE: T --> LQFP
# STM32_FAMILIE: F4
#-------------------------------------------------------------------------------------------------
set(STM32_SUPPORTED_FAMILIES F4 F7 CACHE INTERNAL "stm32 supported families")
set(STM32_SUPPORTED_PRODUCT_TYPE F CACHE INTERNAL "stm32 supported product type")
set(STM32_SUPPORTED_DEVICE_SUBFAMILY 407 767 CACHE INTERNAL "stm32 supported device subfamily")
set(STM32_SUPPORTED_PIN_COUNT Z I CACHE INTERNAL "stm32 supported pin count")
set(STM32_SUPPORTED_FLASH_MEMORY_SIZE G CACHE INTERNAL "stm32 supported flash memory size")
set(STM32_SUPPORTED_PIN_PACKAGE T CACHE INTERNAL "stm32 supported pin package")

message(STATUS "Selected STM32_CHIP=${STM32_CHIP}")

#-------------------------------------------------------------------------------------------------
# 检索 STM32_FAMILIE
#-------------------------------------------------------------------------------------------------
string(REGEX REPLACE "^[sS][tT][mM]32([aA]|[fF][0-9]|[lL][0-4]|[sS]|[tT]|[wW]|[xX]|[pP]).+$" "\\1" STM32_FAMILY ${STM32_CHIP})
if(STM32_FAMILY STREQUAL STM32_CHIP OR NOT STM32_FAMILY)
  message(FATAL_ERROR "Invalid STM32_FAMILY ,please check it")
else()
  string(TOUPPER ${STM32_FAMILY} STM32_FAMILY)
  list(FIND STM32_SUPPORTED_FAMILIES "${STM32_FAMILY}" STM32_FAMILY_INDEX)
  if(STM32_FAMILY_INDEX EQUAL -1)
    message(FATAL_ERROR "Unsupported STM32_FAMILY: ${STM32_FAMILY}")
  endif()
  if(SHOW_CORE_MESSAGE)
    message(STATUS "STM32_FAMILY=${STM32_FAMILY}")
  endif()
endif()

#-------------------------------------------------------------------------------------------------
# 检索 STM32_PRODUCT_TYPE
#-------------------------------------------------------------------------------------------------
string(REGEX REPLACE "^[sS][tT][mM]32([aA]|[fF]|[lL]|[sS]|[tT]|[wW]|[xX][pP])([0-9][0-9][0-9])([dD]|[yY]|[fF]|[eE]|[gG]|[kK]|[tT]|[hH]|[sS]|[cC]|[uU]|[rR]|[jJ]|[mM]|[oO]|[vV]|[qQ]|[zZ]|[aA]|[iI]|[bB]|[nN]|[xX])([0-9]|[a-i]|[A-I]|[zZ])([bB]|[dD]|[gG]|[hH]|[iI]|[jJ]|[kK]|[mM]|[pP]|[qQ]|[tT]|[uU]|[vV]|[yY]).+$" "\\1" STM32_PRODUCT_TYPE ${STM32_CHIP})
if(STM32_PRODUCT_TYPE STREQUAL STM32_CHIP OR NOT STM32_PRODUCT_TYPE)
  message(FATAL_ERROR "Invalid STM32_PRODUCT_TYPE ,please check it")
else()
  string(TOUPPER ${STM32_PRODUCT_TYPE} STM32_PRODUCT_TYPE)
  list(FIND STM32_SUPPORTED_PRODUCT_TYPE "${STM32_PRODUCT_TYPE}" STM32_PRODUCT_TYPE_INDEX)
  if(STM32_PRODUCT_TYPE_INDEX EQUAL -1)
    message(FATAL_ERROR "Unsupported STM32_PRODUCT_TYPE: ${STM32_PRODUCT_TYPE}")
  endif()
  if(SHOW_CORE_MESSAGE)
    message(STATUS "STM32_PRODUCT_TYPE=${STM32_PRODUCT_TYPE}")
  endif()
endif()

#-------------------------------------------------------------------------------------------------
# 检索 STM32_DEVICE_SUBFAMILY
#-------------------------------------------------------------------------------------------------
string(REGEX REPLACE "^[sS][tT][mM]32([aA]|[fF]|[lL]|[sS]|[tT]|[wW]|[xX][pP])([0-9][0-9][0-9])([dD]|[yY]|[fF]|[eE]|[gG]|[kK]|[tT]|[hH]|[sS]|[cC]|[uU]|[rR]|[jJ]|[mM]|[oO]|[vV]|[qQ]|[zZ]|[aA]|[iI]|[bB]|[nN]|[xX])([0-9]|[a-i]|[A-I]|[zZ])([bB]|[dD]|[gG]|[hH]|[iI]|[jJ]|[kK]|[mM]|[pP]|[qQ]|[tT]|[uU]|[vV]|[yY]).+$" "\\2" STM32_DEVICE_SUBFAMILY ${STM32_CHIP})
if(STM32_DEVICE_SUBFAMILY STREQUAL STM32_CHIP OR NOT STM32_DEVICE_SUBFAMILY)
  message(FATAL_ERROR "Invalid STM32_DEVICE_SUBFAMILY ,please check it")
else()
  list(FIND STM32_SUPPORTED_DEVICE_SUBFAMILY "${STM32_DEVICE_SUBFAMILY}" STM32_DEVICE_SUBFAMILY_INDEX)
  if(STM32_DEVICE_SUBFAMILY_INDEX EQUAL -1)
    message(FATAL_ERROR "Unsupported STM32_DEVICE_SUBFAMILY: ${STM32_DEVICE_SUBFAMILY}")
  endif()
  if(SHOW_CORE_MESSAGE)
    message(STATUS "STM32_DEVICE_SUBFAMILY=${STM32_DEVICE_SUBFAMILY}")
  endif()
endif()

#-------------------------------------------------------------------------------------------------
# 检索 STM32_PIN_COUNT
#-------------------------------------------------------------------------------------------------
string(REGEX REPLACE "^[sS][tT][mM]32([aA]|[fF]|[lL]|[sS]|[tT]|[wW]|[xX][pP])([0-9][0-9][0-9])([dD]|[yY]|[fF]|[eE]|[gG]|[kK]|[tT]|[hH]|[sS]|[cC]|[uU]|[rR]|[jJ]|[mM]|[oO]|[vV]|[qQ]|[zZ]|[aA]|[iI]|[bB]|[nN]|[xX])([0-9]|[a-i]|[A-I]|[zZ])([bB]|[dD]|[gG]|[hH]|[iI]|[jJ]|[kK]|[mM]|[pP]|[qQ]|[tT]|[uU]|[vV]|[yY]).+$" "\\3" STM32_PIN_COUNT ${STM32_CHIP})
if(STM32_PIN_COUNT STREQUAL STM32_CHIP OR NOT STM32_PIN_COUNT)
  message(FATAL_ERROR "Invalid STM32_PIN_COUNT ,please check it")
else()
  string(TOUPPER ${STM32_PIN_COUNT} STM32_PIN_COUNT)
  list(FIND STM32_SUPPORTED_PIN_COUNT "${STM32_PIN_COUNT}" STM32_PIN_COUNT_INDEX)
  if(STM32_PIN_COUNT_INDEX EQUAL -1)
    message(FATAL_ERROR "Unsupported STM32_PIN_COUNT: ${STM32_PIN_COUNT}")
  endif()
  if(SHOW_CORE_MESSAGE)
    message(STATUS "STM32_PIN_COUNT=${STM32_PIN_COUNT}")
  endif()
endif()

#-------------------------------------------------------------------------------------------------
# 检索 STM32_FLASH_MEMORY_SIZE 
#-------------------------------------------------------------------------------------------------
string(REGEX REPLACE "^[sS][tT][mM]32([aA]|[fF]|[lL]|[sS]|[tT]|[wW]|[xX][pP])([0-9][0-9][0-9])([dD]|[yY]|[fF]|[eE]|[gG]|[kK]|[tT]|[hH]|[sS]|[cC]|[uU]|[rR]|[jJ]|[mM]|[oO]|[vV]|[qQ]|[zZ]|[aA]|[iI]|[bB]|[nN]|[xX])([0-9]|[a-i]|[A-I]|[zZ])([bB]|[dD]|[gG]|[hH]|[iI]|[jJ]|[kK]|[mM]|[pP]|[qQ]|[tT]|[uU]|[vV]|[yY]).+$" "\\4" STM32_FLASH_MEMORY_SIZE ${STM32_CHIP})
if(STM32_FLASH_MEMORY_SIZE STREQUAL STM32_CHIP OR NOT STM32_FLASH_MEMORY_SIZE)
  message(FATAL_ERROR "Invalid STM32_FLASH_MEMORY_SIZE ,please check it")
else()
  string(TOUPPER ${STM32_FLASH_MEMORY_SIZE} STM32_FLASH_MEMORY_SIZE)
  list(FIND STM32_SUPPORTED_FLASH_MEMORY_SIZE "${STM32_FLASH_MEMORY_SIZE}" STM32_FLASH_MEMORY_SIZE_INDEX)
  if(STM32_FLASH_MEMORY_SIZE_INDEX EQUAL -1)
    message(FATAL_ERROR "Unsupported STM32_FLASH_MEMORY_SIZE: ${STM32_FLASH_MEMORY_SIZE}")
  endif()
  if(SHOW_CORE_MESSAGE)
    message(STATUS "STM32_FLASH_MEMORY_SIZE=${STM32_FLASH_MEMORY_SIZE}")
  endif()
endif()

#-------------------------------------------------------------------------------------------------
# 检索 STM32_PIN_PACKAGE 
#-------------------------------------------------------------------------------------------------
string(REGEX REPLACE "^[sS][tT][mM]32([aA]|[fF]|[lL]|[sS]|[tT]|[wW]|[xX][pP])([0-9][0-9][0-9])([dD]|[yY]|[fF]|[eE]|[gG]|[kK]|[tT]|[hH]|[sS]|[cC]|[uU]|[rR]|[jJ]|[mM]|[oO]|[vV]|[qQ]|[zZ]|[aA]|[iI]|[bB]|[nN]|[xX])([0-9]|[a-i]|[A-I]|[zZ])([bB]|[dD]|[gG]|[hH]|[iI]|[jJ]|[kK]|[mM]|[pP]|[qQ]|[tT]|[uU]|[vV]|[yY]).+$" "\\5" STM32_PIN_PACKAGE ${STM32_CHIP})
if(STM32_PIN_PACKAGE STREQUAL STM32_CHIP OR NOT STM32_PIN_PACKAGE)
  message(FATAL_ERROR "Invalid STM32_PIN_PACKAGE ,please check it")
else()
  string(TOUPPER ${STM32_PIN_PACKAGE} STM32_PIN_PACKAGE)
  list(FIND STM32_SUPPORTED_PIN_PACKAGE "${STM32_PIN_PACKAGE}" STM32_PIN_PACKAGE_INDEX)
  if(STM32_PIN_PACKAGE_INDEX EQUAL -1)
    message(FATAL_ERROR "Unsupported STM32_PIN_PACKAGE: ${STM32_PIN_PACKAGE}")
  endif()
  if(SHOW_CORE_MESSAGE)
    message(STATUS "STM32_PIN_PACKAGE=${STM32_PIN_PACKAGE}")
  endif()
endif()

# add_definitions(-D${STM32_CHIP})
# add_definitions(-D${STM32_PRODUCT_TYPE})
# add_definitions(-DS${TM32_DEVICE_SUBFAMILY})
# add_definitions(-DS${TM32_PIN_COUNT})
# add_definitions(-D${STM32_FLASH_MEMORY_SIZE})
# add_definitions(-D${STM32_PIN_PACKAGE})
# add_definitions(-D${STM32_FAMILIE})
