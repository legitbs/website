jQuery ($)->

  TTT = THREE

  AMBER = 0xF5B34A

  class HackerRoom
    constructor: (@canvas)->
      @updater = new Updater
      @initializeLoader()
      @initializeScene()
      @initializeRoom()
      @initializeRenderer()
    initializeLoader: ()->
      @loader = new TTT.LoadingManager()
    initializeScene: ()->
      @scene = new TTT.Scene
    initializeCamera: ()->
      @camera = new TTT.PerspectiveCamera(75,
        (1.0 * @canvas.width) / @canvas.height,
        0.1,
        1000)
      @camera.position.set 0, 4, 4
      @camera.lookAt new TTT.Vector3 -0.25, 4.0, 1
    initializeRenderer: ()->
      @renderer = new TTT.WebGLRenderer canvas: @canvas
      @renderer.shadowMapEnabled = true
      @renderer.shadowMapCullFace = THREE.CullFaceBack
    initializeRoom: ()->
      @room = new Room @scene, @loader, @roomFinished.bind(this)
      @updater.add @room
    roomFinished: ()->
      @updater.add @room
      @initializeDirLight()
      @initializeComputer()
      @initializeCamera()
      requestAnimationFrame @renderLoop.bind(this)
    initializeDirLight: ()->
      @dirLight = new DirLight @scene, @room.displayPanel()
      @updater.add @dirLight
    initializeComputer: ()->
      @computer = new Computer @scene, @room.displayPanel()
    renderLoop: ()->
      @updater.render()
      @renderer.render @scene, @camera
      requestAnimationFrame @renderLoop.bind(this)

  class Updater
    constructor: ()->
      @list = []
    add: (obj)->
      @list.push obj
    render: ()->
      e.render() for e in @list

  class Renderable
    render: ()->
      # noop

  class Room extends Renderable
    constructor: (@scene, @manager, @callback)->
      @loader = new THREE.ColladaLoader @manager
      @loader.load 'hacker_room.dae', @loaded.bind(this)
    loaded: (o)->
      @sceneParent = o.scene.children[0]
      @sceneParent.scale.set 0.15, 0.15, 0.15
      @sceneParent.position.set -6, -2, -2
      @sceneParent.rotation.x = 3.0/2.0 * Math.PI
      @sceneParent.rotation.z = 3.0/2.0 * Math.PI
      @sceneParent.updateMatrix()

      @sceneParent.traverse (c) =>
        c.castShadow = true unless c.type == 'PointLight'
        c.receiveShadow = true
        c.frustrumCulling = false
        if c.name == 'IDA Book'
          @idabook = new IdaBook c

      @scene.add @sceneParent
      @sceneParent.updateMatrixWorld()
      @didLoad = true
      @callback()
    displayPanel: ()->
      return @_displayPanel if @_displayPanel?
      @scene.traverse (c) =>
        if c.name == 'display-panel'
          @_displayPanel = c
      return @_displayPanel

  class IdaBook
    constructor: (@object)->
      @mesh = @object.children[0]
      @createTexture()
    createTexture: ()->
      @texture = TTT.ImageUtils.loadTexture 'uv-idabook.png'
      @texture.anisotropy = 0
      @texture.repeat.set 0, 0
      @texture.mapFilter = @texture.magFilter = TTT.LinearFilter
      @texture.mapping = TTT.UVMapping
      @mesh.material =
        new TTT.MeshPhongMaterial
          color: new TTT.Color 0x444444
          emissive: new TTT.Color 0x444444
          specular: new TTT.Color 0x444444
          shininess: 10
          map: @texture

  class Computer extends Renderable
    constructor: (@scene, @displayPanel)->
      @makeScreen()
    makeScreen: ()->
      mesh = @displayPanel.children[0]
      mesh.receiveShadow = false
      @screenTexture = TTT.ImageUtils.loadTexture 'legitbs-2015-text.png'
      @screenTexture.anisotropy = 1
      @screenTexture.repeat.set 1, 1
      @screenTexture.mapFilter = @screenTexture.magFilter = TTT.LinearFilter
      @screenTexture.mapping = TTT.UVMapping
      @screenTexture.wrapS = @screenTexture.wrapT = TTT.ClampToEdgeWrapping
      mesh.material =
        new TTT.MeshPhongMaterial
          color: new TTT.Color 0x444444
          emissive: new TTT.Color AMBER
          specular: new TTT.Color 0xffffff
          shininess: 30
          map: @screenTexture

  class DirLight extends Renderable
    constructor: (@scene, @target)->
      @light = new THREE.DirectionalLight 0xffffff, 0.5
      @light.position.set -20, 10, 25
      @light.castShadow = true
      @light.shadowMapWidth = 2048
      @light.shadowMapHeight = 2048

      shadowCameraSize = 10

      @light.shadowCameraLeft = -shadowCameraSize
      @light.shadowCameraRight = shadowCameraSize
      @light.shadowCameraTop = shadowCameraSize
      @light.shadowCameraBottom = -shadowCameraSize

      @light.shadowCameraNear = 1
      @light.shadowCameraFar = 200
      @light.shadowBias = -0.0001
      @light.shadowDarkness = 0.35

      @light.shadowCameraVisible = true

      @light.lookAt @target.position

      @scene.add @light
    render: () ->
      xCycle = 0.4 * Math.sin(Date.now() / 10000.0)
      yCycle = 0.8 * Math.cos(Date.now() / 20000.0)
      @light.position.set(-21 + xCycle, 10 + yCycle, 25)


  window.hackerRoom = new HackerRoom(document.getElementById 'actualScene')
