#-------------------------------------------------------------------------------------------------
# 编译, 链接, 创建静态库, 创建共享库 的 flags
#-------------------------------------------------------------------------------------------------
set(CMAKE_C_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
set(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

# set(CMAKE_EXE_LINKER_FLAGS "--specs=rdimon.specs -Wl,--start-group -lgcc -lc -lm -lrdimon -Wl,--end-group -Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "executable linker flags")

set(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "executable linker flags")
set(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "module linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "shared linker flags")

#-------------------------------------------------------------------------------------------------
# 判别是否支持给定子类
#-------------------------------------------------------------------------------------------------
set(STM32${STM32_FAMILIE}_SUPPORTED_SUBFAMILY 401 405 407 411 415 417 427 429 437 439 446)
list(FIND STM32${STM32_FAMILIE}_SUPPORTED_SUBFAMILY ${STM32_DEVICE_SUBFAMILY} TYPE_INDEX)
if(TYPE_INDEX EQUAL -1)
  message(FATAL_ERROR "Invalid/unsupported STM32${STM32_FAMILIE} chip type: ${STM32_DEVICE_SUBFAMILY}")
endif()

#-------------------------------------------------------------------------------------------------
# 传递到源文件的宏
#-------------------------------------------------------------------------------------------------
add_definitions(-DSTM32F407xx -DUSE_HAL_DRIVER) # HALLIB库中使用到的宏
add_definitions(-DUSER_STM32F4)                      # 用户代码里面使用到的宏

#-------------------------------------------------------------------------------------------------
# 获取 RAM 的大小
#-------------------------------------------------------------------------------------------------
function(stm32_get_ram_size RAM_SIZE)
  if(STM32_DEVICE_SUBFAMILY STREQUAL "401")
    set(${RAM_SIZE} "64K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "405")
    set(${RAM_SIZE} "128K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "407")
    set(${RAM_SIZE} "128K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "411")
    set(${RAM_SIZE} "128K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "415")
    set(${RAM_SIZE} "128K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "417")
    set(${RAM_SIZE} "128K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "427")
    set(${RAM_SIZE} "192K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "429")
    set(${RAM_SIZE} "192K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "437")
    set(${RAM_SIZE} "192K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "439")
    set(${RAM_SIZE} "192K" CACHE INTERNAL "ram size")
  elseif(STM32_DEVICE_SUBFAMILY STREQUAL "446")
    set(${RAM_SIZE} "128K" CACHE INTERNAL "ram size")
  endif()
endfunction()

#-------------------------------------------------------------------------------------------------
# 获取 CCRAM 内存的大小
#-------------------------------------------------------------------------------------------------
function(stm32_get_ccram_size CCRAM_SIZE)
  set(${CCRAM_SIZE} "64K" CACHE INTERNAL "ram size")
endfunction()

#-------------------------------------------------------------------------------------------------
# 如果目标存在 COMPILE_DEFINITIONS 这个属性,就向该属性里追加 STM32F4, STM32F407 这样的两个值
# 如果目标不存在该属性,则设置该属性为 STM32F4, STM32F407
#-------------------------------------------------------------------------------------------------
function(stm32_set_chip_definitions TARGET)
  get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
  if(TARGET_DEFS)
    set(TARGET_DEFS "STM32F4;STM32F${STM32_DEVICE_SUBFAMILY};${TARGET_DEFS}")
  else()
    set(TARGET_DEFS "STM32F4;STM32F${STM32_DEVICE_SUBFAMILY}")
  endif()
  set_target_properties(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()


