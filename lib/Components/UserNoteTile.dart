import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vichaar/Components/readMore.dart';
import 'package:vichaar/Services/apiServices.dart';
import 'package:vichaar/constant.dart';

class UserNoteTile extends StatefulWidget {
  String title;
  String id;
  //Fuction(BuildContext)? onDelete;
  
  UserNoteTile({super.key, required this.title,  required this.id});

  @override
  State<UserNoteTile> createState() => _UserNoteTileState();
}

class _UserNoteTileState extends State<UserNoteTile> {
  final ApiService apiService = ApiService();
  
  @override

  @override
  Widget build(BuildContext context) {
    
    return ListTile(
      tileColor: kGreyColor, 
      trailing: GestureDetector(
        onTap: (){
          setState(() {
            apiService.deleteNote(widget.id);
          });
        },
        child: Icon(Icons.more_vert)),// Background color of the tile
      shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
      ),
      title: Container(
       // height: 100,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ReadMoreText(text: widget.title, maxLines: 6,)
        
        
        
        
      ),
    ),
      ),
    
      
      // elevation: 4, // Elevation of the tile
      // shadowColor: Colors.grey, // Shadow color
    );

  }
}