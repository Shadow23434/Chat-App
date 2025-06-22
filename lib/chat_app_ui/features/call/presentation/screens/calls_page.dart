import 'dart:math';
import 'package:chat_app/chat_app_ui/features/auth/data/models/user_model.dart';
import 'package:chat_app/chat_app_ui/features/call/data/models/call_model.dart';
import 'package:chat_app/chat_app_ui/utils/helpers.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:faker/faker.dart' as faker;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class CallsPage extends StatelessWidget {
  CallsPage({super.key});

  List<UserModel> users = Helpers.users;
  List<CallModel> _generateSortedCallData() {
    List<CallModel> calls = List.generate(
      20,
      (_) => CallModel(
        id: faker.faker.guid.guid(),
        participantId: users[Random().nextInt(users.length)].id,
        participantName: users[Random().nextInt(users.length)].username,
        participantProfilePic:
            users[Random().nextInt(users.length)].profilePic ??
            'https://via.placeholder.com/150',
        status: faker.faker.randomGenerator.boolean() ? 'missed' : 'received',
        endedAt: Helpers.randomDate(),
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
            sortedCalls
                .map((call) => _CallTitle(call: call, users: users))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CallTitle extends StatelessWidget {
  const _CallTitle({required this.call, required this.users});
  final CallModel call;
  final List<UserModel> users;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap:
            () => Navigator.of(context).push(
              ProfileScreen.route(
                users.firstWhere((user) => user.id == call.participantId),
              ),
            ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Avatar.medium(
                url: call.participantProfilePic,
                onTap:
                    () => Navigator.of(context).push(
                      ProfileScreen.route(
                        users.firstWhere(
                          (user) => user.id == call.participantId,
                        ),
                      ),
                    ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      call.participantName,
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
