#-------------------------------------------------------------------------------------------------
# 作用: 将编译生成的目标转换为hex
#-------------------------------------------------------------------------------------------------
function(stm32_add_hex_bin_target TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
      set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
    else()
      set(FILENAME "${TARGET}")
    endif()
    add_custom_target(${TARGET}.hex DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY} -Oihex ${FILENAME} ${FILENAME}.hex)
    add_custom_target(${TARGET}.bin DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY} -Obinary ${FILENAME} ${FILENAME}.bin)
endfunction()

#-------------------------------------------------------------------------------------------------
# 作用：启动调试
#-------------------------------------------------------------------------------------------------
function(stm32_add_debug_target TARGET)
  if(EXECUTABLE_OUTPUT_PATH)
    set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
  else()
    set(FILENAME ${TARGET})
  endif()
  add_custom_target(${TARGET}.debug DEPENDS ${TARGET}
    COMMAND ${CMAKE_DEBUGER} -iex 'target extended-remote :4242' -iex 'monitor reset halt' -ex 'load' -ex '-' -ex 'b main' -ex 'c' ${FILENAME})
endfunction()

#-------------------------------------------------------------------------------------------------
# 作用: 
#-------------------------------------------------------------------------------------------------
function(stm32_add_dump_target TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
      set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
    else()
      set(FILENAME "${TARGET}")
    endif()
    add_custom_target(${TARGET}.dump DEPENDS ${TARGET} COMMAND ${CMAKE_OBJDUMP} -x -D -S -s ${FILENAME} | ${CMAKE_CPPFILT} > ${FILENAME}.dump)
endfunction()

#-------------------------------------------------------------------------------------------------
# 作用: 
#-------------------------------------------------------------------------------------------------
function(stm32_print_size_of_targets TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
      set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
    else()
      set(FILENAME "${TARGET}")
    endif()
    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_SIZE} ${FILENAME})
endfunction()

