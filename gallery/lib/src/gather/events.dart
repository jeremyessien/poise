import 'package:flutter/widgets.dart';

final class GatherEvent {
  const GatherEvent({
    required this.title,
    required this.place,
    required this.time,
    required this.day,
    required this.date,
    required this.spotsLeft,
    required this.tile,
  });

  final String title;
  final String place;
  final String time;
  final String day;
  final String date;
  final int spotsLeft;
  final Color tile;
}

const sampleEvents = [
  GatherEvent(
    title: 'Morning run club',
    place: 'Riverside Park',
    time: '7:00',
    day: 'Thu',
    date: '14',
    spotsLeft: 8,
    tile: Color(0xFFFFE3D3),
  ),
  GatherEvent(
    title: 'Pottery evening',
    place: 'Clay Studio',
    time: '18:30',
    day: 'Fri',
    date: '15',
    spotsLeft: 12,
    tile: Color(0xFFDDEBFF),
  ),
  GatherEvent(
    title: 'Jazz on the roof',
    place: 'The Loft',
    time: '20:00',
    day: 'Sat',
    date: '16',
    spotsLeft: 3,
    tile: Color(0xFFF1E4FF),
  ),
  GatherEvent(
    title: 'Sunday market walk',
    place: 'Old Town',
    time: '10:00',
    day: 'Sun',
    date: '17',
    spotsLeft: 20,
    tile: Color(0xFFE3F5E1),
  ),
];

/// How Gather words the number of spots an event has left.
String spotsLeftLabel(num spots) => '$spots spots left';
