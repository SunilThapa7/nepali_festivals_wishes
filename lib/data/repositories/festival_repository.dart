import 'package:nepali_festival_wishes/models/festival.dart';
import 'package:uuid/uuid.dart';

// Mock data until we implement proper data storage
class FestivalRepository {
  final List<Festival> _festivals = [];
  final Uuid _uuid = Uuid();

  FestivalRepository() {
    _initializeFestivals();
  }

  void _initializeFestivals() {
    // Religious Festivals
    _festivals.add(
      Festival(
        id: _uuid.v4(),
        name: 'Dashain',
        description:
            'Dashain is the longest and most auspicious festival in the Nepali annual calendar, celebrated by Nepalis of all caste and creed throughout the country. The fifteen days of celebration occur during the bright lunar fortnight ending on the day of the full moon.',
        imageUrl: 'assets/images/dashain.jpg',
        category: FestivalCategory.religious,
        nepaliWishes: [
          'दशैंको हार्दिक मंगलमय शुभकामना!',
          'दशैंले तपाईंको जीवनमा खुशी, समृद्धि र सफलता ल्याओस्। शुभ दशैं!',
          'यस पावन पर्वले तपाईंको जीवनमा नयाँ उमंग र उत्साह ल्याओस्। हार्दिक शुभकामना!',
          'माँ दुर्गाको आशिर्वादले तपाईंको जीवन सधैं खुशी र समृद्धिले भरिपूर्ण रहोस्। शुभ दशैं!',
        ],
        englishWishes: [
          'Happy Dashain! May Goddess Durga bless you with strength and courage.',
          'Wishing you a joyous Dashain celebration with your loved ones!',
          'May this Dashain bring peace, prosperity, and happiness in your life.',
          'Sending you warm wishes on the auspicious occasion of Dashain!',
        ],
        cardImageUrls: [
          'assets/images/dashain_card1.jpg',
          'assets/images/dashain_card2.jpg',
          'assets/images/dashain_card3.jpg',
        ],
        date: DateTime(2023, 10, 15),
      ),
    );

    _festivals.add(
      Festival(
        id: _uuid.v4(),
        name: 'Tihar',
        description:
            'Tihar, also known as Deepawali, is a five-day-long Hindu festival celebrated in Nepal. It is the festival of lights, where people decorate their homes with oil lamps, candles and colorful lights.',
        imageUrl: 'assets/images/tihar.jpg',
        category: FestivalCategory.religious,
        nepaliWishes: [
          'तिहारको हार्दिक शुभकामना!',
          'दीपावलीको उज्यालोले तपाईंको जीवनमा नयाँ आशा र खुशी ल्याओस्। शुभ तिहार!',
          'यस तिहारले तपाईंको घरमा समृद्धि र सौभाग्य ल्याओस्। हार्दिक मंगलमय शुभकामना!',
          'लक्ष्मीको कृपा तपाईं र तपाईंको परिवारमा सधैं बनिरहोस्। शुभ तिहार!',
        ],
        englishWishes: [
          'Happy Tihar! May the festival of lights brighten your life.',
          'Wishing you a Tihar filled with joy, prosperity, and illumination!',
          'May Goddess Lakshmi bless your home with wealth and prosperity this Tihar.',
          'Let the light of diyas spread love and happiness in your life. Happy Tihar!',
        ],
        cardImageUrls: [
          'assets/images/tihar_card1.jpg',
          'assets/images/tihar_card2.jpg',
          'assets/images/tihar_card3.jpg',
        ],
        date: DateTime(2023, 11, 3),
      ),
    );

    // National Festivals
    _festivals.add(
      Festival(
        id: _uuid.v4(),
        name: 'Losar',
        description:
            'Losar is the Tibetan New Year, a significant holiday celebrated by Tibetan Buddhists and some ethnic groups in Nepal, particularly in the mountainous regions.',
        imageUrl: 'assets/images/losar.jpg',
        category: FestivalCategory.national,
        nepaliWishes: [
          'लोसार ताशी देलेक!',
          'नयाँ वर्षको हार्दिक शुभकामना! यो लोसारले तपाईंको जीवनमा खुशी र समृद्धि ल्याओस्।',
          'लोसारको पावन अवसरमा तपाईं र तपाईंको परिवारलाई हार्दिक शुभकामना!',
          'लोसार ताशी देलेक! नयाँ वर्षले नयाँ आशा र उमंग ल्याओस्।',
        ],
        englishWishes: [
          'Losar Tashi Delek! Happy Tibetan New Year!',
          'May this Losar bring joy, peace, and prosperity to your life.',
          'Wishing you and your family a blessed Losar celebration!',
          'Happy Losar! May the new year bring new hopes and aspirations.',
        ],
        cardImageUrls: [
          'assets/images/losar_card1.jpg',
          'assets/images/losar_card2.jpg',
          'assets/images/losar_card3.jpg',
        ],
        date: DateTime(2024, 2, 10),
      ),
    );

    // Cultural Festivals
    _festivals.add(
      Festival(
        id: _uuid.v4(),
        name: 'Holi',
        description:
            'Holi, also known as the festival of colors, is a popular Hindu festival celebrated throughout Nepal. It signifies the victory of good over evil and the arrival of spring.',
        imageUrl: 'assets/images/holi.jpg',
        category: FestivalCategory.cultural,
        nepaliWishes: [
          'रंगीचंगी होलीको हार्दिक शुभकामना!',
          'होलीको रंगले तपाईंको जीवनमा खुशी र उल्लासको रंग भरोस्। शुभ होली!',
          'यस होली पर्वले तपाईंको जीवनमा नयाँ उमंग, उत्साह र रंग ल्याओस्। हार्दिक शुभकामना!',
          'रंगहरूको यो चाडमा तपाईंलाई रंगीन शुभकामना! होली मुबारक!',
        ],
        englishWishes: [
          'Happy Holi! May your life be filled with vibrant colors of joy.',
          'Wishing you a colorful and joyous Holi celebration!',
          'May the colors of Holi spread happiness and love in your life.',
          'Let\'s celebrate the victory of good over evil with colors. Happy Holi!',
        ],
        cardImageUrls: [
          'assets/images/holi_card1.jpg',
          'assets/images/holi_card2.jpg',
          'assets/images/holi_card3.jpg',
        ],
        date: DateTime(2024, 3, 25),
      ),
    );

    // Seasonal Festivals
    _festivals.add(
      Festival(
        id: _uuid.v4(),
        name: 'Maghe Sankranti',
        description:
            'Maghe Sankranti is a Nepalese festival observed on the first day of the month of Magh, marking the end of the winter solstice and the beginning of longer days.',
        imageUrl: 'assets/images/maghe_sankranti.jpg',
        category: FestivalCategory.seasonal,
        nepaliWishes: [
          'माघे संक्रान्तिको हार्दिक शुभकामना!',
          'यस माघे संक्रान्तिको अवसरमा तपाईंलाई स्वास्थ्य, समृद्धि र खुशीको कामना गर्दछु।',
          'माघे संक्रान्तिको यो पावन अवसरमा तपाईंलाई हार्दिक शुभकामना!',
          'माघे संक्रान्तिले तपाईंको जीवनमा नयाँ उमंग र उत्साह ल्याओस्। शुभकामना!',
        ],
        englishWishes: [
          'Happy Maghe Sankranti! May this festival bring warmth and joy to your life.',
          'Wishing you a blessed Maghe Sankranti filled with sweet moments!',
          'May the sun\'s transition bring positive changes in your life. Happy Maghe Sankranti!',
          'Sending warm wishes on Maghe Sankranti! May you be blessed with prosperity and happiness.',
        ],
        cardImageUrls: [
          'assets/images/maghe_sankranti_card1.jpg',
          'assets/images/maghe_sankranti_card2.jpg',
          'assets/images/maghe_sankranti_card3.jpg',
        ],
        date: DateTime(2024, 1, 15),
      ),
    );
  }

