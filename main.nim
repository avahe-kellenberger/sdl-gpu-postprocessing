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

  let screen = init(
    uint16 WINDOW_WIDTH,
    uint16 WINDOW_HEIGHT,
    uint32 WINDOW_ALLOW_HIGHDPI and int(INIT_ENABLE_VSYNC)
  )

  if screen == nil:
    raise newException(Exception, "Failed to init SDL!")

  var refreshRate = 60
  if screen.context != nil:
    let window = getWindowFromId(screen.context.windowID)
    window.setWindowTitle("Post-processing shader testing")
    var displayMode: DisplayMode
    discard window.getWindowDisplayMode(displayMode.addr)
    refreshRate = displayMode.refreshRate

  # Create shader program
  let shader = newShader("./assets/common.vert", "./assets/postprocess.frag")
  let hexagonImage = loadImage("./assets/hexagon.png")

  # Loop until exit
  var
    shouldExit = false
    previousTimeNanos: int64 = getMonoTime().ticks
    deltaTime: float = 0
    event: Event

  let
    image = createImage(screen.w, screen.h, FORMAT_RGBA)
    renderTarget = loadTarget(image)

  while not shouldExit:
    # Render
    screen.clearColor(CLEAR_COLOR)
    renderTarget.clearColor(CLEAR_COLOR)
    
    # Render some images
    hexagonImage.blit(nil, renderTarget, WINDOW_WIDTH * 0.5, WINDOW_HEIGHT * 0.5)

    # Post-processing shader
    shader.render(currTimeSeconds)

    renderTarget.image.blit(nil, screen, WINDOW_WIDTH * 0.5, WINDOW_HEIGHT * 0.5)

    # Present the render data on the window
    flip(screen)

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
  freeImage(hexagonImage)

