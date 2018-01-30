set(CMAKE_C_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
set(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

set(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections -mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "executable linker flags")
set(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "module linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "shared linker flags")

#-------------------------------------------------------------------------------------------------
# 判别是否支持给定子类
#-------------------------------------------------------------------------------------------------
set(STM32${STM32_FAMILIE}_SUPPORTED_SUBFAMILY 745 746 756 767 777 769 779)
list(FIND STM32${STM32_FAMILIE}_SUPPORTED_SUBFAMILY ${STM32_DEVICE_SUBFAMILY} TYPE_INDEX)
if(TYPE_INDEX EQUAL -1)
  message(FATAL_ERROR "Invalid/unsupported STM32${STM32_FAMILIE} chip type: ${STM32_DEVICE_SUBFAMILY}")
endif()

#-------------------------------------------------------------------------------------------------
# 传递到源文件的宏
#-------------------------------------------------------------------------------------------------
add_definitions(-DSTM32F767xx -DUSE_HAL_DRIVER -DUSE_USB_OTG_FS) # HALLIB库中使用到的宏
add_definitions(-DUSER_STM32F7)                      # 用户代码里面使用到的宏

#-------------------------------------------------------------------------------------------------
# 获取 RAM 的大小
#-------------------------------------------------------------------------------------------------
function(stm32_get_ram_size RAM_SIZE)
  if(STM32_DEVICE_SUBFAMILY STREQUAL "745")
    set(${RAM_SIZE} "320K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "746")
    set(${RAM_SIZE} "320K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "756")
    set(${RAM_SIZE} "320K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "767")
    set(${RAM_SIZE} "512K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "777")
    set(${RAM_SIZE} "512K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "769")
    set(${RAM_SIZE} "512K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "779")
    set(${RAM_SIZE} "512K" CACHE INTERNAL "ram size")
  endif()
endfunction()

#-------------------------------------------------------------------------------------------------
# 获取 CCRAM 的大小
#-------------------------------------------------------------------------------------------------
function(stm32_get_ccram_size CCRAM_SIZE)
  set(${CCRAM_SIZE} "0K" CACHE INTERNAL "ccram size")
endfunction()

#-------------------------------------------------------------------------------------------------
# 如果目标存在 COMPILE_DEFINITIONS 这个属性,就向该属性里追加 STM32F7, STM32F767 这样的两个值
# 如果目标不存在该属性,则设置该属性为 STM32F7, STM32F767
#-------------------------------------------------------------------------------------------------
function(stm32_set_chip_definitions TARGET)
  get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
  if(TARGET_DEFS)
    set(TARGET_DEFS "STM32F7;STM32F${STM32_DEVICE_SUBFAMILY};${TARGET_DEFS}")
  else()
    set(TARGET_DEFS "STM32F7;STM32F${STM32_DEVICE_SUBFAMILY}")
  endif()
  set_target_properties(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
