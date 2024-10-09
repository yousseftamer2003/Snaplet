import 'dart:developer';

import 'package:sfs_editor/constants/strings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> analyzeImage(String base64Image) async {
  const apiUrl = 'https://vision.googleapis.com/v1/images:annotate?key=$googleCloudApiKey';

  final body = {
    'requests': [
      {
        'image': {
          'content': base64Image,
        },
        'features': [
          {
            'type': 'SAFE_SEARCH_DETECTION',
          },
        ],
      },
    ],
  };

  final response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    final labels = data['responses'][0]['safeSearchAnnotation'];
    return labels;
  } else {
    throw Exception('Failed to analyze image: ${response.statusCode}');
  }
}

Future<bool> isInappropriateImage(String base64Image) async {
  final labels = await analyzeImage(base64Image);

  if (labels['adult'] == 'VERY_LIKELY' ||
      labels['spoof'] == 'VERY_LIKELY' ||
      labels['medical'] == 'VERY_LIKELY' ||
      labels['violence'] == 'VERY_LIKELY' ||
      labels['racy'] == 'VERY_LIKELY' ||
      labels['adult'] == 'LIKELY' ||
      labels['spoof'] == 'LIKELY' || 
      labels['adult'] == 'UNLIKELY' ||
      labels['adult'] == 'POSSIBLE' ||
      labels['racy'] == 'POSSIBLE' ||
      labels['racy'] == 'LIKELY' ||
      labels['racy'] == 'UNLIKELY'
      ) {
        log('label: $labels');
    return true;
  }
  log('label: $labels');
  return false;
}
