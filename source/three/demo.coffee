jQuery ($)->

  TTT = THREE

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
      @camera.position.set 0, 4, 5
      @camera.lookAt new TTT.Vector3 -0.5, 4, 1
    initializeRenderer: ()->
      @renderer = new TTT.WebGLRenderer canvas: @canvas
      @renderer.shadowMapEnabled = true
      @renderer.shadowMapCullFace = THREE.CullFaceBack
    initializeRoom: ()->
      @room = new Room @scene, @loader, @roomFinished.bind(this)
      @updater.add @room
    roomFinished: ()->
      @updater.add @room
      @initializeBadgeLights @room.badgeLights()
      @initializeDirLight()
      @initializeComputer()
      @initializeCamera()
      requestAnimationFrame @renderLoop.bind(this)
    initializeDirLight: ()->
      @dirLight = new DirLight @scene, @room.displayPanel()
    initializeBadgeLights: (badgeLeds)->
      @badgeLights = for light in badgeLeds
        l = new TTT.PointLight 0xddddff, 0.5, 1
        l.position.setFromMatrixPosition light.matrixWorld
        l.updateMatrix()
        @scene.add l
        light.children[0].material.emissive = new TTT.Color 0xddddff
        l
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
        c.castShadow = true
        c.receiveShadow = true
        c.frustrumCulling = false

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
    badgeLights: ()->
      return @_badgeLights if @badgeLight?
      @_badgeLights = []
      @scene.traverse (c) =>
        if c.name == 'BsdgeEye1'
          @_badgeLights.push c
      return @_badgeLights

  class Computer extends Renderable
    constructor: (@scene, @displayPanel)->
      @makeLight()
      @makeScreen()
    makeLight: ()->
      @light = new THREE.PointLight 0xF5B34A, .75, 10
      @light.position.setFromMatrixPosition @displayPanel.matrixWorld
      @light.updateMatrix()
      @scene.add @light
      help = new THREE.PointLightHelper @light, 1
      @scene.add help
    makeScreen: ()->
      mesh = @displayPanel.children[0]
      mesh.receiveShadow = false
      mesh.material =
        new TTT.MeshPhongMaterial
          color: new TTT.Color 0x444444
          emissive: new TTT.Color 0xF5B34A
          specular: new TTT.Color 0xffffff
          shininess: 30

  class DirLight extends Renderable
    constructor: (@scene, @target)->
      @light = new THREE.DirectionalLight 0xffffff, 0.5
      @light.position.set -20, 10, 25
      @light.castShadow = true
      @light.shadowMapWidth = 2048
      @light.shadowMapHeight = 2048

      shadowCameraSize = 8

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
      xCycle = 0.2 * Math.sin(Date.now() / 10000.0)
      yCycle = 0.5 * Math.cos(Date.now() / 20000.0)
      @light.position.set(-21 + xCycle, 10 + yCycle, 25)


  window.hackerRoom = new HackerRoom(document.getElementById 'actualScene')
