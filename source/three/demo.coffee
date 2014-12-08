jQuery ($)->
  Three = THREE

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 0.1, 1000
  renderer = new THREE.WebGLRenderer()
  
  renderer.setSize window.innerWidth, window.innerHeight
  renderer.shadowMapEnabled = true
  renderer.shadowMapCullFace = THREE.CullFaceBack
  document.body.appendChild renderer.domElement

  manager = new THREE.LoadingManager()

  room = new Room scene, manager

  desk = new Desk scene
  computer = new Computer scene

  dirLight = new DirLight scene, computer

  camera.position.y = 4
  camera.position.z = 20

  render = ()->
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

class Room
  constructor: (@scene, @manager)->
    @loader = new THREE.OBJLoader @manager
    @loader.load 'hacker_room.obj', @loaded.bind(this)
  loaded: (o)->
    # @geo = new THREE.PlaneBufferGeometry 20, 20
    # @mat = new THREE.MeshPhongMaterial
    #   color: 0x050505
    # @mat.color.setHSL 0.095, 1, 0.75

    # @mesh = new THREE.Mesh @geo, @mat
    @object = o.children[0]
    @object.material = new THREE.MeshPhongMaterial
      color: 0x73674b
      shininess: 20
    @object.scale.set 0.15, 0.15, 0.15
    @object.position.set -6, -2, -2
    @object.rotation.y = 3.0/2.0 * Math.PI
    @object.updateMatrix()
    @object.castShadow = true
    @object.receiveShadow = true
    @scene.add @object
    @didLoad = true
  render: ()->
    return unless @didLoad?

class Desk
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

class Computer
  constructor: (@scene)->
    @coords = [-2, 4.65, 0]
    @makeMonitor()
    @makeLight()
  makeLight: ()->
    @light = new THREE.PointLight 0xF5B34A, .75, 10
    @light.position.set @coords...
    @scene.add @light
    help = new THREE.PointLightHelper @light, 1
    @scene.add help
  makeMonitor: ()->
    @geo = new THREE.BoxGeometry 4, 3, 0.1
    @mat = new THREE.MeshPhongMaterial
      color: 0x73674B
      specular: 0x73674B
      shininess: 30
      vertexColors: THREE.FaceColors
      shading: THREE.FlatShading

    @mesh = new THREE.Mesh @geo, @mat
    @mesh.position.set @coords...
    @mesh.rotation.y = 0.1

    @mesh.castShadow = true

    @scene.add @mesh

class DirLight
  constructor: (@scene, @target)->
    @light = new THREE.DirectionalLight 0xffffff, 0.5
    @light.position.set -10, 5, 10
    @light.castShadow = true
    @light.shadowMapWidth = 2048
    @light.shadowMapHeight = 2048

    @light.shadowCameraLeft = -50
    @light.shadowCameraRight = 50
    @light.shadowCameraTop = 50
    @light.shadowCameraBottom = -50

    @light.shadowCameraFar = 3500
    @light.shadowBias = -0.0001
    @light.shadowDarkness = 0.35

    @light.target = @target.mesh
  
    @scene.add @light
    help = new THREE.DirectionalLightHelper @light, 3
    @scene.add help
