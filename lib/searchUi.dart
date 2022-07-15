import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:socialize/postView.dart';
import 'package:socialize/resources/colors.dart';
import 'package:socialize/resources/myWidgets.dart';

import 'resources/user_details.dart';

class SearchUi extends StatefulWidget {
  const SearchUi({Key? key}) : super(key: key);

  @override
  _SearchUiState createState() => _SearchUiState();
}

class _SearchUiState extends State<SearchUi> {
  final searchController = TextEditingController();
  bool isShowUsers = false;
  bool _searchBoxShow = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: isDarkMode ? Colors.grey.shade900 : Colors.transparent,
        systemNavigationBarColor:
            isDarkMode ? Colors.grey.shade900 : Colors.white,
      ),
    );

    searchController.text == '' ? isShowUsers = false : true;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 75,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'lib/assets/image/search_filled.svg',
                color: primaryColor,
                height: 17,
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: TextFormField(
                  controller: searchController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isShowUsers = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: isShowUsers
          ? Padding(
              padding: EdgeInsets.all(5),
              child: FutureBuilder<dynamic>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('uid', isNotEqualTo: UserDetails.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length == 0) {
                      return Text(
                        'No User',
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        try {
                          if (ds['username'].toString().toLowerCase().contains(
                              searchController.text.trim().toLowerCase())) {
                            return UserTile(ds);
                          }
                        } catch (e) {
                          print(e);
                          return Container();
                        }
                        return Container();
                      },
                    );
                  }
                  return CustomProgressIndicator();
                },
              ),
            )
          : Padding(
              padding: EdgeInsets.all(5),
              child: FutureBuilder<dynamic>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .where('postType', isEqualTo: 'image')
                    .get(),
                builder: (context, snapshot) {
                  try {
                    return StaggeredGridView.countBuilder(
                      physics: BouncingScrollPhysics(),
                      crossAxisCount: 3,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        try {
                          DocumentSnapshot ds = snapshot.data.docs[index];
                          return ds['postImage'] == ''
                              ? Container()
                              : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (ctx) => PostView(
                                                  snap: ds,
                                                )));
                                  },
                                  child: Hero(
                                    tag: ds['postImage'],
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: ds['postImage'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                        } catch (e) {
                          print(e.toString());
                          return CustomProgressIndicator();
                        }
                      },
                      staggeredTileBuilder: (index) => StaggeredTile.count(
                        (index % 7 == 0) ? 2 : 1,
                        (index % 7 == 0) ? 2 : 1,
                      ),
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                    );
                  } catch (e) {
                    print(e.toString());
                    return CustomProgressIndicator();
                  }
                },
              ),
            ),
    );
  }

  Widget UserTile(DocumentSnapshot<Object?> ds) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              image: DecorationImage(
                image: NetworkImage(
                  ds['profilePhoto'],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          CircleAvatar(
            radius: 7,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 5,
              backgroundColor: ds['active'] == '1' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      title: Text(
        ds['username'],
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        ds['email'],
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: primaryColor,
        ),
      ),
    );
  }
}
