import 'package:darlink/modules/detail/event_detail_screen.dart';
import 'package:darlink/shared/widgets/card/event_card.dart';
import 'package:flutter/material.dart';
import 'package:darlink/layout/announce_event_page.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:darlink/constants/Database_url.dart' as mg;

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final eventData = await collect_info_Events();
      setState(() {
        events = eventData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: ${e.toString()}')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> collect_info_Events() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("Event");
    var eventdata = await collection.find().toList();
    print('----------------------------------------');
    print(eventdata.toString());

    return eventdata;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode
            ? theme.colorScheme.surface
            : theme.colorScheme.primary.withOpacity(0.2),
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.headlineMedium?.color),
      ),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchEvents,
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 500 + index * 100),
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: {
                          'title': event['Event Name']?.toString() ?? 'No Title',
                          'date': event['date']?.toString() ?? 'No Date',
                          'location': event['location'] != null
                              ? '${event['location']['latitude']}, ${event['location']['longitude']}'
                              : 'No Location',
                          'description': event['description']?.toString() ?? 'No Description',
                          'image': event['image']?.toString() ?? '',
                          'price': event['price']?.toString() ?? 'Free',
                          'celeb': event['celeb']?.toString() ?? '',
                        }),
                      ),
                    );
                  },
                  child: EventCard(
                    title: event['Event Name']?.toString() ?? 'No Title',
                    date: event['date']?.toString() ?? 'No Date',
                    location: event['location'] != null
                        ? '${event['location']['latitude']}, ${event['location']['longitude']}'
                        : 'No Location',
                    imageUrl: event['image']?.toString() ?? '',
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AnnounceEventPage()),
          ).then((_) => _fetchEvents()); // Refresh events after adding a new one
        },
        child: Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}