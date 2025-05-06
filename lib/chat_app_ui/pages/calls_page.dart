import 'dart:math';
import 'package:chat_app/chat_app_ui/models/models.dart';
import 'package:chat_app/chat_app_ui/utils/helpers.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:faker/faker.dart' as faker;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  List<Call> _generateSortedCallData() {
    List<Call> calls = List.generate(
      20,
      (_) => Call(
        id: faker.faker.guid.guid(),
        caller: users[Random().nextInt(users.length)],
        receiver: users[Random().nextInt(users.length)],
        status: faker.faker.randomGenerator.boolean() ? 'missed' : 'received',
        duration: faker.faker.randomGenerator.integer(60),
        startedAt: DateTime.now().subtract(
          Duration(minutes: faker.faker.randomGenerator.integer(60)),
        ),
        endedAt: Helpers.randomDate(),
        roomId: faker.faker.guid.guid(),
      ),
    );

    calls.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return calls;
  }

  @override
  Widget build(BuildContext context) {
    final sortedCalls = _generateSortedCallData();

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            sortedCalls.map((call) => _CallTitle(call: call)).toList(),
          ),
        ),
      ],
    );
  }
}

class _CallTitle extends StatelessWidget {
  const _CallTitle({required this.call});
  final Call call;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Avatar.medium(
                url: call.caller.profilePic,
                onTap:
                    () => Navigator.of(
                      context,
                    ).push(ProfileScreen.route(call.caller)),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caller name
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      call.caller.username,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        letterSpacing: 0.2,
                        wordSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  // Timeline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        call.status == 'missed'
                            ? Image.asset(
                              'assets/images/missed_call.png',
                              scale: 1.5,
                            )
                            : Image.asset(
                              'assets/images/comming_call.png',
                              scale: 1.5,
                            ),
                        SizedBox(width: 4),
                        Text(
                          Jiffy.parse(call.endedAt.toString()).fromNow(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textFaded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconImage(
                    src: 'assets/images/phone_volume.png',
                    scale: 1.5,
                    onTap: () {},
                  ),
                  SizedBox(width: 4),
                  IconImage(
                    src: 'assets/images/video.png',
                    scale: 1.5,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
