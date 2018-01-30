set(SYSTEM_HEADERS
  delay.h
  sys.h
  usart.h
  )

set(SYSTEM_SRCS
  delay.c
  sys.c
  usart.c
  newlib.c
  )

find_path(SYSTEM_INCLUDE_DIRS NAMES ${SYSTEM_HEADERS}
  HINTS ${STM32_TOOLKITS_DIR}/SYSTEM/Inc
  NO_DEFAULT_PATH
  )

foreach(cmp ${SYSTEM_SRCS})
  set(SYSTEM_SRCS_FILE SYSTEM_SRCS_FILE-NOTFOUND)
  find_file(SYSTEM_SRCS_FILE NAMES ${cmp}
    HINTS ${STM32_TOOLKITS_DIR}/SYSTEM/Src
    NO_DEFAULT_PATH
    )
  if(SYSTEM_SRCS_FILE)
    message(STATUS "Found ${SYSTEM_SRCS_FILE}")
    list(APPEND SYSTEM_SOURCES ${SYSTEM_SRCS_FILE})
  endif()
endforeach()

list(REMOVE_DUPLICATES SYSTEM_INCLUDE_DIRS)
list(REMOVE_DUPLICATES SYSTEM_SOURCES)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(STM32SYSTEM DEFAULT_MSG SYSTEM_INCLUDE_DIRS SYSTEM_SOURCES)
