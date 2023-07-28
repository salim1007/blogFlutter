import 'dart:io';

import 'package:blog/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostForm extends StatefulWidget {
  const PostForm({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Post'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    image: _imageFile == null ? null :DecorationImage(
                      image: FileImage(_imageFile?? File('')),
                      fit: BoxFit.cover
                      )
                  ),
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
                    }
                  }),
                ),
              ],
            ),
    );
  }
}
