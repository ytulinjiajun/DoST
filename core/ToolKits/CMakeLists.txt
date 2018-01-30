#-------------------------------------------------------------------------------------------------
# STM32Cube 管理器
#-------------------------------------------------------------------------------------------------
set(STM32CubeF4_ARCHIVE "stm32cubef4.zip")
set(STM32CubeF4_ARCHIVE_VERSION "1.18.0")
set(STM32CubeF4_ARCHIVE_DIR "STM32Cube_FW_F4_V${STM32CubeF4_ARCHIVE_VERSION}")

set(STM32CubeF7_ARCHIVE "stm32cubef7.zip")
set(STM32CubeF7_ARCHIVE_VERSION "1.8.0")
set(STM32CubeF7_ARCHIVE_DIR "STM32Cube_FW_F7_V${STM32CubeF7_ARCHIVE_VERSION}")

set(STM32Cube_ARCHIVE_BASEURL "http://www.st.com/st-web-ui/static/active/en/st_prod_software_internet/resource/technical/software/firmware")

set(STM32Cube_ARCHIVE "${STM32Cube${STM32_FAMILY}_ARCHIVE}")
set(STM32Cube_ARCHIVE_VERSION "${STM32Cube${STM32_FAMILY}_ARCHIVE_VERSION}")
set(STM32Cube_ARCHIVE_DIR "${STM32Cube${STM32_FAMILY}_ARCHIVE_DIR}")
set(STM32Cube_ARCHIVE_FULL "${STM32_TOOLKITS_DIR}/STM32Cube/STM32Cube${STM32_FAMILY}/${STM32Cube${STM32_FAMILY}_ARCHIVE}")
set(STM32Cube_ARCHIVE_FULLDIR "${STM32_TOOLKITS_DIR}/STM32Cube/STM32Cube${STM32_FAMILY}/${STM32Cube${STM32_FAMILY}_ARCHIVE_DIR}" CACHE INTERNAL "STM32Cube Dir")

#-------------------------------------------------------------------------------------------------
# 如果已经存在工具包,则略过,如果不存在,则从官网下载 
#-------------------------------------------------------------------------------------------------
if(EXISTS "${STM32Cube_ARCHIVE_FULL}") 
  message(STATUS "Using already-downloaded archive: ${STM32Cube${STM32_FAMILY}_ARCHIVE}")
else()
  message(STATUS "From st.com, downloading ${STM32Cube${STM32_FAMILY}_ARCHIVE}")
  file(DOWNLOAD "${STM32Cube_ARCHIVE_BASEURL}/${STM32Cube${STM32_FAMILY}_ARCHIVE}"
    "${STM32Cube_ARCHIVE_FULL}" SHOW_PROGRESS)
endif()

#-------------------------------------------------------------------------------------------------
# 解压下载的工具包(zip格式)
#-------------------------------------------------------------------------------------------------
if(EXISTS "${STM32Cube_ARCHIVE_FULLDIR}")
  message(STATUS "Using already-extracted path: ${STM32Cube_ARCHIVE_FULLDIR}")
else()
  execute_process(COMMAND unzip -o -d ${STM32_TOOLKITS_DIR}/STM32Cube/STM32Cube${STM32_FAMILY} ${STM32Cube_ARCHIVE_FULL})
endif()



# add_subdirectory(STM32Cube${STM32_FAMILY})


# # 指示应将此目标 debs 添加到默认的构建目标，以便每次都运行（不能将 ALL 当成命令）
# add_custom_target(debs ALL)

# # Install everything into a subdirectory so that we can package it from there.
# # set(STM32F1_CHIP_TYPES HD HD_VL MD MD_VL LD LD_VL XL)
# set(STM32F4_CHIP_TYPES 401xx 40_41xxx 427_437xx 429_439xx)
# set(STM32_CHIP_TYPES "${STM32${STM32_FAMILY}_CHIP_TYPES}")
# set(STM32${STM32_FAMILY}_StdPeriphLib_DIR "${STM_ARCHIVE_FULLDIR}")

# # Add targets for building cmsis libraries
# set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install/usr/${TARGET_TRIPLET}/")
# add_subdirectory(../cmsis ${CMAKE_CURRENT_BINARY_DIR}/cmsis)

# # Add targets for building stdperiph libraries, which need the cmsis headers
# get_property(CMSIS_INCLUDE_DIR DIRECTORY ../cmsis PROPERTY INCLUDE_DIRECTORIES)
# add_subdirectory(../stdperiph ${CMAKE_CURRENT_BINARY_DIR}/stdperiph)

# #-------------------------------------------------------------------------------------------------
# # (1) install_stm32f4 是一个用户自定义的伪目标,它总会被构建,默认默认情况下，没有任何东西依赖于该伪目标目标,
# # (2) 可以使用 add_dependencies()命令添加依赖关系
# #-------------------------------------------------------------------------------------------------
# add_custom_target(install_stm32${STM32_FAMILY_LOWER})
# add_dependencies(install_stm32${STM32_FAMILY_LOWER}
#                  cmsis_${STM32_FAMILY_LOWER}
#                  stdperiph_${STM32_FAMILY_LOWER})

# set(MODULES_DIR ${CMAKE_CURRENT_BINARY_DIR}/install/usr/share/cmake-2.8/Modules)
# add_custom_command(TARGET install_stm32${STM32_FAMILY_LOWER} POST_BUILD
#   COMMAND ${CMAKE_COMMAND} -P cmake_install.cmake
#   COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules/FindCMSIS.cmake
#           ${MODULES_DIR}/FindCMSIS.cmake
#   COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules/FindStdPeriphLib.cmake
#           ${MODULES_DIR}/FindStdPeriphLib.cmake
#   COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/../toolchain_stm32.cmake
#           ${MODULES_DIR}/toolchain_stm32.cmake
#   COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/../toolchain_stm32${STM32_FAMILY_LOWER}.cmake
#           ${MODULES_DIR}/toolchain_stm32${STM32_FAMILY_LOWER}.cmake
# )

# #-------------------------------------------------------------------------------------------------
# # Create package.  stm32f4-stdperiph_1.8.0_F4_all.deb
# #-------------------------------------------------------------------------------------------------
# set(PACKAGE_NAME "stm32${STM32_FAMILY_LOWER}-stdperiph")
# set(PACKAGE_VERSION "${STM_ARCHIVE_VERSION_${STM32_FAMILY}}")
# set(PACKAGE_FILENAME "${PACKAGE_NAME}_${PACKAGE_VERSION}_all.${PACKAGE_TYPE}")

# add_custom_command(
#   OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_FILENAME}
#   COMMAND fpm -a all -s dir -t ${PACKAGE_TYPE} -n ${PACKAGE_NAME}
#               -d gcc-arm-none-eabi
#               -v ${PACKAGE_VERSION} -C install usr
# )
# add_custom_target(${PACKAGE_FILENAME}_
#   DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_FILENAME}
# )
# add_dependencies(${PACKAGE_FILENAME}_ install_stm32${STM32_FAMILY_LOWER})
# add_dependencies(debs ${PACKAGE_FILENAME}_)
