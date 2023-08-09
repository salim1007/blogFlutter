import 'package:blog/screens/login.dart';
import 'package:blog/screens/post_screen.dart';
import 'package:blog/screens/post_form.dart';
import 'package:blog/screens/profile.dart';
import 'package:blog/services/user_service.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog App'),
        actions: [
          IconButton(
              onPressed: () {
                logout().then((value) => Navigator.of(context)
                    .pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false));
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: currIndex == 0 ? PostScreen() : Profile(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => PostForm(
                title: 'Add New Post'
              )));
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        elevation: 30,
        clipBehavior: Clip.antiAlias,
        shape: CircularNotchedRectangle(),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Contacts')
          ],
          currentIndex: currIndex,
          onTap: (val) {
            setState(() {
              currIndex = val;
            });
            
          },
        ),
      ),
    );
  }
}
