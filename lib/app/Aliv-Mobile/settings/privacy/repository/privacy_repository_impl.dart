import 'privacy_repository.dart';

class PrivacyRepositoryImpl implements PrivacyRepository {
  @override
  Future<PrivacyContent> fetchContent() async {
    // Demo static content (later replace with API)
    return const PrivacyContent(
      title1: 'beautiful analytics to grow smarter',
      paragraph1:
      'powerful, self-serve product and growth analytics to help you convert, engage, and retain more users.',
      paragraph2:
      'dolor enim eu tortor urna sed duis nulla. Aliquam vestibulum, nulla odio nisl vitae. In aliquet pellentesque aenean hac vestibulum turpis mi bibendum diam. Tempor integer aliquam in vitae malesuada fringilla.',
      title2: 'how we can help',
      paragraph3:
      'mi tincidunt elit, id quisque ligula ac diam, amet. Vel etiam suspendisse morbi eleifend faucibus eget vestibulum felis. Dictum quis montes, sit sit. Tellus etiam enim urna, etiam. Mauris posuere vulputate arcu amet, vitae nisi, tellus tincidunt. At feugiat sapien varius id.',
      paragraph4:
      'eget quis mi enim, leo lacinia pharetra, semper. Eget in volutpat mollis at volutpat lectus velit, sed auctor. Porttitor fames arcu quis fusce augue enim. Quis at habitant diam. Suscipit tristique risus, at donec. In turpis vel et quam imperdiet. Ipsum molestie aliquet sodales id est ac volutpat.',
    );
  }
}
