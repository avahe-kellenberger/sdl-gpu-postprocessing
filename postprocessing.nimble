# Package

version                            = "0.1.0"
author                             = "Avahe Kellenberger"
description                        = "sdl_gpu post-processing shader example"
license                            = "GPLv2.0"

# Dependencies

requires "nim >= 1.6.8"
requires "https://github.com/avahe-kellenberger/sdl2_nim#head"

task runr, "Runs the example":
  exec "nim r -d:release main.nim"

task rund, "Runs the example in debug mode":
  exec "nim r -d:debug main.nim"


