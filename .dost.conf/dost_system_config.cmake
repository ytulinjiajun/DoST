#-------------------------------------------------------------------------------------------------
# 配置一些常用的目录路径
#-------------------------------------------------------------------------------------------------
set(STM32_TOP_DIR ${CMAKE_CURRENT_LIST_DIR}/.. CACHE STRING "Default DoST Top DIR")
set(STM32_SCRIPTS_DIR ${STM32_TOP_DIR}/core/Scripts CACHE STRING "Default DoST Scripts DIR")
set(STM32_TOOLKITS_DIR ${STM32_TOP_DIR}/core/ToolKits CACHE STRING "Default ToolKits DIR")
set(CROSS_TOOLCHAIN_PREFIX "${STM32_TOP_DIR}/core/gcc-arm-none-eabi-6-2017-q2-update" CACHE STRING "")
#-------------------------------------------------------------------------------------------------
# 配置默认的 include() 和 find_package()搜索路径
# 配置默认的工具链文件
# 配置默认的芯片类型
#-------------------------------------------------------------------------------------------------
set(CMAKE_MODULE_PATH ${STM32_SCRIPTS_DIR} ${CMAKE_MODULE_PATH} CACHE STRING "Default Search path")
set(CMAKE_TOOLCHAIN_FILE ${STM32_SCRIPTS_DIR}/toolchain_stm32.cmake CACHE FILEPATH "Default toolchain file")
set(STM32_CHIP STM32F407ZGT6 CACHE STRING "Default STM32_CHIP")
# set(CMAKE_EXPORT_COMPILE_COMMANDS 1 CACHE STRING "uesed to rtags")


