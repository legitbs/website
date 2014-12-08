jQuery ($)->
  Three = THREE

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 0.1, 1000
  renderer = new THREE.WebGLRenderer()
  
  renderer.setSize window.innerWidth, window.innerHeight
  renderer.shadowMapEnabled = true
  renderer.shadowMapCullFace = THREE.CullFaceBack
  document.body.appendChild renderer.domElement

  wall = new Wall scene

  desk = new Desk scene
  computer = new Computer scene

  dirLight = new DirLight scene, computer

  camera.position.y = 4
  camera.position.z = 20

  render = ()->
    renderer.render scene, camera
    requestAnimationFrame render

  render()

class Updater
  constructor: ()->
    @list = []
  add: (obj)->
    @list.push obj
  render: ()->
    e.render() for e in @list

class Wall
  constructor: (@scene)->
    @geo = new THREE.PlaneBufferGeometry 20, 20
    @mat = new THREE.MeshPhongMaterial
      color: 0x050505
    @mat.color.setHSL 0.095, 1, 0.75

    @mesh = new THREE.Mesh @geo, @mat
    @mesh.position.set 0, 5, -3
    @mesh.receiveShadow = true
    @scene.add @mesh

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
    @light = new THREE.PointLight 0xF5B34A, .75, 3
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
    @light.position.set -10, 25, 100
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

    @light.target.position.set (@target.coords)...
  
    @scene.add @light
    help = new THREE.DirectionalLightHelper @light, 3
    @scene.add help

class SkyLight
  constructor: (@scene)->
    @skyLight = new THREE.HemisphereLight 0xaaaaff, 0x88aa88, 0.5
    @skyLight.position.set 0, 500, 0
    @scene.add @skyLight
