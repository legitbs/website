jQuery ($)->

  window.lightdebug = true

  TTT = THREE

  AMBER = 0xF5B34A

  class HackerRoom
    constructor: (@canvas)->
      @updater = new Updater
      @initializeScene()
      @initializeRoom()
    initializeScene: ()->
      @scene = new TTT.Scene
      @scene.textureLoader = new TTT.TextureLoader
    initializeCamera: (sequences)->
      @camera = new Camera @canvas, @scene
      @camera.setSequences sequences
      @updater.add @camera
    initializeRoom: ()->
      @room = new Room @scene, @roomFinished.bind(this)
      @updater.add @room
    roomFinished: ()->
      @updater.add @room
      # @initializeDirLight()
      # @initializeComputer()
      @initializeCamera(@room.cameraSequences)
      requestAnimationFrame @renderLoop.bind(this)
    # initializeDirLight: ()->
    #   @dirLight = new DirLight @scene, @room.displayPanel()
    #   @updater.add @dirLight
    # initializeComputer: ()->
    #   @computer = new Computer @scene, @room.displayPanel()
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
    setupTexture: (texture)->
      texture.anisotropy = 16
      texture.repeat.set 1, 1
      texture.wrapS = texture.wrapT = TTT.RepeatWrapping
      texture.mapFilter = texture.magFilter = TTT.LinearFilter
      texture.mapping = TTT.UVMapping
      texture

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
    constructor: (@scene, @callback)->
      @loader = new THREE.ColladaLoader
      @loader.load 'scene/legit-stage-2017.DAE', @loaded.bind(this)
    loaded: (o)->
      @sceneParent = o.scene.children[0]
      @sceneParent.rotation.x = 0
      # @sceneParent.position.set 80, -180, -10
      @sceneParent.updateMatrix()

      @sceneParent.traverse (c) =>
        c.castShadow = true unless c.type == 'PointLight'
        c.receiveShadow = true
        c.frustrumCulling = false
        if c.name == 'Amp'
          @amp = new Amp c, @scene
        else if c.name.match /^WorkLight\d+/
          @workLights ?= []
          @workLights.push new WorkLight c, @scene
        else if c.name.match /Cam\d+$/
          @cameras ?= {}
          @cameras[c.name] = c
        else if m = c.name.match /^(.+Cam\d+).Target$/
          @cameraTargets ?= {}
          @cameraTargets[m[1]] = c
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

      @buildCameraSequences()
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
    buildCameraSequences: ()->
      @cameraSequences = {}
      for name, camera of @cameras
        target = @cameraTargets[name]
        [match, sequenceName, idx] = name.match(/^(.+)Cam(\d)+$/)
        @cameraSequences[sequenceName] ?= new CameraSequence()
        @cameraSequences[sequenceName].register(camera, target, idx)
      for _name, sequence of @cameraSequences
        sequence.compact()

  class Amp extends Renderable
    constructor: (@object, @scene)->
      @mesh = @object.children[0]
      @textureMaterials(@mesh.material)
    textureMaterials: (parentMaterial)->
      for mat in parentMaterial.materials
        switch mat.name
          when "control panel"
            cp_mat = mat
            cp_mat.color = new TTT.Color(0x0)
            st = @setupTexture
            @scene.textureLoader.load @diffuseTextureFile, (texture)->
              cp_mat.map = st(texture)
              cp_mat.needsUpdate = true
            @scene.textureLoader.load @specularTextureFile, (texture)->
              cp_mat.specularMap = st(texture)
              cp_mat.needsUpdate = true
          when "speaker cover"
            sk_mat = mat
            sk_mat.color = new TTT.Color(0x0)
            st = @setupTexture
            @scene.textureLoader.load @diffuseTextureFile, (texture)->
              sk_mat.map = st(texture)
              sk_mat.needsUpdate = true
            @scene.textureLoader.load @bumpTextureFile, (texture)->
              sk_mat.bumpMap = st(texture)
              sk_mat.needsUpdate = true
    diffuseTextureFile: 'scene/amp-labels-diffuse.png'
    specularTextureFile: 'scene/amp-labels-specular.png'
    bumpTextureFile: 'scene/amp-labels-bump.png'

  class WorkLight
    constructor: (@object3d, @scene)->
      @light = @object3d.children[0]
      @scene.add @light
      if window.lightdebug?
        @helper = new TTT.SpotLightHelper(@light)
        @scene.add @helper

  class IdaBook extends TexturedMesh
    textureFile: 'hacker_room/uv-idabook.png'

  class Bottle extends TexturedMesh
    textureFile: 'hacker_room/uv-bottle.png'

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

  class CameraSequence extends Renderable
    constructor: ()->
      @cameras = []
      @targets = []
    register: (camera, target, idx)->
      @cameras[idx] = camera
      @targets[idx] = target
    compact: ()->
      raise "CameraSequence weird" unless @cameras.length == @targets.length
      until @cameras[0]?
        @cameras.shift()
        @targets.shift()
      @count = @cameras.length
    setScene: (@sceneCamera)->
      @vecs = for camera, i in @cameras
        [camera.getWorldPosition(), @targets[i].getWorldPosition()]
      true
    render: ()->
      t = Date.now()
      dist = (t % @sequenceLength) / @sequenceLength
      cur = Math.floor(dist * @count)
      next = (cur + 1) % @count
      alpha = (dist * @count) - Math.floor(dist * @count)
      lerp = if (alpha < 0.5)
        (4 * Math.pow(alpha, 3))
      else
         (1 + 4 * Math.pow((alpha - 1), 3))

      [curCam, curTarg] = @vecs[cur]
      [nextCam, nextTarg] = @vecs[next]

      @sceneCamera.position.lerpVectors(curCam, nextCam, lerp)
      @sceneCamera.lookAt curTarg.clone().lerp(nextTarg, lerp)
    sequenceLength: 10000

  class Camera extends Renderable
    constructor: (@canvas, @scene)->
      @initializeCamera()
      @initializeRenderer()
    initializeCamera: ()->
      @camera = new TTT.PerspectiveCamera(55,
        (1.0 * @canvas.width) / @canvas.height,
        0.1,
        1000)
      @camera.up = new TTT.Vector3(0, 0, 1)
    initializeRenderer: ()->
      @renderer = new TTT.WebGLRenderer
        canvas: @canvas
        antialias: true
        alpha: true
      @renderer.setPixelRatio 4
      @renderer.shadowMap.enabled = true
      @renderer.shadowMap.renderReverseSided = false
    setSequences: (@sequences)->
      @onlySequence = @sequences['Amp']

      @scene.add new TTT.AxisHelper(5)

      @camera.position.set -20, 2.8, -13
      @camera.rotation.set 0, -1.5, 0

      @onlySequence.setScene(@camera)
    render: ()->
      @onlySequence.render()
      @renderer.render @scene, @camera

  class DirLight extends Renderable
    constructor: (@scene, @target)->
      @light = new THREE.DirectionalLight 0xffffff, 0.25
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

  window.hackerRoom = new HackerRoom(document.getElementById 'scene')
