(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  jQuery(function($) {
    var AMBER, Amp, Badge, Bottle, COUNTDOWN, Camera, CameraSequence, Can, Computer, DirLight, HackerRoom, IdaBook, Knob, OdroidHeartbeat, OnLight, Renderable, Room, TTT, TexturedMesh, Updater, WorkLight;
    window.lightdebug = true;
    COUNTDOWN = new Date(1493424000000);
    TTT = THREE;
    AMBER = 0xF5B34A;
    HackerRoom = (function() {
      function HackerRoom(canvas) {
        this.canvas = canvas;
        this.updater = new Updater;
        this.initializeScene();
        this.initializeRoom();
      }

      HackerRoom.prototype.initializeScene = function() {
        this.scene = new TTT.Scene;
        return this.scene.textureLoader = new TTT.TextureLoader;
      };

      HackerRoom.prototype.initializeCamera = function(sequences) {
        this.camera = new Camera(this.canvas, this.scene);
        this.camera.setSequences(sequences);
        return this.updater.add(this.camera);
      };

      HackerRoom.prototype.initializeRoom = function() {
        this.room = new Room(this.scene, this.roomFinished.bind(this));
        return this.updater.add(this.room);
      };

      HackerRoom.prototype.roomFinished = function() {
        this.updater.add(this.room);
        this.initializeCamera(this.room.cameraSequences);
        return requestAnimationFrame(this.renderLoop.bind(this));
      };

      HackerRoom.prototype.renderLoop = function() {
        this.updater.render();
        return requestAnimationFrame(this.renderLoop.bind(this));
      };

      return HackerRoom;

    })();
    Updater = (function() {
      function Updater() {
        this.list = [];
      }

      Updater.prototype.add = function(obj) {
        return this.list.push(obj);
      };

      Updater.prototype.render = function() {
        var e, j, len, ref, results;
        ref = this.list;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          e = ref[j];
          results.push(e.render());
        }
        return results;
      };

      return Updater;

    })();
    Renderable = (function() {
      function Renderable() {}

      Renderable.prototype.render = function() {};

      Renderable.prototype.setupTexture = function(texture) {
        texture.anisotropy = 16;
        texture.repeat.set(1, 1);
        texture.wrapS = texture.wrapT = TTT.RepeatWrapping;
        texture.mapFilter = texture.magFilter = TTT.LinearFilter;
        texture.mapping = TTT.UVMapping;
        return texture;
      };

      return Renderable;

    })();
    TexturedMesh = (function() {
      function TexturedMesh(object1) {
        this.object = object1;
        this.mesh = this.object.children[0];
        this.createTexture();
      }

      TexturedMesh.prototype.createTexture = function() {
        this.texture = TTT.ImageUtils.loadTexture(this.textureFilePicker());
        this.texture.anisotropy = 16;
        this.texture.repeat.set(1, 1);
        this.texture.mapFilter = this.texture.magFilter = TTT.LinearFilter;
        this.texture.mapping = TTT.UVMapping;
        return this.mesh.material = new TTT.MeshPhongMaterial({
          color: new TTT.Color(0x444444),
          emissive: new TTT.Color(0x444444),
          specular: new TTT.Color(0x444444),
          shininess: 10,
          map: this.texture
        });
      };

      TexturedMesh.prototype.textureFilePicker = function() {
        return this.textureFile;
      };

      return TexturedMesh;

    })();
    Room = (function(superClass) {
      extend(Room, superClass);

      function Room(scene, callback) {
        this.scene = scene;
        this.callback = callback;
        this.loader = new THREE.ColladaLoader;
        this.loader.load('scene/legit-stage-2017.DAE', this.loaded.bind(this));
      }

      Room.prototype.loaded = function(o) {
        this.sceneParent = o.scene.children[0];
        this.sceneParent.rotation.x = 0;
        this.sceneParent.updateMatrix();
        this.sceneParent.traverse((function(_this) {
          return function(c) {
            var m, omni, shadow, spot;
            if (c.type !== 'PointLight') {
              c.castShadow = true;
            }
            c.receiveShadow = true;
            c.frustrumCulling = false;
            if (c.name === 'Amp') {
              return _this.amp = new Amp(c, _this.scene);
            } else if (c.name === 'OnLightBulb') {
              return _this.onLight = new OnLight(c);
            } else if (c.name.match(/^WorkLight\d+/)) {
              if (_this.workLights == null) {
                _this.workLights = [];
              }
              return _this.workLights.push(new WorkLight(c, _this.scene));
            } else if (c.name.match(/Cam\d+$/)) {
              if (_this.cameras == null) {
                _this.cameras = {};
              }
              return _this.cameras[c.name] = c;
            } else if (m = c.name.match(/^(.+Cam\d+).Target$/)) {
              if (_this.cameraTargets == null) {
                _this.cameraTargets = {};
              }
              return _this.cameraTargets[m[1]] = c;
            } else if (c.name === 'KnobSeconds') {
              if (_this.knobs == null) {
                _this.knobs = {};
              }
              return _this.knobs['seconds'] = new Knob(c, 60);
            } else if (c.name === 'KnobMiniutes') {
              if (_this.knobs == null) {
                _this.knobs = {};
              }
              return _this.knobs['minutes'] = new Knob(c, 60 * 60);
            } else if (c.name === 'KnobHours') {
              if (_this.knobs == null) {
                _this.knobs = {};
              }
              return _this.knobs['hours'] = new Knob(c, 24 * 60 * 60);
            } else if (c.name === 'KnobDays') {
              if (_this.knobs == null) {
                _this.knobs = {};
              }
              return _this.knobs['days'] = new Knob(c, 7 * 24 * 60 * 60);
            } else if (c.name === 'KnobWeeks') {
              if (_this.knobs == null) {
                _this.knobs = {};
              }
              return _this.knobs['weeks'] = new Knob(c, 6 * 7 * 24 * 60 * 60);
            } else if (c.name === 'KnobMonths') {
              if (_this.knobs == null) {
                _this.knobs = {};
              }
              return _this.knobs['months'] = new Knob(c, 5 * 30 * 24 * 60 * 60);
            } else if (c.name === 'BeerBottle') {
              return _this.bottle = new Bottle(c);
            } else if (c.name === 'paper') {
              return _this.paper = new Paper(c);
            } else if (c.name.match(/Cylinder00\d/)) {
              if (_this.cans == null) {
                _this.cans = [];
              }
              return _this.cans.push(new Can(c));
            } else if (c.name === 'odroid heartbeat') {
              return _this.heartbeat = new OdroidHeartbeat(c);
            } else if (c.name === 'Omni001') {
              omni = c.children[0];
              _this.scene.add(omni);
              console.log(c.getWorldPosition());
              console.log(c.position);
              omni.position.copy(c.position);
              omni.intensity = 2;
              omni.distance = 500;
              omni.decay = 2;
              omni.castShadow = true;
              shadow = omni.shadow;
              shadow.mapWidth = shadow.mapHeight = 128;
              return shadow.bias = 0.1;
            } else if (c.name === 'Fspot001') {
              spot = c.children[0];
              _this.scene.add(spot);
              spot.position.copy(c.position);
              spot.intensity = 5;
              spot.decay = 2;
              spot.distance = 100;
              spot.castShadow = true;
              shadow = spot.shadow = new TTT.LightShadow(new TTT.PerspectiveCamera(50, 1, 1, 20));
              shadow.mapWidth = shadow.mapHeight = 256;
              return shadow.bias = .11;
            } else if (c.name.match(/badge/i)) {
              if (_this.badge == null) {
                _this.badge = new Badge;
              }
              return _this.badge.addObject(c);
            } else if (c.type.match(/Light/)) {
              c.intensity = 2;
              c.decay = 2;
              c.distance = 100;
              c.castShadow = true;
              return c.shadow.mapWidth = c.shadow.mapHeight = 256;
            }
          };
        })(this));
        this.buildCameraSequences();
        this.scene.add(this.sceneParent);
        this.sceneParent.updateMatrixWorld();
        this.didLoad = true;
        return this.callback();
      };

      Room.prototype.displayPanel = function() {
        if (this._displayPanel != null) {
          return this._displayPanel;
        }
        this.scene.traverse((function(_this) {
          return function(c) {
            if (c.name === 'display-panel') {
              return _this._displayPanel = c;
            }
          };
        })(this));
        return this._displayPanel;
      };

      Room.prototype.buildCameraSequences = function() {
        var _name, base, camera, idx, match, name, ref, ref1, ref2, results, sequence, sequenceName, target;
        this.cameraSequences = {};
        ref = this.cameras;
        for (name in ref) {
          camera = ref[name];
          target = this.cameraTargets[name];
          ref1 = name.match(/^(.+)Cam(\d)+$/), match = ref1[0], sequenceName = ref1[1], idx = ref1[2];
          if ((base = this.cameraSequences)[sequenceName] == null) {
            base[sequenceName] = new CameraSequence();
          }
          this.cameraSequences[sequenceName].register(camera, target, idx);
        }
        ref2 = this.cameraSequences;
        results = [];
        for (_name in ref2) {
          sequence = ref2[_name];
          results.push(sequence.compact());
        }
        return results;
      };

      return Room;

    })(Renderable);
    Amp = (function(superClass) {
      extend(Amp, superClass);

      function Amp(object1, scene) {
        this.object = object1;
        this.scene = scene;
        this.mesh = this.object.children[0];
        this.textureMaterials(this.mesh.material);
      }

      Amp.prototype.textureMaterials = function(parentMaterial) {
        var cp_mat, j, le_mat, len, mat, ref, results, sk_mat, st;
        ref = parentMaterial.materials;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          mat = ref[j];
          switch (mat.name) {
            case "control panel":
              cp_mat = mat;
              cp_mat.color = new TTT.Color(0x101010);
              st = this.setupTexture;
              this.scene.textureLoader.load(this.diffuseTextureFile, function(texture) {
                cp_mat.map = st(texture);
                return cp_mat.needsUpdate = true;
              });
              results.push(this.scene.textureLoader.load(this.specularTextureFile, function(texture) {
                cp_mat.specularMap = st(texture);
                return cp_mat.needsUpdate = true;
              }));
              break;
            case "speaker cover":
              sk_mat = mat;
              sk_mat.color = new TTT.Color(0xffffff);
              st = this.setupTexture;
              this.scene.textureLoader.load(this.diffuseTextureFile, function(texture) {
                sk_mat.map = st(texture);
                return sk_mat.needsUpdate = true;
              });
              results.push(this.scene.textureLoader.load(this.bumpTextureFile, function(texture) {
                sk_mat.bumpMap = st(texture);
                return sk_mat.needsUpdate = true;
              }));
              break;
            case "leatherette":
              le_mat = mat;
              le_mat.color = new TTT.Color(0x111111);
              le_mat.specular = new TTT.Color(0x222222);
              results.push(this.scene.textureLoader.load(this.leatheretteTextureFile, function(texture) {
                le_mat.bumpMap = st(texture);
                texture.repeat.set(10, 10);
                return le_mat.needsUpdate = true;
              }));
              break;
            default:
              results.push(console.log("mystery material " + mat.name + " D:"));
          }
        }
        return results;
      };

      Amp.prototype.diffuseTextureFile = 'scene/amp-labels-diffuse.png';

      Amp.prototype.specularTextureFile = 'scene/amp-labels-specular.png';

      Amp.prototype.bumpTextureFile = 'scene/amp-labels-bump.png';

      Amp.prototype.leatheretteTextureFile = 'scene/leatherette-bump.png';

      return Amp;

    })(Renderable);
    WorkLight = (function() {
      function WorkLight(object3d, scene) {
        var cam, camSize, shadow;
        this.object3d = object3d;
        this.scene = scene;
        this.light = this.object3d.children[0];
        this.light.castShadow = true;
        this.light.distance = 500;
        shadow = this.light.shadow;
        shadow.mapSize.set(256, 256);
        shadow.bias = 0;
        shadow.darkness = 0.0;
        cam = shadow.camera;
        camSize = 100;
        cam.left = cam.bottom = -camSize;
        cam.right = cam.top = camSize;
        this.scene.add(new TTT.CameraHelper(cam));
        this.scene.add(this.light);
        this.helper = new TTT.SpotLightHelper(this.light);
        this.scene.add(this.helper);
      }

      return WorkLight;

    })();
    IdaBook = (function(superClass) {
      extend(IdaBook, superClass);

      function IdaBook() {
        return IdaBook.__super__.constructor.apply(this, arguments);
      }

      IdaBook.prototype.textureFile = 'hacker_room/uv-idabook.png';

      return IdaBook;

    })(TexturedMesh);
    Bottle = (function(superClass) {
      extend(Bottle, superClass);

      function Bottle() {
        return Bottle.__super__.constructor.apply(this, arguments);
      }

      Bottle.prototype.textureFile = 'hacker_room/uv-bottle.png';

      return Bottle;

    })(TexturedMesh);
    Can = (function(superClass) {
      extend(Can, superClass);

      function Can() {
        return Can.__super__.constructor.apply(this, arguments);
      }

      Can.prototype.textureFile = 'hacker_room/uv-can.png';

      return Can;

    })(TexturedMesh);
    OdroidHeartbeat = (function() {
      function OdroidHeartbeat(object3d) {
        this.object3d = object3d;
        this.light = this.object3d.children[0];
        this.light.distance = 5;
        hackerRoom.updater.add(this);
      }

      OdroidHeartbeat.prototype.render = function() {
        var cycle;
        cycle = 0.1 + Math.sin(Date.now() * 0.005);
        if (cycle > 1) {
          return this.light.intensity = 0.25;
        } else {
          return this.light.intensity = 0;
        }
      };

      return OdroidHeartbeat;

    })();
    OnLight = (function(superClass) {
      extend(OnLight, superClass);

      function OnLight(bulb) {
        this.bulb = bulb;
        this.mesh = this.bulb.children[0];
        this.onRed = new TTT.Color(0xFF0000);
        this.offRed = new TTT.Color(0x440000);
        this.mesh.material.color = new TTT.Color(0);
        this.mesh.receiveShadow = false;
        this.mesh.castShadow = false;
        this.setupLight();
        hackerRoom.updater.add(this);
      }

      OnLight.prototype.setupLight = function() {
        var shadow;
        this.light = this.bulb.children[1].children[0];
        this.light.distance = 1;
        this.light.decay = 2;
        this.light.castShadow = true;
        shadow = this.light.shadow;
        shadow.mapWidth = shadow.mapHeight = 4;
        return shadow.bias = .01;
      };

      OnLight.prototype.render = function() {
        var cycle;
        cycle = 0.5 + Math.sin(Date.now() * 0.005);
        if (cycle > 1) {
          this.light.intensity = 1;
          return this.mesh.material.emissive = this.onRed;
        } else {
          this.light.intensity = 0;
          return this.mesh.material.emissive = this.offRed;
        }
      };

      return OnLight;

    })(Renderable);
    Knob = (function(superClass) {
      extend(Knob, superClass);

      function Knob(object1, period) {
        this.object = object1;
        this.period = period;
        this.mesh = this.object.children[0];
        hackerRoom.updater.add(this);
      }

      Knob.prototype.render = function() {
        var diff, remainder, rotation;
        diff = (COUNTDOWN - new Date()) / 1000;
        if (diff < 0) {
          diff = 0;
        }
        remainder = diff % this.period;
        rotation = -2 * Math.PI * (remainder / this.period);
        return this.mesh.rotation.set(0, 0, rotation);
      };

      return Knob;

    })(Renderable);
    Badge = (function() {
      function Badge() {
        this.eyes = [];
        this.eyeMaterials = [];
        hackerRoom.updater.add(this);
      }

      Badge.prototype.addObject = function(object) {
        if (object.name.match(/BadgeEye/)) {
          return this.addEye(object);
        } else if (object.name === 'badge-light') {
          return this.addLight(object);
        }
      };

      Badge.prototype.addEye = function(eye) {
        this.eyes.push(eye);
        return this.eyeMaterials.push(eye.children[0].material);
      };

      Badge.prototype.addLight = function(light) {
        this.light = light.children[0];
        return this.light.distance = 5;
      };

      Badge.prototype.render = function() {
        var cycle, i, j, k, len, len1, ref, ref1, ref2, ref3, results, results1;
        cycle = 0.1 + Math.sin((Date.now() * 0.003) + .1);
        if (cycle > 1) {
          if ((ref = this.light) != null) {
            ref.intensity = 0.5;
          }
          ref1 = this.eyeMaterials;
          results = [];
          for (j = 0, len = ref1.length; j < len; j++) {
            i = ref1[j];
            results.push(i.emissive.set(0xaaccff));
          }
          return results;
        } else {
          if ((ref2 = this.light) != null) {
            ref2.intensity = 0.25;
          }
          ref3 = this.eyeMaterials;
          results1 = [];
          for (k = 0, len1 = ref3.length; k < len1; k++) {
            i = ref3[k];
            results1.push(i.emissive.set(0x000000));
          }
          return results1;
        }
      };

      return Badge;

    })();
    Computer = (function(superClass) {
      extend(Computer, superClass);

      function Computer(scene, displayPanel) {
        this.scene = scene;
        this.displayPanel = displayPanel;
        this.makeScreen();
      }

      Computer.prototype.makeScreen = function() {
        var mesh;
        mesh = this.displayPanel.children[0];
        mesh.receiveShadow = false;
        this.screenTexture = TTT.ImageUtils.loadTexture('hacker_room/legitbs-2015-text.png');
        this.screenTexture.anisotropy = 16;
        this.screenTexture.repeat.set(1, 1);
        this.screenTexture.mapFilter = this.screenTexture.magFilter = TTT.LinearFilter;
        this.screenTexture.mapping = TTT.UVMapping;
        this.screenTexture.wrapS = this.screenTexture.wrapT = TTT.ClampToEdgeWrapping;
        return mesh.material = new TTT.MeshPhongMaterial({
          color: new TTT.Color(0x444444),
          emissive: new TTT.Color(AMBER),
          specular: new TTT.Color(0xffffff),
          shininess: 30,
          map: this.screenTexture
        });
      };

      return Computer;

    })(Renderable);
    CameraSequence = (function(superClass) {
      extend(CameraSequence, superClass);

      function CameraSequence() {
        this.cameras = [];
        this.targets = [];
      }

      CameraSequence.prototype.register = function(camera, target, idx) {
        this.cameras[idx] = camera;
        return this.targets[idx] = target;
      };

      CameraSequence.prototype.compact = function() {
        if (this.cameras.length !== this.targets.length) {
          raise("CameraSequence weird");
        }
        while (this.cameras[0] == null) {
          this.cameras.shift();
          this.targets.shift();
        }
        return this.count = this.cameras.length;
      };

      CameraSequence.prototype.setScene = function(sceneCamera) {
        var camera, i;
        this.sceneCamera = sceneCamera;
        this.vecs = (function() {
          var j, len, ref, results;
          ref = this.cameras;
          results = [];
          for (i = j = 0, len = ref.length; j < len; i = ++j) {
            camera = ref[i];
            results.push([camera.getWorldPosition(), this.targets[i].getWorldPosition()]);
          }
          return results;
        }).call(this);
        return true;
      };

      CameraSequence.prototype.render = function() {
        var alpha, cur, curCam, curTarg, dist, lerp, next, nextCam, nextTarg, ref, ref1, t;
        t = Date.now();
        dist = (t % this.sequenceLength) / this.sequenceLength;
        cur = Math.floor(dist * this.count);
        next = (cur + 1) % this.count;
        alpha = (dist * this.count) - Math.floor(dist * this.count);
        lerp = alpha < 0.5 ? 4 * Math.pow(alpha, 3) : 1 + 4 * Math.pow(alpha - 1, 3);
        ref = this.vecs[cur], curCam = ref[0], curTarg = ref[1];
        ref1 = this.vecs[next], nextCam = ref1[0], nextTarg = ref1[1];
        this.sceneCamera.position.lerpVectors(curCam, nextCam, lerp);
        return this.sceneCamera.lookAt(curTarg.clone().lerp(nextTarg, lerp));
      };

      CameraSequence.prototype.sequenceLength = 100000;

      return CameraSequence;

    })(Renderable);
    Camera = (function(superClass) {
      extend(Camera, superClass);

      function Camera(canvas, scene) {
        this.canvas = canvas;
        this.scene = scene;
        this.initializeCamera();
        this.initializeRenderer();
      }

      Camera.prototype.initializeCamera = function() {
        this.camera = new TTT.PerspectiveCamera(25, (1.0 * this.canvas.width) / this.canvas.height, 0.1, 1000);
        return this.camera.up = new TTT.Vector3(0, 0, 1);
      };

      Camera.prototype.initializeRenderer = function() {
        this.renderer = new TTT.WebGLRenderer({
          canvas: this.canvas,
          antialias: true,
          alpha: true
        });
        this.renderer.setPixelRatio(4);
        this.renderer.shadowMap.enabled = true;
        return this.renderer.shadowMap.renderReverseSided = false;
      };

      Camera.prototype.setSequences = function(sequences1) {
        this.sequences = sequences1;
        this.onlySequence = this.sequences['Amp'];
        this.scene.add(new TTT.AxisHelper(5));
        this.camera.position.set(-20, 2.8, -13);
        this.camera.rotation.set(0, -1.5, 0);
        return this.onlySequence.setScene(this.camera);
      };

      Camera.prototype.initializeControls = function() {
        this.controls = new TTT.TrackballControls(this.camera);
        return this.controls.keys = [65, 83, 68];
      };

      Camera.prototype.render = function() {
        this.onlySequence.render();
        return this.renderer.render(this.scene, this.camera);
      };

      return Camera;

    })(Renderable);
    DirLight = (function(superClass) {
      extend(DirLight, superClass);

      function DirLight(scene, target1) {
        var shadowCameraSize;
        this.scene = scene;
        this.target = target1;
        this.light = new THREE.DirectionalLight(0xffffff, 0.25);
        this.light.position.set(-20, 10, 25);
        this.light.castShadow = true;
        this.light.shadowMapWidth = 2048;
        this.light.shadowMapHeight = 2048;
        this.light.onlyShadow = false;
        shadowCameraSize = 10;
        this.light.shadowCameraLeft = -shadowCameraSize;
        this.light.shadowCameraRight = shadowCameraSize;
        this.light.shadowCameraTop = shadowCameraSize;
        this.light.shadowCameraBottom = -shadowCameraSize;
        this.light.shadowCameraNear = 1;
        this.light.shadowCameraFar = 200;
        this.light.shadowBias = -0.0001;
        this.light.shadowDarkness = 0.35;
        this.light.shadowCameraVisible = true;
        this.light.lookAt(this.target.position);
        this.scene.add(this.light);
      }

      DirLight.prototype.render = function() {
        var xCycle, yCycle;
        xCycle = 0.4 * Math.sin(Date.now() / 10000.0);
        yCycle = 0.8 * Math.cos(Date.now() / 20000.0);
        return this.light.position.set(-21 + xCycle, 10 + yCycle, 25);
      };

      return DirLight;

    })(Renderable);
    return window.hackerRoom = new HackerRoom(document.getElementById('scene'));
  });

}).call(this);