  // Get all festivals
  List<Festival> getAllFestivals() {
    return _festivals;
  }

  // Get festival by ID
  Festival? getFestivalById(String id) {
    try {
      return _festivals.firstWhere((festival) => festival.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get festivals by category
  List<Festival> getFestivalsByCategory(FestivalCategory category) {
    return _festivals
        .where((festival) => festival.category == category)
        .toList();
  }

  // Search festivals by name or description
  List<Festival> searchFestivals(String query) {
    final lowercaseQuery = query.toLowerCase();

    return _festivals.where((festival) {
      return festival.name.toLowerCase().contains(lowercaseQuery) ||
          festival.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get upcoming festivals
  List<Festival> getUpcomingFestivals() {
    final now = DateTime.now();

    // Create dates for the next three festivals by using current year
    final nextYear = now.year + 1;

    // Update the dates for existing festivals to be in the future
    final updatedFestivals = _festivals.map((festival) {
      // Make a copy of the festival with an updated date
      DateTime updatedDate;

      // If the festival date for this year has already passed, use next year
      if (DateTime(now.year, festival.date.month, festival.date.day)
          .isBefore(now)) {
        updatedDate =
            DateTime(nextYear, festival.date.month, festival.date.day);
      } else {
        updatedDate =
            DateTime(now.year, festival.date.month, festival.date.day);
      }

      return Festival(
        id: festival.id,
        name: festival.name,
        description: festival.description,
        imageUrl: festival.imageUrl,
        category: festival.category,
        nepaliWishes: festival.nepaliWishes,
        englishWishes: festival.englishWishes,
        cardImageUrls: festival.cardImageUrls,
        date: updatedDate,
      );
    }).toList();

    // Sort by upcoming date
    updatedFestivals.sort((a, b) => a.date.compareTo(b.date));

    // Return the upcoming festivals
    return updatedFestivals
        .where((festival) => festival.date.isAfter(now))
        .toList();
  }
}
