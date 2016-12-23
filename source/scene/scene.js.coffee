jQuery ($)->

  window.lightdebug = true
  COUNTDOWN = new Date(1493424000000)

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
        else if c.name == 'OnLightBulb'
          @onLight = new OnLight c
        else if c.name.match /^WorkLight\d+/
          @workLights ?= []
          @workLights.push new WorkLight c, @scene
        else if c.name.match /Cam\d+$/
          @cameras ?= {}
          @cameras[c.name] = c
        else if m = c.name.match /^(.+Cam\d+).Target$/
          @cameraTargets ?= {}
          @cameraTargets[m[1]] = c
        else if c.name == 'KnobSeconds'
          @knobs ?= {}
          @knobs['seconds'] = new Knob(c, 60)
        else if c.name == 'KnobMiniutes'
          @knobs ?= {}
          @knobs['minutes'] = new Knob(c, 60 * 60)
        else if c.name == 'KnobHours'
          @knobs ?= {}
          @knobs['hours'] = new Knob(c, 24 * 60 * 60)
        else if c.name == 'KnobDays'
          @knobs ?= {}
          @knobs['days'] = new Knob(c, 7 * 24 * 60 * 60)
        else if c.name == 'KnobWeeks'
          @knobs ?= {}
          @knobs['weeks'] = new Knob(c, 6 * 7 * 24 * 60 * 60)
        else if c.name == 'KnobMonths'
          @knobs ?= {}
          @knobs['months'] = new Knob(c, 5 * 30 * 24 * 60 * 60)
        else if c.name == 'BeerBottle'
          @bottle = new Bottle c
        else if c.name == 'paper'
          @paper = new Paper c
        else if c.name.match /Cylinder00\d/
          @cans ?= []
          @cans.push new Can c
        else if c.name == 'odroid heartbeat'
          @heartbeat = new OdroidHeartbeat c
        else if c.name == 'Omni001'
          omni = c.children[0]
          @scene.add omni
          console.log c.getWorldPosition()
          console.log c.position
          omni.position.copy c.position
          omni.intensity = 2
          omni.distance = 500
          omni.decay = 2
          omni.castShadow = true
          shadow = omni.shadow
          shadow.mapWidth = shadow.mapHeight = 128
          shadow.bias = 0.1
        else if c.name == 'Fspot001'
          spot = c.children[0]
          @scene.add spot
          spot.position.copy c.position
          spot.intensity = 5
          spot.decay = 2
          spot.distance = 100
          spot.castShadow = true
          shadow = spot.shadow =
            new TTT.LightShadow(new TTT.PerspectiveCamera(50, 1, 1, 20))
          shadow.mapWidth = shadow.mapHeight = 256
          shadow.bias = .11
        else if c.name.match /badge/i
          @badge ?= new Badge
          @badge.addObject c
        else if c.type.match /Light/
          c.intensity = 2
          c.decay = 2
          c.distance = 100
          c.castShadow = true
          c.shadow.mapWidth = c.shadow.mapHeight = 256

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
            cp_mat.color = new TTT.Color(0x101010)
            st = @setupTexture
            @scene.textureLoader.load @diffuseTextureFile, (texture)->
              cp_mat.map = st(texture)
              cp_mat.needsUpdate = true
            @scene.textureLoader.load @specularTextureFile, (texture)->
              cp_mat.specularMap = st(texture)
              cp_mat.needsUpdate = true
          when "speaker cover"
            sk_mat = mat
            sk_mat.color = new TTT.Color(0xffffff)
            st = @setupTexture
            @scene.textureLoader.load @diffuseTextureFile, (texture)->
              sk_mat.map = st(texture)
              sk_mat.needsUpdate = true
            @scene.textureLoader.load @bumpTextureFile, (texture)->
              sk_mat.bumpMap = st(texture)
              sk_mat.needsUpdate = true
          when "leatherette"
            le_mat = mat
            le_mat.color = new TTT.Color(0x111111)
            le_mat.specular = new TTT.Color(0x222222)
            @scene.textureLoader.load @leatheretteTextureFile, (texture)->
              le_mat.bumpMap = st(texture)
              texture.repeat.set 10, 10
              le_mat.needsUpdate = true
          else
            console.log "mystery material #{mat.name} D:"
    diffuseTextureFile: 'scene/amp-labels-diffuse.png'
    specularTextureFile: 'scene/amp-labels-specular.png'
    bumpTextureFile: 'scene/amp-labels-bump.png'
    leatheretteTextureFile: 'scene/leatherette-bump.png'

  class WorkLight
    constructor: (@object3d, @scene)->
      @light = @object3d.children[0]
      @light.castShadow = true
      @light.distance = 500
      shadow = @light.shadow
      shadow.mapSize.set 256, 256
      shadow.bias = 0
      shadow.darkness = 0.0
      cam = shadow.camera
      camSize = 100
      cam.left = cam.bottom = -camSize
      cam.right = cam.top = camSize
      @scene.add new TTT.CameraHelper(cam)
      @scene.add @light
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

  class OnLight extends Renderable
    constructor: (@bulb)->
      @mesh = @bulb.children[0]
      @onRed = new TTT.Color(0xFF0000)
      @offRed = new TTT.Color(0x440000)
      @mesh.material.color = new TTT.Color(0)
      @mesh.receiveShadow = false
      @mesh.castShadow = false
      @setupLight()
      hackerRoom.updater.add this
    setupLight: ()->
      @light = @bulb.children[1].children[0]
      @light.distance = 1
      @light.decay = 2
      @light.castShadow = true
      shadow = @light.shadow
      shadow.mapWidth = shadow.mapHeight = 4
      shadow.bias = .01
    render: ()->
      cycle = 0.5 + Math.sin(Date.now() * 0.005)
      if cycle > 1
        @light.intensity = 1
        @mesh.material.emissive = @onRed
      else
        @light.intensity = 0
        @mesh.material.emissive = @offRed

  class Knob extends Renderable
    constructor: (@object, @period)->
      @mesh = @object.children[0]
      hackerRoom.updater.add this
    render: ()->
      diff = (COUNTDOWN - new Date()) / 1000
      diff = 0 if diff < 0
      remainder = diff % @period
      rotation = -2 * Math.PI * (remainder / @period)
      @mesh.rotation.set 0, 0, rotation

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
    sequenceLength: 100000

  class Camera extends Renderable
    constructor: (@canvas, @scene)->
      @initializeCamera()
      @initializeRenderer()
      # @initializeControls()
    initializeCamera: ()->
      @camera = new TTT.PerspectiveCamera(25,
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
    initializeControls: ()->
      @controls = new TTT.TrackballControls(@camera)
      @controls.keys = [65, 83, 68]
    render: ()->
      # @controls.update()
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
