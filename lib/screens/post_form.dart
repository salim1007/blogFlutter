import 'dart:io';

import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/screens/login.dart';
import 'package:blog/services/post_service.dart';
import 'package:blog/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String? title;

  const PostForm({this.post, this.title});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> postformkey = GlobalKey<FormState>();
  final TextEditingController bodyController = TextEditingController();
  bool _loading = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future getImage() async {
    final pickedfile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedfile != null) {
      setState(() {
        _imageFile = File(pickedfile.path);
      });
    }
  }

  void _createPost() async {
    String? image = _imageFile == null ? null : getStringImage(_imageFile);
    ApiResponse response = await createPost(bodyController.text, image);

    if (response.error == null) {
      Navigator.of(context).pop();
    } else if (response.error == unAuthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Login()), (route) => false));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  void _editPost(postId) async {
    ApiResponse response = await editPost(postId, bodyController.text);

    if (response.error == null) {
      Navigator.of(context).pop();
    } else if (response.error == unAuthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  @override
  void initState() {
    if (widget.post != null) {
      bodyController.text = widget.post!.body?? ''; 
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                widget.post != null
                    ? SizedBox()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: BoxDecoration(
                            image: _imageFile == null
                                ? null
                                : DecorationImage(
                                    image: FileImage(_imageFile ?? File('')),
                                    fit: BoxFit.cover)),
                        child: Center(
                          child: IconButton(
                              onPressed: () {
                                getImage();
                              },
                              icon: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.black38,
                              )),
                        ),
                      ),
                Form(
                    key: postformkey,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: bodyController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 12,
                        validator: (val) =>
                            val!.isEmpty ? 'Post body is required' : null,
                        decoration: InputDecoration(
                          hintText: 'Post body.....',
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black38)),
                        ),
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: KTextButton('Post', () {
                    if (postformkey.currentState!.validate()) { 
                      setState(() {
                        _loading = !_loading;
                      });
                      if (widget.post == null) {
                        _createPost();
                      } else {
                        _editPost(widget.post!.id ?? 0);
                      }
                    }
                  }),
                ),
              ],
            ),
    );
  }
}
