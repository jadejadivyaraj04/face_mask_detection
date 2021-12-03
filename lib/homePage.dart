import 'package:camera/camera.dart';
import 'package:face_mask_detortor_app/main.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraImage imgCamera;
  CameraController cameraController;
  bool isWorking = false;
  String result = "";
  String image_path = "";

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = imageFromStream,
                  runModelOnFrame(),
                }
            });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
  }

  runModelOnFrame() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: imgCamera.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: imgCamera.height,
          imageWidth: imgCamera.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 1,
          threshold: 0.1,
          asynch: true);

      result = "";

      recognitions.forEach((response) {
        result += response["label"] + "\n";
        if (result.trim() == "without_mask") {
          image_path = "assets/wear_mask_messgae.jpg";
        } else {
          image_path = "assets/thnkyou_message.jpg";
        }
      });

      setState(() {
        result;

      });

      print("su lage yrr $image_path");

      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();

    initCamera();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          // appBar: AppBar(
          //   backgroundColor: Colors.black,
          //   title: Padding(
          //     padding: EdgeInsets.only(top: 40.0),
          //     child: Center(
          //       child: Text(
          //         result,
          //         style: TextStyle(
          //             backgroundColor: Colors.black54,
          //             fontSize: 22,
          //             color: Colors.white),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ),
          // ),
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: (!cameraController.value.isInitialized)
                    ? Container()
                    : AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: CameraPreview(cameraController),
                      ),
              ),
              Column(
                children: [
                  Expanded(child: Container()),
                  Image.asset(
                    image_path,
                    height: 230,
                    width: 180,
                    fit: BoxFit.fill,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
