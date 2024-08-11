import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Model/noteModel.dart';
import 'package:vichaar/Services/apiServices.dart';

import '../Model/userModel.dart';
import '../Model/userNoteModel.dart';

class PreFetchProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  List<Note> _notesForYou = [];
  List<Note> _notesFollowing = [];
  List<Note> _trendingNotes = [];
  List<UserNote> _loggedUserNotes = [];
  bool _isLoading = false;

  List<Note> get notesForYou => _notesForYou;
  List<Note> get notesFollowing => _notesFollowing;
  List<Note> get trendingNotes => _trendingNotes;
  List<UserNote> get loggedUserNotes => _loggedUserNotes;

  bool get isLoading => _isLoading;

  Future<void> fetchNotes() async {
    print("/////////entered fetchnotes function//////");
    _isLoading = true;
    notifyListeners();

    try {
      _notesForYou = await apiService.getNotes();
      _loggedUserNotes = await apiService.getUserNotes();
      _notesFollowing = await apiService.getFollowingNotes();
      _trendingNotes = await apiService.fetchTrendingNotes();
    } catch (error) {
      print(error);
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
