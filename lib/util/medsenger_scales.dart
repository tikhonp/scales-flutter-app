import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:scales/util/shared_preferences.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

class MedsengerScales {
  static Future<void> sendMesurementData(
      double weight, MiScaleBodyData? extraData, DateTime time) async {
    final agentToken = await Store.getAgentToken();
    if (agentToken == null) {
      log('Agent token not found');
      return;
    }

    String body;
    if (extraData == null) {
      body = jsonEncode(<String, dynamic>{
        'agent_token': agentToken,
        'timestamp': time.millisecondsSinceEpoch ~/ 1000,
        'weight': weight,
      });
    } else {
      body = jsonEncode(<String, dynamic>{
        'agent_token': agentToken,
        'timestamp': time.millisecondsSinceEpoch ~/ 1000,
        'weight': weight,
        'body_fat_percentage': extraData.bodyFat,
        'bone_mass': extraData.boneMass,
        'muscle_mass': extraData.muscleMass,
        'water_percentage': extraData.water,
        'visceral_fat': extraData.visceralFat,
      });
    }
    final response = await http.post(
      Uri.parse('https://scales.ai.medsenger.ru/new_record'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (response.statusCode == HttpStatus.created) {
      log('Measurement data sent successfully');
    } else {
      log('Failed to send measurement data: ${response.statusCode} ${response.body}');
    }
  }
}

