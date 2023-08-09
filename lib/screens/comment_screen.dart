import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/models/comment.dart';
import 'package:blog/services/comment_service.dart';
import 'package:blog/services/user_service.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class CommentScreen extends StatefulWidget {
  final int? postId;

  const CommentScreen({this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<dynamic> _commentList = [];
  bool _loading = true;
  int? userId = 0;
  int _editCommentId = 0;
  TextEditingController _commentController = TextEditingController();

  //get all comments of a single post......
  Future<void> _getComments() async {
    userId = await getUserId();
    ApiResponse response = await getComments(widget.postId ?? 0);

    if (response.error == null) {
      setState(() {
        _commentList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
      });
    } else if (response.error == unAuthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _createComment() async {
    ApiResponse response =
        await createComment(widget.postId ?? 0, _commentController.text);

    if (response.error == null) {
      _commentController.clear();
      _getComments();
    } else if (response.error == unAuthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _deleteComment(commentId) async {
    ApiResponse response = await deleteComment(commentId);

    if (response.error == null) {
      _getComments();
    } else if (response.error == unAuthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _editComment() async {
    ApiResponse response =
        await editComment(_commentController.text, _editCommentId);
    if (response.error == null) {  
      _editCommentId = 0;
      _commentController.clear();
      _getComments();
    } else if (response.error == unAuthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  @override
  void initState() {
    _getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () {
                      return _getComments();
                    },
                    child: ListView.builder(
                        itemCount: _commentList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Comment comment = _commentList[index];
                          return Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black26, width: 0.5))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              image: comment.user!.image != null
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                          '${comment.user!.image}'),
                                                      fit: BoxFit.cover)
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.blueGrey),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${comment.user!.name}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                    comment.user!.id == userId
                                        ? PopupMenuButton(
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: Icon(
                                                  Icons.more_vert,
                                                  color: Colors.black,
                                                )),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                child: Text('Edit'),
                                                value: 'edit',
                                              ),
                                              PopupMenuItem(
                                                child: Text('Delete'),
                                                value: 'delete',
                                              ),
                                            ],
                                            onSelected: (val) {
                                              if (val == 'edit') {
                                                setState(() {
                                                  _editCommentId = comment.id ?? 0;
                                                  _commentController.text =
                                                      comment.comment ?? '';
                                                });
                                              } else {
                                                _deleteComment(comment.id ?? 0);
                                              }
                                            },
                                          )
                                        : SizedBox()
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('${comment.comment}')
                              ],
                            ),
                          );
                        }),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.black26, width: 0.5))),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        decoration: KinputDecoration('Comment'),
                        controller: _commentController,
                      )),
                      IconButton(
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              setState(() {
                                _loading = true;
                              });
                              if (_editCommentId > 0) {
                                _editComment();
                              }else{
                                 _createComment();
                              }
                              
                            }
                          },
                          icon: Icon(Icons.send))
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
