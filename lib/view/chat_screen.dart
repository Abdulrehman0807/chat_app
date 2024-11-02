import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_me/view/StaticData.dart';
import 'package:chat_me/view/audio.dart';
import 'package:chat_me/view/document.dart';
import 'package:chat_me/model/friendmodel.dart';
import 'package:chat_me/view/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class ChatScreen extends StatefulWidget {
  final String chatroomId;
  final FriendModel userModel;
  const ChatScreen({
    super.key,
    required this.chatroomId,
    required this.userModel,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    print(widget.userModel.toMap());

    super.initState();
  }

  void onsendMessage() async {
    if (msgController.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendBy": StaticData.model!.name,
        "message": msgController.text,
        "time": FieldValue.serverTimestamp(),
        'type': 'msg'
      };
      await _firestore
          .collection('chatroom')
          .doc(widget.chatroomId)
          .collection('chats')
          .add(messages);
      msgController.clear();
    } else {
      print("Enter Some Text");
    }
  }
///////////

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  XFile? _photo;

  XFile? videoFile;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _photo = pickedFile;
      uploadFile();
    } else {
      print('No image selected.');
    }
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _photo = pickedFile;
      });

      uploadFile();
    } else {
      print('No image selected.');
    }
  }

  Future uploadFile() async {
    if (_photo == null) return;

    try {
      String? downloadUrl;

      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('file/${_photo!.name}');
      await ref
          .putData(await _photo!.readAsBytes(),
              SettableMetadata(contentType: 'image/png'))
          .then((taskSnapshot) async {
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
      });

      Map<String, dynamic> messages = {
        "sendBy": StaticData.model!.name,
        "message": downloadUrl,
        "time": FieldValue.serverTimestamp(),
        'type': 'img'
      };
      await _firestore
          .collection('chatroom')
          .doc(widget.chatroomId)
          .collection('chats')
          .add(messages);
    } catch (e) {
      print('error occured $e');
    }
  }

  Future uploadVideoFile() async {
    if (videoFile == null) return;

    try {
      String? downloadUrl;

      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('file/${videoFile!.name}');
      await ref
          .putData(await videoFile!.readAsBytes(),
              SettableMetadata(contentType: 'video/mp4'))
          .then((taskSnapshot) async {
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print(downloadUrl);
      });

      Map<String, dynamic> messages = {
        "sendBy": StaticData.model!.name,
        "message": downloadUrl,
        "time": FieldValue.serverTimestamp(),
        'type': 'video'
      };
      await _firestore
          .collection('chatroom')
          .doc(widget.chatroomId)
          .collection('chats')
          .add(messages);
      print(widget.chatroomId);
    } catch (e) {
      print('error occured $e');
    }
  }

  Future videoFromGallary() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      videoFile = pickedFile;
      uploadVideoFile();
    } else {
      print('No image selected.');
    }
  }

