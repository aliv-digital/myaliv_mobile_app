import 'help_repository.dart';

class HelpRepositoryImpl implements HelpRepository {
  @override
  Future<HelpContent> fetchContent() async {
    // Demo static content (later replace with API)
    return const HelpContent(
      title1: 'Beautiful analytics to grow smarter',
      paragraph1:
      'Powerful, self-serve product and growth analytics to help you convert, engage, and retain more users.',
      paragraph2:
      'Dolor enim eu tortor urna sed duis nulla. Aliquam vestibulum, nulla odio nisl vitae. In aliquet pellentesque aenean hac vestibulum turpis mi bibendum diam. Tempor integer aliquam in vitae malesuada fringilla.',
      title2: 'How we can help',
      paragraph3:
      'Mi tincidunt elit, id quisque ligula ac diam, amet. Vel etiam suspendisse morbi eleifend faucibus eget vestibulum felis. Dictum quis montes, sit sit. Tellus aliquam enim urna, etiam. Mauris posuere vulputate arcu amet, vitae nisi, tellus tincidunt. At feugiat sapien varius id.',
      paragraph4:
      'Eget quis mi enim, leo lacinia pharetra, semper. Eget in volutpat mollis at volutpat lectus velit, sed auctor. Porttitor fames arcu quis fusce augue enim. Quis at habitant diam at. Suscipit tristique risus, at donec. In turpis vel et quam imperdiet. Ipsum molestie aliquet sodales id est ac volutpat.',
    );
  }
}
