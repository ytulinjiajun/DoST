#-------------------------------------------------------------------------------------------------
#                                  STM32F407ZGT6
#
#                   Author linjiajun          2017-12-01
#-------------------------------------------------------------------------------------------------
set(USER_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/Inc)

find_package(CMSIS REQUIRED)
find_package(STM32HAL COMPONENTS gpio uart usart dma  REQUIRED)
find_package(STM32SYSTEM REQUIRED)

include_directories(
  ${CMSIS_INCLUDE_DIRS}
  ${STM32HAL_INCLUDE_DIRS}
  ${USER_INCLUDE_DIRS}
  ${SYSTEM_INCLUDE_DIRS}
)

add_subdirectory(User)
add_subdirectory(Drivers)

get_property(PROJECT_SOURCES GLOBAL PROPERTY PROJECT_SOURCE)

if(Debug)
message("CMSIS_INCLUDE_DIRS=${CMSIS_INCLUDE_DIRS}\n")
message("STM32HAL_INCLUDE_DIR=${STM32HAL_INCLUDE_DIRS}\n")
message("USER_INCLUDE_DIRS=${USER_INCLUDE_DIRS}\n")
message("SYSTEM_INCLUDE_DIRS=${SYSTEM_INCLUDE_DIRS}\n")

message("PROJECT_SOURCES=${PROJECT_SOURCES}\n")
message("SYSTEM_SOURCES=${SYSTEM_SOURCES}\n")
message("CMSIS_SOURCES=${CMSIS_SOURCES}\n")
message("STM32HAL_SOURCES=${STM32HAL_SOURCES}\n")
endif()



add_executable(${CMAKE_PROJECT_NAME} ${PROJECT_SOURCES} ${SYSTEM_SOURCES} ${CMSIS_SOURCES} ${STM32HAL_SOURCES})

stm32_set_target_properties(${CMAKE_PROJECT_NAME})
stm32_add_hex_bin_target(${CMAKE_PROJECT_NAME})

if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
  message(STATUS "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
  message(STATUS "CMAKE_C_FLAGS=${CMAKE_C_FLAGS}")
  message(STATUS "CMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}")
  message(STATUS "CMAKE_C_FLAGS_DEBUG=${CMAKE_C_FLAGS_DEBUG}")

  stm32_add_debug_target(${CMAKE_PROJECT_NAME})
endif()

