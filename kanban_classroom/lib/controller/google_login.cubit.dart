import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';



class GoogleSignInCubit extends Cubit<GoogleSignInAccount?> {
  final GoogleSignIn _googleSignIn;

  GoogleSignInCubit()
      : _googleSignIn = GoogleSignIn(),
        super(null);

  // Sign in with Google
  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      emit(account);
    } catch (error) {
      emit(null);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    emit(null);
  }
}
