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
    required this.about,
  });

  final String title;
  final String place;
  final String time;
  final String day;
  final String date;
  final int spotsLeft;
  final Color tile;
  final String about;
}

const sampleEvents = [
  GatherEvent(
    title: 'Morning run club',
    about:
        'An easy 5k along the river, at a pace where talking is still possible. Coffee after for anyone who wants it.',
    place: 'Riverside Park',
    time: '7:00',
    day: 'Thu',
    date: '14',
    spotsLeft: 8,
    tile: Color(0xFFFFE3D3),
  ),
  GatherEvent(
    title: 'Pottery evening',
    about:
        "Two hours at the wheel with a potter who'll show you the basics. Everything you make is fired and ready a week later.",
    place: 'Clay Studio',
    time: '18:30',
    day: 'Fri',
    date: '15',
    spotsLeft: 12,
    tile: Color(0xFFDDEBFF),
  ),
  GatherEvent(
    title: 'Jazz on the roof',
    about:
        'A trio playing standards as the sun goes down. Bring a jacket; it gets cool up there.',
    place: 'The Loft',
    time: '20:00',
    day: 'Sat',
    date: '16',
    spotsLeft: 3,
    tile: Color(0xFFF1E4FF),
  ),
  GatherEvent(
    title: 'Sunday market walk',
    about:
        'A slow wander through the old town market, stopping for whatever smells good.',
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
