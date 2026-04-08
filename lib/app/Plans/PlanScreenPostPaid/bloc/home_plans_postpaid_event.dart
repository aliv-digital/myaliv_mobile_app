abstract class HomePlansPostPaidEvent {
  const HomePlansPostPaidEvent();
}

class HomePlansPostPaidStarted extends HomePlansPostPaidEvent {
  const HomePlansPostPaidStarted();
}

class HomePlansPostPaidToggleExpanded extends HomePlansPostPaidEvent {
  final String planId;

  const HomePlansPostPaidToggleExpanded(this.planId);
}

class HomePlansPostPaidApiSyncRequested extends HomePlansPostPaidEvent {
  final bool printRawResponse;

  const HomePlansPostPaidApiSyncRequested({
    this.printRawResponse = false,
  });
}

class HomePlansPostPaidToastConsumed extends HomePlansPostPaidEvent {
  const HomePlansPostPaidToastConsumed();
}
