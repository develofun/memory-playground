import 'package:flutter/material.dart';

/// 홈 화면의 게임 타일 정보. 게임이 구현되면 route를 채운다.
class GameInfo {
  const GameInfo({
    required this.id,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.color,
    this.route,
  });

  final String id;
  final String title;
  final String emoji;
  final String subtitle;
  final Color color;
  final String? route;
}

const gameCatalog = [
  GameInfo(
    id: 'digit_backward',
    title: '숫자 거꾸로',
    emoji: '🔢',
    subtitle: '듣고 거꾸로 누르기',
    color: Color(0xFF4F8EF7),
  ),
  GameInfo(
    id: 'market',
    title: '시장에 가면',
    emoji: '🛒',
    subtitle: '순서대로 기억하기',
    color: Color(0xFF3CB878),
  ),
  GameInfo(
    id: 'instruction',
    title: '지시 따르기',
    emoji: '📋',
    subtitle: '잘 듣고 차례로',
    color: Color(0xFFF2994A),
  ),
  GameInfo(
    id: 'english',
    title: '영어 단어',
    emoji: '🔤',
    subtitle: '듣고 그림 고르기',
    color: Color(0xFFB667F1),
  ),
];
