import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:scales/util/shared_preferences.dart';

class MedsengerScales {
  static Future<void> sendMesurementData(
      double weight, DateTime time, String otherData) async {
    final agentToken = await Store.getAgentToken();
    if (agentToken == null) {
      log('Agent token not found');
      return;
    }

    final response = await http.post(
      Uri.parse('https://scales.ai.medsenger.ru/new_record'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'agent_token': agentToken,
        'weight': weight.toInt(),
        'timestamp': time.millisecondsSinceEpoch ~/ 1000,
        'other_data': otherData,
      }),
    );
    if (response.statusCode == HttpStatus.created) {
      log('Measurement data sent successfully');
    } else {
      log('Failed to send measurement data: ${response.statusCode}');
    }
  }
}

