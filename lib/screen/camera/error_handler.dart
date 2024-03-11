import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

catchError(AsyncSnapshot<bool> snapshot) {
  if (snapshot.hasError) {
    return Center(
      child: Text(
        snapshot.error.toString(),
      ),
    );
  }
  if (!snapshot.hasData)
    return Center(
      child: CircularProgressIndicator(),
    );
}