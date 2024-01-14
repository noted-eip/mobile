import 'package:flutter/material.dart';

const String kBaseUrl = "https://noted-rojasdiego.koyeb.app";

const String kGoogleUrl =
    "https://accounts.google.com/o/oauth2/v2/auth?client_id=871625340195-kf7c2u88u9aivgdru776a36hgel0kjja.apps.googleusercontent.com&redirect_uri=$kUriDirect&scope=$kScope&response_type=code&access_type=offline";

const String kUriDirect =
    "https://notes-are-noted.vercel.app/authenticate/google";
const String kScope =
    "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile";
// "https://www.googleapis.com/auth/userinfo.email"
// "https://www.googleapis.com/auth/userinfo.profile"
const Color kPrimaryColor = Color.fromARGB(255, 39, 4, 66);
