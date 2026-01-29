import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kanban_classroom/controller/google_login.cubit.dart';


class GoogleLoginPage extends StatelessWidget {
  const GoogleLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => GoogleSignInCubit(),
        child: BlocBuilder<GoogleSignInCubit, GoogleSignInAccount?>(
          builder: (context, account) {
            if (account != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(account.photoUrl ?? ''), radius: 40,),
                    SizedBox(height: 10),
                    Text('Welcome, ${account.displayName}',style: TextStyle(fontSize: 20),),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GoogleSignInCubit>().signOut();
                      },
                      child: Text('Sign Out'),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<GoogleSignInCubit>().signIn();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/google.png', height: 40,),
                      SizedBox(width: 8),
                      Text('Continue with Google', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400,),),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}