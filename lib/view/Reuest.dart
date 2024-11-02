import 'package:chat_me/model/RequestModel.dart';
import 'package:chat_me/view/StaticData.dart';
import 'package:chat_me/model/friendmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List<RequestModel> AlluserRequest = [];
  getAllRequest() async {
    AlluserRequest.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Requests")
        .where("recevieId", isEqualTo: StaticData.model!.UserId)
        .where("status", isEqualTo: "Pendding")
        .get();
    for (var User in snapshot.docs) {
      RequestModel model =
          RequestModel.fromMap(User.data() as Map<String, dynamic>);
      setState(() {
        AlluserRequest.add(model);
      });
    }
  }

  @override
  void initState() {
    getAllRequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SizedBox(
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
            height: height * 0.10,
            width: width,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Center(
              child: Text(
                "Request",
                style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.86,
            width: width,
            child: AlluserRequest.isEmpty
                ? Center(
                    child: Text(" No Request Found",
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(color: Colors.black)),
                  )
                : ListView.builder(
                    itemCount: AlluserRequest.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 1,
                          child: Container(
                            height: height * 0.07,
                            width: width * 0.85,
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: height * 0.06,
                                    width: width * 0.6,
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 20,
                                          child: Icon(Icons.person),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            AlluserRequest[index].senderName!,
                                            style: const TextStyle(
                                                fontStyle: FontStyle.normal,
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    )),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orangeAccent),
                                    onPressed: () async {
                                      var uid = const Uuid();
                                      var friend1 = uid.v4();
                                      FriendModel model = FriendModel(
                                          friendId:
                                              AlluserRequest[index].senderId,
                                          friendName:
                                              AlluserRequest[index].senderName!,
                                          userId:
                                              AlluserRequest[index].recevieId!,
                                          id: friend1);
                                      await FirebaseFirestore.instance
                                          .collection("Friends")
                                          .doc(friend1)
                                          .set(model.toMap());

                                      var friend2 = uid.v4();
                                      FriendModel model2 = FriendModel(
                                          friendId:
                                              AlluserRequest[index].recevieId,
                                          friendName: AlluserRequest[index]
                                              .recevieName!,
                                          userId:
                                              AlluserRequest[index].senderId!,
                                          id: friend2);

                                      await FirebaseFirestore.instance
                                          .collection("Friends")
                                          .doc(friend2)
                                          .set(model2.toMap());

                                      await FirebaseFirestore.instance
                                          .collection("Requests")
                                          .doc(AlluserRequest[index].reqId)
                                          .update({"status": "accepted"});

                                      // Remove accepted request from the list
                                      setState(() {
                                        AlluserRequest.removeAt(index);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.check,
                                    )),

                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection("Requests")
                                          .doc(AlluserRequest[index].reqId)
                                          .delete();
                                      setState(() {
                                        AlluserRequest.removeAt(index);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    )),
                                // InkWell(
                                //     onTap: () async {
                                //   var uid = Uuid();
                                //   var friend1 = uid.v4();
                                //   FriendModel model = FriendModel(
                                //       friendId:
                                //           AlluserRequest[index].senderId,
                                //       friendName:
                                //           AlluserRequest[index].senderName!,
                                //       userId:
                                //           AlluserRequest[index].recevieId!,
                                //       id: friend1);
                                //   await FirebaseFirestore.instance
                                //       .collection("Friends")
                                //       .doc(friend1)
                                //       .set(model.toMap());

                                //   var friend2 = uid.v4();
                                //   FriendModel model2 = FriendModel(
                                //       friendId:
                                //           AlluserRequest[index].recevieId,
                                //       friendName: AlluserRequest[index]
                                //           .recevieName!,
                                //       userId:
                                //           AlluserRequest[index].senderId!,
                                //       id: friend2);

                                //   await FirebaseFirestore.instance
                                //       .collection("Friends")
                                //       .doc(friend2)
                                //       .set(model2.toMap());

                                //   await FirebaseFirestore.instance
                                //       .collection("Requests")
                                //       .doc(AlluserRequest[index].reqId)
                                //       .update({"status": "accepted"});

                                //   // Remove accepted request from the list
                                //   setState(() {
                                //     AlluserRequest.removeAt(index);
                                //   });
                                // },
                                //     child: Icon(Icons.check)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
          ),
        ],
      ),
    ));
  }
}
