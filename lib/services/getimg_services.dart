import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sfs_editor/constants/strings.dart';
import 'package:http/http.dart' as http;
import 'package:sfs_editor/models/aimodels_model.dart';

class GetIMageServices with ChangeNotifier {
  Uint8List? imageData;
  List<AiModels> allmodels = [];
  Future<void> postEssential(String promptText) async {
    try {
      if(imageData != null){
        imageData = null;
      }
      final response = await http.post(
        Uri.parse(essintialUrl),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "style": "photorealism",
          "prompt": promptText,
          "width": 1024,
          "height": 1024,
          "output_format": "jpeg",
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
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

  Future<void> postTextToText(String promptText,AiModels selectedModel) async {
    try {
      if(imageData != null){
        imageData = null;
      }
      final response = await http.post(
        Uri.parse(
        selectedModel.family == 'stable-diffusion'
          ? stableDiffusionTextToImage
          : selectedModel.family == 'latent-consistency'
            ? latentConsTextToImage
            : stableXItextToimage
      ),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": selectedModel.id,
          "prompt": promptText,
          "width": selectedModel.family == 'stable-diffusion-xl' ? 1024 : 512,
          "height":  selectedModel.family == 'stable-diffusion-xl' ? 1024 : 512,
          "steps": selectedModel.family == 'latent-consistency'? 8 : 25,
          "output_format": "jpeg",
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
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

  Future<void> getAllModels()async{
    try{
      final response = await http.get(Uri.parse(allModels),
      headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
      );
      if(response.statusCode == 200){
        List<dynamic> responseData = jsonDecode(response.body);
        List<AiModels> models = responseData.map((json) => AiModels.fromJson(json)).toList();
        allmodels = models;
        notifyListeners();
      }else{
        log('error in get, StatusCode: ${response.statusCode}');
      }
    }catch(e){
      log('error: $e');
    }
  }

  Future<void> postImagetoImage(AiModels selectedModel,String promptText,String image)async{
    try {
      if(imageData != null){
        imageData = null;
      }
      final response = await http.post(
        Uri.parse(
        selectedModel.family == 'stable-diffusion'
          ? stableDiffusionImageToImage
          : selectedModel.family == 'latent-consistency'
            ? latentConsImageToImage
            : stableXIimageToimage
      ),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": selectedModel.id,
          "prompt": promptText,
          "negative_prompt": "nude women",
          "strength": 0.5,
          "steps": selectedModel.family == 'latent-consistency'? 8 : 50,
          "image" : image,
          "output_format": "jpeg",
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
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