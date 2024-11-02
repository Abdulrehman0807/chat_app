import 'package:chat_me/view/Alluser.dart';
import 'package:chat_me/view/Reuest.dart';
import 'package:chat_me/view/StaticData.dart';
import 'package:chat_me/view/chat_screen.dart';
import 'package:chat_me/model/friendmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSwitch = false;

  PageController controller = PageController();

  int index = 0;
  List<FriendModel> allFriends = [];
  getAllFriends() async {
    allFriends.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Friends")
        .where("userId", isEqualTo: StaticData.model!.UserId)
        .get();
    for (var User in snapshot.docs) {
      FriendModel model =
          FriendModel.fromMap(User.data() as Map<String, dynamic>);
      setState(() {
        allFriends.add(model);
      });
    }
  }

  @override
  void initState() {
    getAllFriends();
    super.initState();
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  int currentPageIndex = 0;

  void navigateToScreen(int index) {
    setState(() {
      currentPageIndex = index;
    });
    switch (index) {
      case 0:
        controller.jumpToPage(0);
        break;
      case 1:
        controller.jumpToPage(1);
        break;
      case 2:
        controller.jumpToPage(2);
        break;
      case 3:
        // controller.jumpToPage(3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return
        // theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentPageIndex,
              backgroundColor: Colors.blue,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              onTap: navigateToScreen,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 26),
                  activeIcon: Icon(Icons.home, size: 30),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 26),
                  activeIcon: Icon(Icons.person, size: 30),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined, size: 26),
                  activeIcon: Icon(Icons.settings, size: 30),
                  label: 'Setting',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view, size: 26),
                  activeIcon: Icon(Icons.grid_view_sharp, size: 30),
                  label: 'More',
                ),
              ],
              selectedLabelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
              ),
            ),
            body: SizedBox(
              height: height,
              width: width,
              child: Column(
                children: [
                  SizedBox(
                      height: height * 0.9,
                      width: width,
                      child: Stack(
                        children: [
                          PageView(
                              controller: controller,
                              physics: NeverScrollableScrollPhysics(),
                              onPageChanged: (value) {
                                index = value;
                                print(value);
                              },
                              children: [
                                SizedBox(
                                  height: height * 0.9,
                                  width: width,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        height: height * 0.04,
                                      ),
                                      Container(
                                          height: height * 0.10,
                                          width: width,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: height * 0.08,
                                                width: width * 0.45,
                                                decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          "images/under1.png")),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  // toggleTheme(!isSwitch);
                                                },
                                                child: const Icon(
                                                  Icons.dark_mode,
                                                  size: 30,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const RequestPage(),
                                                      ));
                                                },
                                                child: const Icon(
                                                  Icons.person_add,
                                                  size: 30,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.more_vert,
                                                size: 30,
                                              )
                                            ],
                                          )),
                                      SizedBox(
                                        height: height * 0.76,
                                        width: width,
                                        child: ListView.builder(
                                          itemCount: allFriends.length,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                String id = chatRoomId(
                                                    StaticData.model!.UserId!,
                                                    allFriends[index]
                                                        .friendId!);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatScreen(
                                                              chatroomId: id,
                                                              userModel:
                                                                  allFriends[
                                                                      index]),
                                                    ));
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                elevation: 1,
                                                child: Container(
                                                  height: height * 0.07,
                                                  width: width * 0.8,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: ListTile(
                                                    leading: const CircleAvatar(
                                                      radius: 25,
                                                      child: Icon(Icons.person),
                                                    ),
                                                    title: Text(
                                                        allFriends[index]
                                                            .friendName!),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AllUserData(allFriends: allFriends),
                                Scaffold(
                                  body: SizedBox(
                                    height: height * 0.9,
                                    width: width,
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: height * 0.45,
                                          width: width,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              image: const DecorationImage(
                                                  image: AssetImage(
                                                      "images/main.png"))),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            height: height * 0.52,
                                            width: width,
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(30),
                                                    topRight:
                                                        Radius.circular(30))),
                                            child: Column(children: [
                                              SizedBox(
                                                height: height * 0.02,
                                              ),
                                              SizedBox(
                                                height: height * 0.06,
                                                width: width * 0.9,
                                                child: Center(
                                                  child: Text(
                                                    "Profile",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: height * 0.03,
                                              ),
                                              SizedBox(
                                                height: height * 0.03,
                                                width: width * 0.95,
                                                child: Text(
                                                  "Name",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge,
                                                ),
                                              ),
                                              ListTile(
                                                leading: Text(
                                                  StaticData.model!.name!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge!
                                                      .copyWith(
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 87, 83, 83),
                                                      ),
                                                ),
                                              ),
                                              const Divider(
                                                thickness: 1,
                                              ),
                                              SizedBox(
                                                height: height * 0.03,
                                                width: width * 0.95,
                                                child: Text("Email",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayLarge!),
                                              ),
                                              ListTile(
                                                leading: Text(
                                                  StaticData.model!.email!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge!
                                                      .copyWith(
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 87, 83, 83),
                                                      ),
                                                ),
                                              ),
                                              const Divider(
                                                thickness: 1,
                                              ),
                                              SizedBox(
                                                height: height * 0.03,
                                                width: width * 0.95,
                                                child: Text("Password",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayLarge!),
                                              ),
                                              ListTile(
                                                leading: Text(
                                                  "Change Password",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge!
                                                      .copyWith(
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 87, 83, 83),
                                                      ),
                                                ),
                                                trailing: GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          actions: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                            ),
                                                            const Text(
                                                              "Confirm",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20),
                                                            ),
                                                          ],
                                                          content: SizedBox(
                                                              height: 230,
                                                              width: 250,
                                                              child: Column(
                                                                children: [
                                                                  const Text(
                                                                    "Change Password",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.03,
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.05,
                                                                    width:
                                                                        width *
                                                                            0.85,
                                                                    child:
                                                                        const TextField(
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        prefixIcon:
                                                                            Icon(Icons.password),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            "Old Password",
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.03,
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.05,
                                                                    width:
                                                                        width *
                                                                            0.85,
                                                                    child:
                                                                        const TextField(
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        prefixIcon:
                                                                            Icon(Icons.password),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            "New Password",
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.03,
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.05,
                                                                    width:
                                                                        width *
                                                                            0.85,
                                                                    child:
                                                                        const TextField(
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        prefixIcon:
                                                                            Icon(Icons.password),
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            "Confrim Password ",
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: const Icon(
                                                    Icons.edit,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                          // Positioned(
                          //   bottom: 0,
                          //   child: Container(
                          //     height: height * 0.085,
                          //     width: width,
                          //     decoration: BoxDecoration(
                          //         color: Theme.of(context).colorScheme.background,
                          //         borderRadius: const BorderRadius.only(
                          //             topLeft: Radius.circular(25),
                          //             topRight: Radius.circular(25))),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //       children: [
                          //         InkWell(
                          //           onTap: () {
                          //             controller.jumpToPage(0);
                          //           },
                          //           child: const Icon(
                          //             Icons.home,
                          //             size: 35,
                          //           ),
                          //         ),
                          //         InkWell(
                          //           onTap: () {
                          //             controller.jumpToPage(1);
                          //           },
                          //           child: const Icon(
                          //             Icons.request_page,
                          //             size: 35,
                          //           ),
                          //         ),
                          //         InkWell(
                          //           onTap: () {
                          // controller.jumpToPage(2);
                          //           },
                          //           child: const Icon(
                          //             Icons.settings,
                          //             size: 35,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // )
                        ],
                      ))
                ],
              ),
            ));
  }
}
