# aux_source_directory(. hardware_sources)

set(drivers_source_list
  led.c
  )

stm32_add_project_source(drivers_source_list)
