// services/api_service.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/commentModel.dart';
import '../Model/noteModel.dart';
import '../Model/userModel.dart';
import '../Model/userNoteModel.dart';



class ApiService {
  static const String baseUrl = 
  //'https://vichaar.onrender.com'
  //'http://localhost:8000'
  //'http://10.0.2.2:8000'
  'http://172.20.10.3:8000'

  ;

  
  String? token;

  Future<String> getToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('user_token');

    return token ?? '';
  }

 //--------------------N O T E S--------------------

  Future<List<Note>> getNotes() async {
    print("notes api calling");
    token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/notes/'),
      headers: {'Authorization': 'bearer $token'},
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("user token sent to backend: $token");
      return data.map((note) => Note.fromJson(note)).toList();
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Note>> getFollowingNotes() async {
    print("notes api calling");
    token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/notes/followingnotes'),
      headers: {'Authorization': 'bearer $token'},
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("user token sent to backend: $token");
      return data.map((note) => Note.fromJson(note)).toList();
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<UserNote>> getUserNotes() async {

    token = await getToken();


    final response = await http.get(
      Uri.parse('$baseUrl/notes/user'),
      headers: {'Authorization': 'bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<UserNote> notes =
          data.map((json) => UserNote.fromJson(json)).toList();
      return notes;
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<List<Note>> getSpecificUserNotes(String id) async {
    print("sending user id $id");

    token = await getToken();


    final response = await http.get(
      Uri.parse('$baseUrl/notes/user/$id'),
      headers: {'Authorization': 'bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Note> notes =
          data.map((note) => Note.fromJson(note)).toList();
      return notes;
    } else {
      throw Exception('Failed to get notes');
    }
  }

  Future<bool> saveNote(String noteTitle, List skills, XFile? photo) async {

    token = await getToken();
    try{

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/notes/'));

    request.headers['Authorization'] = 'bearer $token';
    request.headers['Content-Type'] = 'application/json';
    

    request.fields.addAll({
      'title': noteTitle,
      'requiredSkills': jsonEncode(skills),
    });

    if (photo != null) {
      var stream = new http.ByteStream(photo!.openRead());
      stream.cast();

      var length = await photo!.length();
      final imageFile = await http.MultipartFile('photo', stream, length);
      request.files.add(imageFile);
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      var responseBody = await response.stream.bytesToString();
      print('Request successful: $responseBody');
      return true;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Exception occurred: $e');
    return false;
  }
}
  

  Future<bool> deleteNote(String id) async {

    token = await getToken();


    try {
      final response = await http.delete(Uri.parse('$baseUrl/notes/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer $token'
          });
      print(response.body);
      return true;
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }


  Future<bool> updateNote(String noteId, String newTitle) async {
    token = await getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notes/$noteId'),
        headers: {
      'Content-Type': 'application/json',
      'Authorization': 'bearer $token'
    },
        body: jsonEncode({
      'title': newTitle,
    }),
      );

      if (response.statusCode == 200) {
        // Update was successful
        print('Note Updated Successfully!');
        return true;
      } else {
        // Update failed
        print('Failed to update note: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Exception occurred during the update
      print('Error updating note: $e');
      return false;
    }
  }


  Future<List<User>> searchUsers(String query) async {
    final String apiUrl = '$baseUrl/users/search/$query';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<User> users = data.map((json) => User.fromJson(json)).toList();
      return users;
    } else {
      // Handle API error
      throw Exception(
          'Failed to search users. Status code: ${response.statusCode}');
    }
  }


  Future<List<dynamic>> fetchTrendingSkills() async {
  final response = await http.get(Uri.parse('$baseUrl/notes/skills/trending'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load trending skills');
  }
}

Future<List<Note>> fetchTrendingNotes() async {
  final response = await http.get(Uri.parse('$baseUrl/notes/trending'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
      print("user token sent to backend: $data");
      return data.map((note) => Note.fromJson(note)).toList();
  } else {
    throw Exception('Failed to load trending notes');
  }
}

Future<List<dynamic>> fetchNotesForSpecificSkill(String skill) async {
  final response = await http.get(Uri.parse('$baseUrl/notes/skill/$skill'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load notes for skill');
  }
}


//--------------------L I K E S--------------------

  Future<void> likeNote(String noteId) async {
    token = await getToken();
    print('note id: $noteId');
    print('token : $token');
    final String apiUrl = '$baseUrl/notes/like/$noteId';

    
    final response = await http.put(Uri.parse(apiUrl),
    headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer $token'
          });

    if (response.statusCode == 200) {
      // Like request successful
      print('Note liked successfully');
      print(response.body);
    } else {
      // Handle error
      print('Failed to like note. Status code: ${response.statusCode}');
    }
  }
  Future<void> unlikeNote(String noteId) async {
    token = await getToken();
    print('note id: $noteId');
    print('token : $token');
    final String apiUrl = '$baseUrl/notes/unlike/$noteId';

    
    final response = await http.put(Uri.parse(apiUrl),
    headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer $token'
          });

    if (response.statusCode == 200) {
      // Like request successful
      print('Note Unliked successfully');
      print(response.body);
    } else {
      // Handle error
      print('Failed to Unlike note. Status code: ${response.statusCode}');
    }
  }


  //--------------------C O M M E N T S--------------------



  Future<List<Comment>> getComments(String noteId) async {
    print("note Id:"+ noteId);

    token = await getToken();

    print("token:"+ token!);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes/comment/$noteId'),
        headers: {'Authorization': 'bearer $token'},
        // Include any necessary headers or authentication tokens
      );

      if (response.statusCode == 200) {
        print(response.body);

        final List<dynamic> data = json.decode(response.body);
        //List<Comment> comments = data.map((comment) => Comment.fromJson(comment)).toList();
        return data.map((comment) => Comment.fromJson(comment)).toList();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<bool> postComment(String text, String noteId) async {

    token = await getToken();


    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes/comment/$noteId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token'
        },
        body: jsonEncode({'text': text}),
      );

      return response.statusCode == 200;
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }




  //--------------------S E A R C H--------------------


  Future<List<String>> getSkills(String id) async {
  final String apiUrl = '$baseUrl/users/userdata/$id';

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    // Like request successful
    print('Data fetched successfully');

    // Assuming 'following' field contains a list of user IDs
    List<String> skillsList = List<String>.from(responseData[0]['skills']);
    return skillsList;
  } else {
    print("error occured getting skills");
    return [];
  }
}
  

  Future<String> SearchedUserData(String id, String key) async{
    final String apiUrl = '$baseUrl/users/userdata/$id';

    final response = await http.get(Uri.parse(apiUrl),
    headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer $token'
          }
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      print('Data fetched Successfully');
      print(responseData[0][key]);

      return(responseData[0][key] ?? '');
    } else {
      // Handle error
      return('Failed, Status code: ${response.statusCode}');
    }
  }

  //--------------------F O L L O W--------------------

  Future<List<dynamic>> getFollowing(String id) async {
  final String apiUrl = '$baseUrl/users/userdata/$id';

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    // Like request successful
    print('Data fetched successfully');

    // Assuming 'following' field contains a list of user IDs
    List<dynamic> followingList = List<dynamic>.from(responseData[0]['following']);
    return followingList;
  } else {
    // Handle error
    return [];
  }
}



  Future<List<dynamic>> getFollowers(String id) async{
    final String apiUrl = '$baseUrl/users/userdata/$id';

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    // Like request successful
    print('followers fetched successfully');

    // Assuming 'following' field contains a list of user IDs
    List<dynamic> followerList = List<dynamic>.from(responseData[0]['followers']);

    print(followerList);
    return followerList;
  } else {
    // Handle error
    return [];
  }

}

Future<void> followUser(String userId) async {
    token = await getToken();
    print('note id: $userId');
    print('token : $token');
    final String apiUrl = '$baseUrl/users/follow/$userId';

    
    final response = await http.post(Uri.parse(apiUrl),
    headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer $token'
          });

    if (response.statusCode == 200) {
      // Like request successful
      print('followed successfully');
      print(response.body);
    } else {
      // Handle error
      print('Failed to  follow. Status code: ${response.statusCode}');
    }
  }

  Future<void> unFollowUser(String userId) async {
    token = await getToken();
    print('note id: $userId');
    print('token : $token');
    final String apiUrl = '$baseUrl/users/unfollow/$userId';

    
    final response = await http.post(Uri.parse(apiUrl),
    headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer $token'
          });

    if (response.statusCode == 200) {
      // Like request successful
      print('unfollowed successfully');
      print(response.body);
    } else {
      // Handle error
      print('Failed to  unfollow. Status code: ${response.statusCode}');
    }
  }
}
