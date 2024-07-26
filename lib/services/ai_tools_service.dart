import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sfs_editor/constants/strings.dart';
import 'package:http/http.dart' as http;
import 'package:sfs_editor/models/aimodels_model.dart';

class AiToolsProvider with ChangeNotifier {
  Uint8List? imageData;
  Future<void> upScale(String promptText,String image) async{
    try {
      if(imageData != null){
        imageData = null;
      }
      final response = await http.post(
        Uri.parse(enhansUpScale),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "real-esrgan-4x",
          "scale" : 4,
          "image" : image,
          "output_format": "jpeg",
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log('$responseData');
        String base64Image = responseData['image'];
          imageData = base64Decode(base64Image);
          notifyListeners();
      } else {
        log('error in post, StatusCode: ${response.statusCode}');
        log('error message: ${response.body}');
      }
    } catch (e) {
      log('error: $e');
    }
  }

  Future<void> fixFace(String promptText,String image) async{
    try {
      if(imageData != null){
        imageData = null;
      }
      final response = await http.post(
        Uri.parse(enhansFixFaces),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gfpgan-v1-3",
          "scale" : 4,
          "image" : image,
          "output_format": "jpeg",
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log('$responseData');
        String base64Image = responseData['image'];
          imageData = base64Decode(base64Image);
          notifyListeners();
      } else {
        log('error in post, StatusCode: ${response.statusCode}');
      }
    } catch (e) {
      log('error: $e');
    }
  }

  Future<void> inpainting(AiModels selectedModel,String promptText,String image,String maskedImage)async{
    try {
      if(imageData != null){
        imageData = null;
      }
      final response = await http.post(
        Uri.parse(inpaintUrl),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": 'stable-diffusion-v1-5-inpainting',
          "prompt": promptText,
          "width": 512,
          "height": 512,
          "steps": 25,
          "image" : image,
          "mask_image": maskedImage,
          "output_format": "jpeg",
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log('$responseData');
        String base64Image = responseData['image'];
          imageData = base64Decode(base64Image);
          notifyListeners();
      } else {
        log('error in post, StatusCode: ${response.statusCode}');
      }
    } catch (e) {
      log('error: $e');
    }
  }

  Future<void> instruct(String promptText,String image,)async{
    try {
      if(imageData != null){
        imageData = null;
      }
      final response = await http.post(
        Uri.parse(instructUrl),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": 'instruct-pix2pix',
          "prompt": promptText,
          "width": 1024,
          "height": 1024,
          "steps": 25,
          "image" : image,
          "output_format": "jpeg",
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log('$responseData');
        String base64Image = responseData['image'];
          imageData = base64Decode(base64Image);
          notifyListeners();
      } else {
        log('error in post, StatusCode: ${response.statusCode}');
      }
    } catch (e) {
      log('error: $e');
    }
  }
}