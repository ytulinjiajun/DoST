#-------------------------------------------------------------------------------------------------
# HALLIB 下面涉及的所有组件
#-------------------------------------------------------------------------------------------------
set(HAL_COMPONENTS adc can cec cortex crc cryp dac dcmi dfsdm dma dma2d dsi eth flash
                   flash_ramfunc fmpi2c gpio hash hcd i2c i2s irda iwdg lptim ltdc mmc
                   nand nor pccard pcd pwr qspi rcc rng rtc sai sd sdram
                   smartcard spdifrx spi sram tim uart usart wwdg)

# 必须参与编译的组件
set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

# 基础部件
string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
set(HAL_PREFIX_HAL stm32${STM32_FAMILY_LOWER}xx_hal)
set(HAL_PREFIX_LL stm32${STM32_FAMILY_LOWER}xx_ll)
set(HAL_SUFFIX_EX _ex)

# 与组件无关但是被HALLIB使用到的头文件
set(HAL_HEADERS
        stm32${STM32_FAMILY_LOWER}xx_hal.h
        stm32${STM32_FAMILY_LOWER}xx_hal_def.h
        )

# 与组件无关但是被HALLIB使用到的源文件
set(HAL_SRCS
        stm32${STM32_FAMILY_LOWER}xx_hal.c
    )

# set(STM32HAL_SOURCES "" CACHE INTERNAL "") 
# set(STM32HAL_INCLUDE_DIR "" CACHE INTERNAL "") 
#-------------------------------------------------------------------------------------------------
# STM32HAL_FIND_COMPONENTS 变量由 find_package(STM32HAL COMPONENTS gpio tim REQUIRED)中关键字COMPONENTS
# 后面的列表(gpio tim)传入,下面这段代码的目的是希望 find_package() 中缺省 COMPONENTS时加载全部组件
#-------------------------------------------------------------------------------------------------
if(NOT STM32HAL_FIND_COMPONENTS)
  set(STM32HAL_FIND_COMPONENTS ${HAL_COMPONENTS})
  message(STATUS "No STM32HAL components selected, using all: ${STM32HAL_FIND_COMPONENTS}")
endif()

