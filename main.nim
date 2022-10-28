import
  sdl2_nim/[sdl, sdl_gpu],
  std/monotimes,
  shader as shaderModule

const
  WINDOW_WIDTH = 800
  WINDOW_HEIGHT = 600
  ONE_BILLION = 1_000_000_000
  CLEAR_COLOR = Color(r: 80, g: 80, b: 80)
  BLUE = Color(r: 0, g: 0, b: 255)

template currTimeSeconds: float =
  float(getMonoTime().ticks) / float(ONE_BILLION)

when isMainModule:
  when defined(debug):
    setDebugLevel(DEBUG_LEVEL_MAX)

  shaderModule.resolution[0] = WINDOW_WIDTH
  shaderModule.resolution[1] = WINDOW_HEIGHT

  let target = init(uint16 WINDOW_WIDTH, uint16 WINDOW_HEIGHT, uint32 WINDOW_ALLOW_HIGHDPI and int(INIT_ENABLE_VSYNC))
  if target == nil:
    raise newException(Exception, "Failed to init SDL!")

  var refreshRate = 60
  if target.context != nil:
    let window = getWindowFromId(target.context.windowID)
    window.setWindowTitle("Post-processing shader testing")
    var displayMode: DisplayMode
    discard window.getWindowDisplayMode(displayMode.addr)
    refreshRate = displayMode.refreshRate

  # Create shader program
  let hexagonShader = newShader("./assets/common.vert", "./assets/hexagons.frag")

  # Loop until exit
  var
    shouldExit = false
    previousTimeNanos: int64 = getMonoTime().ticks
    deltaTime: float = 0
    event: Event

  while not shouldExit:
    # Render
    target.clearColor(CLEAR_COLOR)
    
    # Post-processing shader
    hexagonShader.render(currTimeSeconds)
    target.rectangleFilled(0, 0, 800, 600, BLUE)

    # Present the render data on the window
    flip(target)

    let time = getMonoTime().ticks
    let elapsedNanos = time - previousTimeNanos
    previousTimeNanos = time

    deltaTime = 1.0 / float(refreshRate)

    while pollEvent(event.addr) != 0:
      if event.kind == KEYDOWN and event.key.keysym.sym == K_ESCAPE:
        shouldExit = true

  # Teardown
  sdl_gpu.quit()
  logInfo(LogCategoryApplication, "SDL shutdown completed")