#-------------------------------------------------------------------------------------------------
# 作用:
#-------------------------------------------------------------------------------------------------
function(stm32_set_hse_value TARGET STM32_HSE_VALUE)
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE}")
    endif()
    set_target_properties(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()

#-------------------------------------------------------------------------------------------------
# 作用: 获取 FLASH 大小
#-------------------------------------------------------------------------------------------------
function(stm32_get_flash_size FLASH_SIZE)
  if(STM32_FLASH_MEMORY_SIZE STREQUAL "B")
    set(${FLASH_SIZE} "128K" CACHE INTERNAL "flash size")
  elseif(STM32_FLASH_MEMORY_SIZE STREQUAL "C")
    set(${FLASH_SIZE} "256K" CACHE INTERNAL "flash size")
  elseif(STM32_FLASH_MEMORY_SIZE STREQUAL "D")
    set(${FLASH_SIZE} "384K" CACHE INTERNAL "flash size")
  elseif(STM32_FLASH_MEMORY_SIZE STREQUAL "E")
    set(${FLASH_SIZE} "512K" CACHE INTERNAL "flash size")
  elseif(STM32_FLASH_MEMORY_SIZE STREQUAL "F")
    set(${FLASH_SIZE} "768K" CACHE INTERNAL "flash size")
  elseif(STM32_FLASH_MEMORY_SIZE STREQUAL "G")
    set(${FLASH_SIZE} "1024K" CACHE INTERNAL "flash size")
  elseif(STM32_FLASH_MEMORY_SIZE STREQUAL "I")
    set(${FLASH_SIZE} "2048K" CACHE INTERNAL "flash size")
  else()
    message(FATAL_ERROR "Unknown STM32_FLASH_MEMORY_SIZE: ${STM32_FLASH_MEMORY_SIZE}, please check it!")
  endif()
endfunction()

#-------------------------------------------------------------------------------------------------
# 作用: 设置 chip 硬件相关的一些参数, 这些参数在链接脚本里面使用到
#-------------------------------------------------------------------------------------------------
function(stm32_set_chip_params TARGET)
  set(STM32_FLASH_ORIGIN "0x08000000")
  set(STM32_RAM_ORIGIN "0x20000000")
  set(STM32_MIN_STACK_SIZE "0x200")
  set(STM32_MIN_HEAP_SIZE "0")
  set(STM32_CCRAM_ORIGIN "0x10000000")
  
  stm32_get_ram_size(STM32_RAM_SIZE)
  stm32_get_ccram_size(STM32_CCRAM_SIZE)
  stm32_get_flash_size(STM32_FLASH_SIZE)

  message("STM32_FLASH_SIZE=${STM32_FLASH_SIZE}")
  message("STM32_RAM_SIZE=${STM32_RAM_SIZE}")
  message("STM32_CCRAM_SIZE=${STM32_CCRAM_SIZE}")
  
  if((NOT STM32_FLASH_SIZE) OR (NOT STM32_RAM_SIZE) OR (NOT STM32_CCRAM_SIZE))
    message(FATAL_ERROR "Unknown STM32_FLASH_SIZE/STM32_RAM_SIZE/STM32_CCRAM_SIZE, Please check it!")
  endif()

  if(NOT STM32_LINKER_SCRIP)
    message(STATUS "No linker script specified, generating default")
    include(stm32_linker)
    file(WRITE ${STM32_SCRIPTS_DIR}/${TARGET}_FLASH.ld ${STM32_LINKER_SCRIPT_TEXT})
  else()
    configure_file(${STM32_LINKER_SCRIPT} ${STM32_SCRIPTS_DIR}/${TARGET}_FLASH.ld)
  endif()

  get_target_property(TARGET_LD_FLAGS ${TARGET} LINK_FLAGS)
  if(TARGET_LD_FLAGS)
    set(TARGET_LD_FLAGS "\"-T${STM32_SCRIPTS_DIR}/${TARGET}_FLASH.ld\" ${TARGET_LD_FLAGS}")
  else()
    set(TARGET_LD_FLAGS "\"-T${STM32_SCRIPTS_DIR}/${TARGET}_FLASH.ld\"")
  endif()

  set_target_properties(${TARGET} PROPERTIES LINK_FLAGS ${TARGET_LD_FLAGS})
endfunction()

#-------------------------------------------------------------------------------------------------
# 作用: 设置目标属性
#-------------------------------------------------------------------------------------------------
function(stm32_set_target_properties TARGET)
  stm32_set_chip_definitions(${TARGET})

  stm32_set_chip_params(${TARGET})

  message(STATUS "${STM32_CHIP} has ${STM32_FLASH_SIZE}B of flash memory and ${STM32_RAM_SIZE}B of RAM and ${STM32_CCRAM_SIZE}B")
endfunction()

#-------------------------------------------------------------------------------------------------
# 作用: 设置库属性
#-------------------------------------------------------------------------------------------------
macro(stm32_generate_libraries NAME SOURCES LIBRARIES)
    string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
    foreach(CHIP_TYPE ${STM32_CHIP_TYPES})
        string(TOLOWER ${CHIP_TYPE} CHIP_TYPE_LOWER)
        list(APPEND ${LIBRARIES} ${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER})
        add_library(${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${SOURCES})
        stm32_set_chip_definitions(${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${CHIP_TYPE})
    endforeach()
endmacro()

#-------------------------------------------------------------------------------------------------
# 作用： 向 PROJECT_SOURCES 这个全局变量添加源文件
#-------------------------------------------------------------------------------------------------
function(stm32_add_project_source src)
  foreach(tmp0 ${${src}})
    string(CONCAT tmp1 "${CMAKE_CURRENT_LIST_DIR}/" "${tmp0}")
    list(APPEND tmp2 ${tmp1})
  endforeach()
  get_property(tmp GLOBAL PROPERTY PROJECT_SOURCE)
  set_property(GLOBAL PROPERTY PROJECT_SOURCE ${tmp} ${tmp2})
endfunction()

# Provides an option that the user can optionally select.
# Can accept condition to control when option is available for user.
# Usage:
#   option(<option_variable> "help string describing the option" <initial value or boolean expression> [IF <condition>])
macro(STM32_OPTION variable description value)
  set(__value ${value})
  set(__condition "")
  set(__varname "__value")
  foreach(arg ${ARGN})
    if(arg STREQUAL "IF" OR arg STREQUAL "if")
      set(__varname "__condition")
    else()
      list(APPEND ${__varname} ${arg})
    endif()
  endforeach()
  unset(__varname)
  if(__condition STREQUAL "")
    set(__condition 2 GREATER 1)
  endif()

  if(${__condition})
    if(__value MATCHES ";")
      if(${__value})
        option(${variable} "${description}" ON)
      else()
        option(${variable} "${description}" OFF)
      endif()
    elseif(DEFINED ${__value})
      if(${__value})
        option(${variable} "${description}" ON)
      else()
        option(${variable} "${description}" OFF)
      endif()
    else()
      option(${variable} "${description}" ${__value})
    endif()
  else()
    unset(${variable} CACHE)
  endif()
  unset(__condition)
  unset(__value)
endmacro()
