jQuery ($)->
  Three = THREE

  canvas = document.getElementById 'actualScene'

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75,
    (1.0 * canvas.width) / canvas.height,
    0.1,
    1000)
  renderer = new THREE.WebGLRenderer canvas: canvas

  renderer.shadowMapEnabled = true
  renderer.shadowMapCullFace = THREE.CullFaceBack

  manager = new THREE.LoadingManager()

  room = new Room scene, manager

  computer = new Computer scene

  dirLight = new DirLight scene, computer

  camera.position.x = -2
  camera.position.y = 4
  camera.position.z = 5
  camera.lookAt new THREE.Vector3(-2, 4, 1)
  
  window.light = dirLight.light
  window.camera = camera

  updater = new Updater
  updater.add room
  updater.add computer
  updater.add dirLight

  render = ()->
    updater.render()
    renderer.render scene, camera
    room.render()
    requestAnimationFrame render

  render()

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
  constructor: (@scene, @manager)->
    @loader = new THREE.ColladaLoader @manager
    @loader.load 'hacker_room.dae', @loaded.bind(this)
  loaded: (o)->
    # @geo = new THREE.PlaneBufferGeometry 20, 20
    # @mat = new THREE.MeshPhongMaterial
    #   color: 0x050505
    # @mat.color.setHSL 0.095, 1, 0.75

    # @mesh = new THREE.Mesh @geo, @mat

    @object = o.scene.children[0]
    mat =  new THREE.MeshPhongMaterial
      color: 0x73674b
      shininess: 20
    @object.scale.set 0.15, 0.15, 0.15
    @object.position.set -6, -2, -2
    @object.rotation.x = 3.0/2.0 * Math.PI
    @object.rotation.z = 3.0/2.0 * Math.PI
    @object.updateMatrix()
      
    for c in @object.children
      c.material = mat

    o.scene.traverse (c) ->
      c.castShadow = true
      c.receiveShadow = true
      c.frustrumCulling = false
    
    @scene.add @object
    @didLoad = true
  render: ()->
    return unless @didLoad?

class Desk extends Renderable
  constructor: (@scene)->
    @geo = new THREE.BoxGeometry 10, 0.1, 3
    @mat = new THREE.MeshPhongMaterial
      color: 0x73674B
      shininess: 10
      vertexColors: THREE.FaceColors
      shading: THREE.FlatShading

    @mesh = new THREE.Mesh @geo, @mat
    @mesh.position.y = 3

    @mesh.castShadow = true
    @mesh.receiveShadow = true
    
    @scene.add @mesh

class Computer extends Renderable
  constructor: (@scene)->
    @coords = [-3.18, 3.65, .7]
    @makeMonitor()
    @makeLight()
  makeLight: ()->
    @light = new THREE.PointLight 0xF5B34A, .75, 10
    @light.position.set @coords...
    @scene.add @light
    help = new THREE.PointLightHelper @light, 1
    @scene.add help
  makeMonitor: ()->
    @geo = new THREE.BoxGeometry 2.6, 1.5, 0.01
    @mat = new THREE.MeshPhongMaterial
      color: 0x73674B
      specular: 0x73674B
      shininess: 30
      vertexColors: THREE.FaceColors
      shading: THREE.FlatShading

    @mesh = new THREE.Mesh @geo, @mat
    @mesh.position.set @coords...
    @mesh.rotation.y = 0.24
    window.computer = @mesh
    @mesh.receiveShadow = true
    @mesh.castShadow = true

    @scene.add @mesh

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
  
    @light.target = @target.mesh
  
    @scene.add @light
    help = new THREE.DirectionalLightHelper @light, 3
    @scene.add help
  render: () ->
    xCycle = 0.2 * Math.sin(Date.now() / 10000.0)
    yCycle = 0.5 * Math.cos(Date.now() / 20000.0)
    @light.position.set(-21 + xCycle, 10 + yCycle, 25)
