import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn google = GoogleSignIn();
String url = 'https://proctor-m5dv.onrender.com';
//String url = 'http://192.168.28.70:3000';
//String url = 'https://proctor-psi.vercel.app/';
var t = google.isSignedIn();