import 'package:chat_me/model/Model.dart';
import 'package:chat_me/model/RequestModel.dart';
import 'package:chat_me/view/StaticData.dart';
import 'package:chat_me/model/friendmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AllUserData extends StatefulWidget {
  List<FriendModel> allFriends;
  AllUserData({super.key, required this.allFriends});

  @override
  State<AllUserData> createState() => _AllUserDataState();
}

class _AllUserDataState extends State<AllUserData> {
  TextEditingController emailController = TextEditingController();
  PageController controller = PageController();

  List<UserModel> Allusers = [];
  getAlluser() async {
    Allusers.clear();
    List<String> friendIds = [];
    for (var id in widget.allFriends) {
      setState(() {
        friendIds.add(id.friendId!);
      });
    }
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("User")
        .where("name", isNotEqualTo: StaticData.model!.name)
        .get();
    for (var User in snapshot.docs) {
      UserModel model = UserModel.fromMap(User.data() as Map<String, dynamic>);
      if (model.UserId != null && !friendIds.contains(model.UserId)) {
        setState(() {
          Allusers.add(model); // Add the user only if they're not a friend
        });
      }
    }
  }

  @override
  void initState() {
    getAlluser();
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
            child: Center(
              child: Text(StaticData.model!.name!,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(color: Colors.black)),
            ),
          ),
          SizedBox(
            height: height * 0.76,
            width: width,
            child: Allusers.isEmpty
                ? Center(
                    child: Text("User not Found",
                        style: Theme.of(context).textTheme.displaySmall!),
                  )
                : ListView.builder(
                    itemCount: Allusers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                            height: height * 0.07,
                            width: width * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              leading: const CircleAvatar(
                                radius: 20,
                                child: Icon(Icons.person),
                              ),
                              title: Text(
                                Allusers[index].name!,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  var uid = const Uuid();
                                  String reqId = uid.v4();
                                  RequestModel model = RequestModel(
                                      recevieId: Allusers[index].UserId,
                                      recevieName: Allusers[index].name,
                                      senderId: StaticData.model!.UserId,
                                      senderName: StaticData.model!.name,
                                      status: "Pendding",
                                      reqId: reqId);
                                  FirebaseFirestore.instance
                                      .collection("Requests")
                                      .doc(reqId)
                                      .set(model.toMap());
                                },
                                child: const Icon(
                                  Icons.person_add,
                                  color: Colors.black,
                                ),
                              ),
                            )),
                      );
                    },
                  ),
          ),
        ],
      ),
    ));
  }
}
