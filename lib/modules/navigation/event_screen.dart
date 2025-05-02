import 'package:darlink/modules/detail/event_detail_screen.dart';
import 'package:darlink/shared/widgets/card/event_card.dart';
import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  final List<Map<String, String>> events = [
    {
      'title': 'Book Fair',
      'date': 'May 15, 2025',
      'location': 'Beirut, Biel',
      'description':
          'Come explore thousands of books from international and local publishers.',
      'image':
          'https://www.globaltimes.cn/Portals/0/attachment/2022/2022-11-13/1bc337f2-f660-4614-b897-58bf1498a6e5.jpeg'
    },
    {
      'title': 'Anything Goes Bel Arabi - Award Winning Broadway Musical',
      'date': 'May 18, 2025',
      'location': 'Casino du Liban',
      'description':
          'Enjoy a spectacular Broadway musical performed entirely in Arabic.',
      'image':
          'https://cdn.ticketingboxoffice.com/uploadImages/ProducersEventsPics/Producers-Events-T-1405-638715148217700146.jpg'
    },
    {
      'title': 'Let us Walk in a Brighter Beirut',
      'date': 'May 26, 2025',
      'location': 'Corniche Ain El Mraisseh',
      'description':
          'Join us for a walk to support a greener and brighter Beirut!',
      'image':
          'https://images-ihjoz-com.s3.amazonaws.com/events/cover/6964/event_cover_WhatsApp_Image_2023-04-27_at_12.18.09_PM.jpg'
    },
    {
      'title': 'معرض الصناعة في لبنان',
      'date': 'May 8-13, 2025',
      'location': 'Beirut, Biel',
      'description': 'اكتشف المنتجات الصناعية اللبنانية من مختلف القطاعات.',
      'image':
          'https://lebanon.shafaqna.com/wp-content/uploads/2023/06/dsc_0306.jpg'
    },
  ];

  EventScreen({super.key});

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
                      builder: (context) => EventDetailPage(event: event),
                    ),
                  );
                },
                child: EventCard(
                  title: event['title']!,
                  date: event['date']!,
                  location: event['location']!,
                  imageUrl: event['image']!,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print('Add Event Button Pressed');
        },
        label: Text(
          'Add Event',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}