/////
  String? recordFilePath;
  Record audioRecord = Record();

  AudioController audioController = Get.put(AudioController());
  AudioPlayer audioPlayer = AudioPlayer();
  String audioURL = "";

  int i = 0;
  Future<String> getfilepath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath =
        '${storageDirectory.path}record/${DateTime.now().microsecondsSinceEpoch}';
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return '$sdPath/test_${i++}.mp3';
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getfilepath();
      await audioRecord.start(path: recordFilePath);
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void stopRecord() async {
    String? path = await audioRecord.stop();
    print(path);
    audioController.end.value = DateTime.now();
    audioController.calcDuration();
    var ap = AudioPlayer();
    await ap.play(AssetSource("Notification.mp3"));
    ap.onPlayerComplete.listen((a) {});

    await uploadAudio();
  }

  /////
  Future<void> uploadAudio() async {
    if (recordFilePath == null) return;

    Reference reference = FirebaseStorage.instance
        .ref()
        .child("audio/${DateTime.now().millisecondsSinceEpoch.toString()}");

    UploadTask uploadTask = reference.putFile(
      File(recordFilePath!),
      SettableMetadata(contentType: "audio/mp3"),
    );

    try {
      TaskSnapshot snapshot = await uploadTask;
      audioURL = await snapshot.ref.getDownloadURL();
      print("Audio URL: $audioURL");

      Map<String, dynamic> messages = {
        "sendBy": StaticData.model!.name,
        "message": audioURL,
        "time": FieldValue.serverTimestamp(),
        "type": "audio",
        "duration": "0:30" // Add duration here based on actual recording
      };

      await _firestore
          .collection('chatroom')
          .doc(widget.chatroomId)
          .collection('chats')
          .add(messages);
    } on FirebaseException catch (e) {
      print('Error uploading audio: $e');
    }
  }

  ///
  File? documentFile;

  Future uploadDocumentFile() async {
    if (documentFile == null) return;

    try {
      String? downloadUrl;
      String fileName = documentFile!.path.split('/').last;
      String fileExtension =
          fileName.split('.').last; // Extracting file extension

      // Checking file extension
      if (['pdf', 'doc', 'docx', 'ppt'].contains(fileExtension.toLowerCase())) {
        final ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('documents/$fileName');
        await ref
            .putFile(
                documentFile!,
                firebase_storage.SettableMetadata(
                    contentType: getContentType(fileExtension)))
            .then((taskSnapshot) async {
          downloadUrl = await taskSnapshot.ref.getDownloadURL();
          print(downloadUrl);
        });

        // Map for saving data to Firestore
        Map<String, dynamic> messages = {
          "sendBy": StaticData.model!.name,
          "message": downloadUrl,
          "time": FieldValue.serverTimestamp(),
          'type': 'document',
          'fileName': fileName, // Saving the document name
          'fileExtension': fileExtension // Saving the file extension
        };

        // Storing in Firestore
        await FirebaseFirestore.instance
            .collection('chatroom')
            .doc(widget.chatroomId)
            .collection('chats')
            .add(messages);

        print('Uploaded to chatroom ${widget.chatroomId}');
      } else {
        print('Unsupported file format');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

// Determine content type based on file extension
  String getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      default:
        return 'application/octet-stream';
    }
  }

  Future documentFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt'], // Supported extensions
    );

    if (result != null) {
      documentFile = File(result.files.single.path!);
      uploadDocumentFile();
    } else {
      print('No document selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          width: width,
          child: Column(
            children: [
              Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).colorScheme.primary),
                height: height * 0.04,
              ),
              Container(
                height: height * 0.08,
                width: width,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Padding(
                  padding:
                      EdgeInsets.only(right: width * 0.02, left: width * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: height * 0.05,
                        width: width * 0.12,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: width * 0.01,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.userModel.friendName}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Expanded(
                          child: SizedBox(
                        width: width,
                      )),
                      SizedBox(
                        width: width * 0.02,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chatroom')
                        .doc(widget.chatroomId)
                        .collection('chats')
                        .orderBy("time", descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> map =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;

                            // Extract the message type and other data
                            String messageType = map['type'];
                            String message = map['message'];
                            String sendBy = map['sendBy'];

                            if (messageType == "audio") {
                              // Handle audio message
                              return _audio(
                                message: message,
                                isCurrentUser: StaticData.model!.name == sendBy,
                                index: index,
                                time: "12",
                                duration: map['duration'],
                              );
                            } else if (messageType == 'document') {
                              // Handle document message
                              String fileName = map['fileName'] ?? "Document";
                              String fileUrl = message;
                              String fileExtension = map['fileExtension'] ?? "";

                              return DocumentWidget(
                                fileName: fileName,
                                fileUrl: fileUrl,
                                fileExtension: fileExtension,
                              );
                            } else {
                              // Handle other message types like text
                              return messages(MediaQuery.of(context).size, map);
                            }
                          },
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
              ),
              SizedBox(
                height: height * 0.07,
                width: width,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: width * 0.03, right: width * 0.01),
                  child: Row(
                    children: [
                      Container(
                        height: height * 0.06,
                        width: width * 0.82,
                        decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                  height: height * 0.06,
                                  width: width * 0.52,
                                  decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: width * 0.02),
                                    child: Center(
                                      child: TextField(
                                        controller: msgController,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  )),
                            ),
                            InkWell(
                              onTap: () {
                                // Show a dialog box when the icon is tapped
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Choose an Option'),
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Image Icon
                                          IconButton(
                                            icon: const Icon(Icons.image,
                                                size: 40, color: Colors.blue),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              imgFromGallery();
                                            },
                                          ),
                                          // Video Icon
                                          IconButton(
                                            icon: const Icon(
                                                Icons.video_library,
                                                size: 40,
                                                color: Colors.green),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              videoFromGallary();
                                            },
                                          ),
                                          // Camera Icon
                                          IconButton(
                                            icon: const Icon(Icons.camera_alt,
                                                size: 40, color: Colors.red),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              imgFromCamera();
                                            },
                                          ),

                                          IconButton(
                                            icon: const Icon(Icons.file_open,
                                                size: 40, color: Colors.blue),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              documentFromGallery();
                                            },
                                          ),

                                          IconButton(
                                            icon: const Icon(Icons.location_on,
                                                size: 40, color: Colors.blue),
                                            onPressed: () {
                                              // Navigator.of(context).pop();
                                              // imgFromGallery();
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Icon(
                                Icons.attach_file,
                                size: width * 0.06,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onLongPress: () async {
                                var audioPlayer = AudioPlayer();
                                await audioPlayer
                                    .play(AssetSource("Notification.mp3"));
                                audioPlayer.onPlayerComplete.listen((a) {
                                  audioController.start.value = DateTime.now();
                                  startRecord();
                                  audioController.isRecording.value = true;
                                });
                              },
                              onLongPressEnd: (details) {
                                stopRecord();
                              },
                              child: Icon(
                                Icons.mic_outlined,
                                size: width * 0.07,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width * 0.012,
                      ),
                      InkWell(
                          onTap: () {
                            onsendMessage();
                          },
                          child: Container(
                            height: height,
                            width: width * 0.11,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary),
                            child: const Center(
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map) {
    return Container(
      width: size.width,
      alignment: map['sendBy'] == StaticData.model!.name
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: map['type'] == "img"
          ? Container(
              height: size.height * 0.3,
              width: size.width * 0.45,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage(map['message'])),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
                color: map['sendBy'] == StaticData.model!.UserId
                    ? Colors.blue
                    : Colors.blue[100],
              ),
            )
          : map['type'] == "video"
              ? Container(
                  height: size.height * 0.3,
                  width: size.width * 0.45,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: map['sendBy'] == StaticData.model!.name
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: VideoPlayerSCreen(
                    videoUrl: map['message'],
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: map['sendBy'] == StaticData.model!.UserId
                        ? Colors.blue
                        : Colors.blue[100],
                  ),
                  child: Text(
                    map['message'],
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: map['sendBy'] == StaticData.model!.name
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
    );
  }

  Widget _audio({
    required String message,
    required bool isCurrentUser,
    required int index,
    required String time,
    required String duration,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.black : Colors.grey.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              audioController.onPressedPlayButton(index, message);
            },
            onSecondaryTap: () {},
            child: Obx(
              () => (audioController.isRecordPlaying &&
                      audioController.currentId == index)
                  ? Icon(
                      Icons.cancel,
                      color: isCurrentUser ? Colors.white : Colors.red,
                    )
                  : Icon(
                      Icons.play_arrow,
                      color: isCurrentUser ? Colors.white : Colors.red,
                    ),
            ),
          ),
          Obx(
            () => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    LinearProgressIndicator(
                      minHeight: 5,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCurrentUser ? Colors.white : Colors.red,
                      ),
                      value: (audioController.isRecordPlaying &&
                              audioController.currentId == index)
                          ? audioController.completedPercentage.value
                          : audioController.totalDuration.value.toDouble(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            duration,
            style: TextStyle(
                fontSize: 12, color: isCurrentUser ? Colors.white : Colors.red),
          ),
        ],
      ),
    );
  }
}
