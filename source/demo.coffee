jQuery ($)->

  TTT = THREE

  AMBER = 0xF5B34A

  class HackerRoom
    constructor: (@canvas)->
      @updater = new Updater
      @initializeLoader()
      @initializeScene()
      @initializeRoom()
    initializeLoader: ()->
      @loader = new TTT.LoadingManager()
    initializeScene: ()->
      @scene = new TTT.Scene
    initializeCamera: ()->
      @camera = new Camera @canvas, @scene
      @updater.add @camera
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

  class TexturedMesh
    constructor: (@object)->
      @mesh = @object.children[0]
      @createTexture()
    createTexture: ()->
      @texture = TTT.ImageUtils.loadTexture @textureFilePicker()
      @texture.anisotropy = 16
      @texture.repeat.set 1, 1
      @texture.mapFilter = @texture.magFilter = TTT.LinearFilter
      @texture.mapping = TTT.UVMapping
      @mesh.material =
        new TTT.MeshPhongMaterial
          color: new TTT.Color 0x444444
          emissive: new TTT.Color 0x444444
          specular: new TTT.Color 0x444444
          shininess: 10
          map: @texture
    textureFilePicker: ()-> @textureFile

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
        else if c.name == 'BeerBottle'
          @bottle = new Bottle c
        else if c.name == 'paper'
          @paper = new Paper c
        else if c.name.match /Cylinder00\d/
          @cans ?= []
          @cans.push new Can c
        else if c.name == 'odroid heartbeat'
          @heartbeat = new OdroidHeartbeat c
        else if c.name.match /badge/i
          @badge ?= new Badge
          @badge.addObject c
          
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

  class IdaBook extends TexturedMesh
    textureFile: 'hacker_room/uv-idabook.png'

  class Bottle extends TexturedMesh
    textureFile: 'hacker_room/uv-bottle.png'

  class Paper extends TexturedMesh
    textureFilePicker: ()->
      idx = Math.floor(Math.random() * @textureNames.length)
      pick = @textureNames[idx]
      "hacker_room/#{pick}"
    textureNames: ['choripan.png']

  class Can extends TexturedMesh
    textureFile: 'hacker_room/uv-can.png'

  class OdroidHeartbeat
    constructor: (@object3d)->
      @light = @object3d.children[0]
      @light.distance = 5
      hackerRoom.updater.add this
    render: ()->
      cycle = 0.1 + Math.sin(Date.now() * 0.005)
      if cycle > 1
        @light.intensity = 0.25
      else
        @light.intensity = 0

  class Badge
    constructor: ()->
      @eyes = []
      @eyeMaterials = []
      hackerRoom.updater.add this
    addObject: (object)->
      if object.name.match /BadgeEye/
        @addEye object
      else if object.name == 'badge-light'
        @addLight object
    addEye: (eye)->
      @eyes.push eye
      @eyeMaterials.push eye.children[0].material
    addLight: (light)->
      @light = light.children[0]
      @light.distance = 5
    render: ()->
      cycle = 0.1 + Math.sin((Date.now() * 0.003) + .1)
      if cycle > 1
        @light?.intensity = 0.5
        i.emissive.set 0xaaccff for i in @eyeMaterials
      else
        @light?.intensity = 0.25
        i.emissive.set 0x000000 for i in @eyeMaterials

  class Computer extends Renderable
    constructor: (@scene, @displayPanel)->
      @makeScreen()
    makeScreen: ()->
      mesh = @displayPanel.children[0]
      mesh.receiveShadow = false
      @screenTexture = TTT.ImageUtils.loadTexture 'hacker_room/legitbs-2015-text.png'
      @screenTexture.anisotropy = 16
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

  class Camera extends Renderable
    constructor: (@canvas, @scene)->
      @initializeCamera()
      @initializeRenderer()
    initializeCamera: ()->
      @camera = new TTT.PerspectiveCamera(55,
        (1.0 * @canvas.width) / @canvas.height,
        0.1,
        1000)
      @camera.position.set 0, 4.5, 5
    initializeRenderer: ()->
      @renderer = new TTT.WebGLRenderer
        canvas: @canvas
        antialias: true
        alpha: true
      @renderer.shadowMapEnabled = true
      @renderer.shadowMapCullFace = THREE.CullFaceBack
    render: ()->
      xCycle = -0.25 - (0.08 * Math.cos(Date.now() / 10000.0))
      yCycle = 0.1 * Math.sin((Date.now() + 1000) / 20000.0)
      @camera.rotation.set xCycle, yCycle, 0
      @renderer.render @scene, @camera

  class DirLight extends Renderable
    constructor: (@scene, @target)->
      @light = new THREE.DirectionalLight 0xffffff, 0.15
      @light.position.set -20, 10, 25
      @light.castShadow = true
      @light.shadowMapWidth = 2048
      @light.shadowMapHeight = 2048
      @light.onlyShadow = false

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