#-------------------------------------------------------------------------------------------------
# 要求 HAL_REQUIRED_COMPONENTS 列表中的元素均在 STM32HAL_FIND_COMPONENTS 内部,如果不在里面则强行追加
# 这么做的原因的 HAL_REQUIRED_COMPONENTS 中给出的文件是使用HAL库必须加载的文件
# 结果: STM32HAL_FIND_COMPONENTS = "${HAL_REQUIRED_COMPONENTS} gpio tim" = "rcc cortex pwr gpio tim"
#-------------------------------------------------------------------------------------------------
foreach(cmp ${HAL_REQUIRED_COMPONENTS})
    list(FIND STM32HAL_FIND_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
    if(${STM32HAL_FOUND_INDEX} LESS 0)
        list(APPEND STM32HAL_FIND_COMPONENTS ${cmp})
    endif()
endforeach()

#-------------------------------------------------------------------------------------------------
# 构建 HAL_SRCS 和 HAL_HEADERS, 这个两个包含所有可能的组件的列表
#-------------------------------------------------------------------------------------------------
foreach(compon ${STM32HAL_FIND_COMPONENTS})
  list(APPEND HAL_SRCS ${HAL_PREFIX_HAL}_${compon}.c)
  list(APPEND HAL_SRCS ${HAL_PREFIX_HAL}_${compon}${HAL_SUFFIX_EX}.c) 
  list(APPEND HAL_SRCS ${HAL_PREFIX_LL}_${compon}.c)

  list(APPEND HAL_HEADERS ${HAL_PREFIX_HAL}_${compon}.h)
  list(APPEND HAL_HEADERS ${HAL_PREFIX_HAL}_${compon}${HAL_SUFFIX_EX}.h)
  list(APPEND HAL_HEADERS ${HAL_PREFIX_LL}_${compon}.h)
endforeach()

#-------------------------------------------------------------------------------------------------
# 在指定路径下面查找 HAL_SRCS 中给出的所有可能的组合,找到之后就赋值给 STM32HAL_SOURCES 
#-------------------------------------------------------------------------------------------------
foreach(cmp ${HAL_SRCS})
  set(HAL_SRC_FILE HAL_SRC_FILE-NOTFOUND)
  find_file(HAL_SRC_FILE NAMES ${cmp}
    HINTS ${STM32Cube_ARCHIVE_FULLDIR}/Drivers/STM32${STM32_FAMILY}xx_HAL_Driver/Src
    NO_DEFAULT_PATH)
  if(HAL_SRC_FILE)
    message(STATUS "Found ${HAL_SRC_FILE}")
    list(APPEND STM32HAL_SOURCES ${HAL_SRC_FILE})
  endif()
endforeach()

#-------------------------------------------------------------------------------------------------
# 在指定路径下面查找 HAL_HEADERS 中给出的所有可能的组合,找到之后就赋值给 HAL_HEADER_FILES
#-------------------------------------------------------------------------------------------------
find_path(STM32HAL_INCLUDE_DIRS NAMES ${HAL_HEADERS}
  HINTS ${STM32Cube_ARCHIVE_FULLDIR}/Drivers/STM32${STM32_FAMILY}xx_HAL_Driver/Inc
  NO_DEFAULT_PATH
  )

#-------------------------------------------------------------------------------------------------
# 删除列表中重复的项目
#-------------------------------------------------------------------------------------------------
list(REMOVE_DUPLICATES STM32HAL_SOURCES)
list(REMOVE_DUPLICATES STM32HAL_INCLUDE_DIRS)

# message(STATUS "STM32HAL_INCLUDE_DIR=${STM32HAL_INCLUDE_DIR}")
# message(STATUS "STM32HAL_SOURCES=${STM32HAL_SOURCES}")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(STM32HAL DEFAULT_MSG STM32HAL_INCLUDE_DIRS STM32HAL_SOURCES)
# if(STM32_FAMILY STREQUAL "F0")
#     set(HAL_COMPONENTS adc can cec comp cortex crc dac dma flash gpio i2c
#                        i2s irda iwdg pcd pwr rcc rtc smartcard smbus
#                        spi tim tsc uart usart wwdg)

#     set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

#     # Components that have _ex sources
#     set(HAL_EX_COMPONENTS adc crc dac flash i2c pcd pwr rcc rtc smartcard spi tim uart)

#     # Components that have ll_ in names instead of hal_
#     set(HAL_LL_COMPONENTS "")

#     set(HAL_PREFIX stm32f0xx_)

#     set(HAL_HEADERS
#         stm32f0xx_hal.h
#         stm32f0xx_hal_def.h
#     )
#     set(HAL_SRCS
#         stm32f0xx_hal.c
#     )
# elseif(STM32_FAMILY STREQUAL "F1")
#     set(HAL_COMPONENTS adc can cec cortex crc dac dma eth flash gpio hcd i2c
#                        i2s irda iwdg nand nor pccard pcd pwr rcc rtc sd smartcard
#                        spi sram tim uart usart wwdg fsmc sdmmc usb)

#     set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

#     # Components that have _ex sources
#     set(HAL_EX_COMPONENTS adc dac flash gpio pcd rcc rtc tim)

#     # Components that have ll_ in names instead of hal_
#     set(HAL_LL_COMPONENTS fsmc sdmmc usb)

#     set(HAL_PREFIX stm32f1xx_)

#     set(HAL_HEADERS
#         stm32f1xx_hal.h
#         stm32f1xx_hal_def.h
#     )
#     set(HAL_SRCS
#         stm32f1xx_hal.c
#     )
# elseif(STM32_FAMILY STREQUAL "F2")
#     set(HAL_COMPONENTS adc can cortex crc cryp dac dcmi dma eth flash
#                        gpio hash hcd i2c i2s irda iwdg nand nor pccard
#                        pcd pwr rcc rng rtc sd smartcard spi sram tim
#                        uart usart wwdg fsmc sdmmc usb)

#     set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

#     # Components that have _ex sources
#     set(HAL_EX_COMPONENTS adc dac dma flash pwr rcc rtc tim)

#     # Components that have ll_ in names instead of hal_
#     set(HAL_LL_COMPONENTS fsmc sdmmc usb)

#     set(HAL_PREFIX stm32f2xx_)

#     set(HAL_HEADERS
#         stm32f2xx_hal.h
#         stm32f2xx_hal_def.h
#     )

#     set(HAL_SRCS
#         stm32f2xx_hal.c
#     )
# elseif(STM32_FAMILY STREQUAL "F3")
#     set(HAL_COMPONENTS adc can cec comp cortex crc dac dma flash gpio i2c i2s
#                        irda nand nor opamp pccard pcd pwr rcc rtc sdadc
#                        smartcard smbus spi sram tim tsc uart usart wwdg)

#     set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

#     set(HAL_EX_COMPONENTS adc crc dac flash i2c i2s opamp pcd pwr
#                           rcc rtc smartcard spi tim uart)

#     set(HAL_PREFIX stm32f3xx_)

#     set(HAL_HEADERS
#         stm32f3xx_hal.h
#         stm32f3xx_hal_def.h
#         )

#     set(HAL_SRCS
#         stm32f3xx_hal.c
#     )
# elseif(STM32_FAMILY STREQUAL "F4")
#   if(STM32CubeF4_ARCHIVE_VERSION STREQUAL "1.18.0")
#     # 所有组件的类别
#     set(HAL_COMPONENTS adc can cec cortex crc cryp dac dcmi dfsdm dma dma2d dsi eth flash
#       flash_ramfunc fmpi2c gpio hash hcd i2c i2s irda iwdg lptim ltdc mmc
#       nand nor pccard pcd pwr qspi rcc rng rtc sai sd sdram
#       smartcard spdifrx spi sram tim uart usart wwdg)

#     stm32f4xx_hal_adc.c
#     stm32f4xx_hal_adc.h
#     stm32f4xx_hal_adc_ex.c
#     stm32f4xx_hal_adc_ex.h

#     stm32f4xx_ll_adc.c
#     stm32f4xx_ll_adc.h
    

#     set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

#     # Components that have _ex sources
#     set(HAL_EX_COMPONENTS adc cryp dac dcmi dma flash fmpi2c hash i2c i2s ltdc pcd
#       pwr rcc rtc sai tim)

#     # Components that have ll_ in names instead of hal_
#     set(HAL_LL_COMPONENTS adc crc dac dma2d dma exit fmc fsmc gpio i2c lptim pwr rcc rng
#       rtc sdmmc spi tim usart usb utils)

#     set(HAL_PREFIX stm32f4xx_)

#     set(HAL_HEADERS
#       stm32f4xx_hal.h
#       stm32f4xx_hal_def.h
#       )

#     set(HAL_SRCS
#       stm32f4xx_hal.c
#       )
#   endif()
# elseif(STM32_FAMILY STREQUAL "F7")
#   if(STM32CubeF7_ARCHIVE_VERSION STREQUAL "1.8.0")
#     set(HAL_COMPONENTS adc can cec cortex crc cryp dac dcmi dfsdm dma dma2d dsi eth flash
#       gpio hash hcd i2c i2s irda iwdg jpeg lptim ltdc mdios mmc nand nor pcd
#       pwr qspi rcc rng rtc sai sd sdram smartcard smbus spdifrx spi
#       sram tim uart usart wwdg)

#     set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

#     # Components that have _ex sources
#     set(HAL_EX_COMPONENTS adc crc cryp dac dcmi dma flash hash i2c ltdc pcd
#       pwr rcc rtc sai smartcard tim)

#     # Components that have ll_ in names instead of hal_
#     set(HAL_LL_COMPONENTS adc crc dac dma dma2d exit fmc gpio i2c lptim pwr rcc rng rtc sdmmc spi
#       tim usart usb utils)

#     set(HAL_PREFIX stm32f7xx_)

#     set(HAL_HEADERS
#       stm32f7xx_hal.h
#       stm32f7xx_hal_def.h
#       )

#     set(HAL_SRCS
#       stm32f7xx_hal.c
#       )
#   endif()
# elseif(STM32_FAMILY STREQUAL "L0")
#     set(HAL_COMPONENTS adc comp cortex crc crs cryp dac dma exti firewall flash gpio i2c
#                        i2s irda iwdg lcd lptim lpuart pcd pwr rcc rng rtc smartcard
#                        smbus spi tim tsc uart usart utils wwdg)

#     set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

#     # Components that have _ex sources
#     set(HAL_EX_COMPONENTS adc comp crc cryp dac flash i2c pcd pwr rcc rtc smartcard tim uart usart)

#     # Components that have ll_ in names instead of hal_
#     set(HAL_LL_COMPONENTS crs exti lpuart utils)

#     set(HAL_PREFIX stm32l0xx_)

#     set(HAL_HEADERS
#         stm32l0xx_hal.h
#         stm32l0xx_hal_def.h
#     )
#     set(HAL_SRCS
#         stm32l0xx_hal.c
#     )
# elseif(STM32_FAMILY STREQUAL "L4")
#     set(HAL_COMPONENTS adc can comp cortex crc cryp dac dcmi dfsdm dma dma2d dsi 
#                        firewall flash flash_ramfunc gfxmmu gpio hash hcd i2c irda iwdg 
#                        lcd lptim ltdc nand nor opamp ospi pcd pwr qspi rcc rng rtc sai
#                        sd smartcard smbus spi sram swpmi tim tsc uart usart wwdg)

#     set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

#     # Components that have _ex sources
#     set(HAL_EX_COMPONENTS adc crc cryp dac dfsdm dma flash hash i2c ltdc 
#       opamp pcd pwr rcc rtc sai sd smartcard spi tim uart usart
#       )

#     # Components that have ll_ in names instead of hal_
#     set(HAL_LL_COMPONENTS adc comp crc crs dac dma dma2d exti fmc gpio i2c lptim lpuart
#       opamp pwr rcc rng rtc sdmmc spi swpmi tim usart usb utils)

#     set(HAL_PREFIX stm32l4xx_)

#     set(HAL_HEADERS
#         stm32l4xx_hal.h
#         stm32l4xx_hal_def.h
#     )

#     set(HAL_SRCS
#         stm32l4xx_hal.c
#     )
# endif()

# #-------------------------------------------------------------------------------------------------
# # STM32HAL_FIND_COMPONENTS 变量由 find_package(STM32HAL COMPONENTS gpio tim REQUIRED)中关键字COMPONENTS
# # 后面的列表(gpio tim)传入,下面这段代码的目的是希望 find_package() 中缺省 COMPONENTS时加载全部组件
# #-------------------------------------------------------------------------------------------------
# if(NOT STM32HAL_FIND_COMPONENTS)
#     set(STM32HAL_FIND_COMPONENTS ${HAL_COMPONENTS})
#     message(STATUS "No STM32HAL components selected, using all: ${STM32HAL_FIND_COMPONENTS}")
# endif()

# #-------------------------------------------------------------------------------------------------
# # 要求 HAL_REQUIRED_COMPONENTS 列表中的元素均在 STM32HAL_FIND_COMPONENTS 内部,如果不在里面则强行追加
# # 这么做的原因的 HAL_REQUIRED_COMPONENTS 中给出的文件是使用HAL库必须加载的文件
# # 结果: STM32HAL_FIND_COMPONENTS = "${HAL_REQUIRED_COMPONENTS} gpio tim" = "rcc cortex pwr gpio tim"
# #-------------------------------------------------------------------------------------------------
# foreach(cmp ${HAL_REQUIRED_COMPONENTS})
#     list(FIND STM32HAL_FIND_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
#     if(${STM32HAL_FOUND_INDEX} LESS 0)
#         list(APPEND STM32HAL_FIND_COMPONENTS ${cmp})
#     endif()
# endforeach()

# #-------------------------------------------------------------------------------------------------
# # 组装源文件与头文件
# #-------------------------------------------------------------------------------------------------
# foreach(cmp ${STM32HAL_FIND_COMPONENTS})
#   # 将 "rcc cortex pwr gpio tim" 依次在 HAL_COMPONENTS中查找,另外,从 find_package()中请求的组件必须在 HAL_COMPONENTS中存在,否则就报错
#   list(FIND HAL_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
#   if(${STM32HAL_FOUND_INDEX} LESS 0)
#     message(FATAL_ERROR "Unknown STM32HAL component: ${cmp}. Available components: ${HAL_COMPONENTS}")
#   else()
#     list(APPEND HAL_HEADERS ${HAL_PREFIX}hal_${cmp}.h)
#     list(APPEND HAL_SRCS ${HAL_PREFIX}hal_${cmp}.c)
#   endif()

#   # 将"rcc cortex pwr gpio tim" 依次在 HAL_EX_COMPONENTS中查找
#   list(FIND HAL_EX_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
#   if(${STM32HAL_FOUND_INDEX} GREATER_EQUAL 0))
#     list(APPEND HAL_HEADERS ${HAL_PREFIX}hal_${cmp}_ex.h)
#     list(APPEND HAL_SRCS ${HAL_PREFIX}hal_${cmp}_ex.c)
#   endif()

#   # 将 "rcc cortex pwr gpio tim" 依次在 HAL_LL_COMPONENTS中查找
#   list(FIND HAL_LL_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
#   if(${STM32HAL_FOUND_INDEX} GREATER_EQUAL 0)
#     list(APPEND HAL_HEADERS ${HAL_PREFIX}ll_${cmp}.h)
#     list(APPEND HAL_SRCS ${HAL_PREFIX}ll_${cmp}.c)
#   endif()
# endforeach()

# #-------------------------------------------------------------------------------------------------
# # 删除列表中重复的项目
# #-------------------------------------------------------------------------------------------------
# list(REMOVE_DUPLICATES HAL_HEADERS)
# list(REMOVE_DUPLICATES HAL_SRCS)

# #-------------------------------------------------------------------------------------------------
# # 查找头文件所在目录路径
# #-------------------------------------------------------------------------------------------------
# string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
# find_path(STM32HAL_INCLUDE_DIR NAMES ${HAL_HEADERS}
#     HINTS ${STM32Cube_DIR}/Drivers/STM32${STM32_FAMILY}xx_HAL_Driver/Inc
#     NO_DEFAULT_PATH
# )
# if(NOT IS_DIRECTORY STM32HAL_INCLUDE_DIR)
# message(FATAL_ERROR "Not find STM32HAL_INCLUDE_DIR, please check it!")
# endif()

# #-------------------------------------------------------------------------------------------------
# # 查找源文件的全路径
# #-------------------------------------------------------------------------------------------------
# foreach(HAL_SRC ${HAL_SRCS})
#     string(MAKE_C_IDENTIFIER "${HAL_SRC}" HAL_SRC_CLEAN)
#     set(HAL_${HAL_SRC_CLEAN}_FILE HAL_SRC_FILE-NOTFOUND)
#     find_file(HAL_${HAL_SRC_CLEAN}_FILE ${HAL_SRC}
#         HINTS ${STM32Cube_DIR}/Drivers/STM32${STM32_FAMILY}xx_HAL_Driver/Src
#         NO_DEFAULT_PATH
#     )
#     list(APPEND STM32HAL_SOURCES ${HAL_${HAL_SRC_CLEAN}_FILE})
# endforeach()

# include(FindPackageHandleStandardArgs)

# find_package_handle_standard_args(STM32HAL DEFAULT_MSG STM32HAL_INCLUDE_DIR STM32HAL_SOURCES)
