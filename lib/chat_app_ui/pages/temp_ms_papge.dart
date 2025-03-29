// import 'package:chat_app/chat_app_ui/app.dart';
// import 'package:faker/faker.dart';
// import 'package:flutter/material.dart';
// import 'package:jiffy/jiffy.dart';
// import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
// import '../helpers.dart';
// import '../models/models.dart';
// import '../theme.dart';
// import '../widgets/widgets.dart';

// class MessagesPage extends StatefulWidget {
//   const MessagesPage({super.key});

//   @override
//   State<MessagesPage> createState() => _MessagesPageState();
// }

// class _MessagesPageState extends State<MessagesPage> {
//   late final channelListController = StreamChannelListController(
//     client: StreamChatCore.of(context).client,
//     filter: Filter.and([
//       Filter.equal('type', 'messaging'),
//       Filter.in_('members', [StreamChatCore.of(context).currentUser!.id]),
//     ]),
//   );

//   @override
//   void initState() {
//     channelListController.doInitialLoad();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     channelListController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PagedValueListenableBuilder<int, Channel>(
//       valueListenable: channelListController,
//       builder: (context, value, child) {
//         return value.when(
//           (channels, nextPageKey, error) {
//             if (channels.isEmpty) {
//               return const Center(
//                 child: Text(
//                   'Empty messages.\nGo and message someone.',
//                   textAlign: TextAlign.center,
//                 ),
//               );
//             }
//             return LazyLoadScrollView(
//               onEndOfPage: () async {
//                 if (nextPageKey != null) {
//                   channelListController.loadMore(nextPageKey);
//                 }
//               },
//               child: CustomScrollView(
//                 slivers: [
//                   const SliverToBoxAdapter(child: _Stories()),
//                   SliverList(
//                     delegate: SliverChildBuilderDelegate((context, index) {
//                       return _MessengerTitle(channel: channels[index]);
//                     }, childCount: channels.length),
//                   ),
//                 ],
//               ),
//             );
//           },
//           loading:
//               () => const Center(
//                 child: SizedBox(
//                   height: 100,
//                   width: 100,
//                   child: CircularProgressIndicator(color: AppColors.secondary),
//                 ),
//               ),
//           error: (e) => DisplayErrorMessage(error: e),
//         );
//       },
//     );
//   }
// }

// class _MessengerTitle extends StatelessWidget {
//   const _MessengerTitle({required this.channel});

//   final Channel channel;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         // Navigator.of(context).push(ChatScreen.routeWithChannel(channel));
//       },
//       child: Container(
//         height: 100,
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         decoration: const BoxDecoration(
//           border: Border(
//             top: BorderSide(color: Colors.grey, width: 0.2),
//             bottom: BorderSide(color: Colors.grey, width: 0.2),
//           ),
//         ),
//         child: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Avatar.medium(
//                 url: Helpers.getChannelImage(channel, context.currentUser!),
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       Helpers.getChannelName(channel, context.currentUser!),
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         letterSpacing: 0.2,
//                         wordSpacing: 1.5,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: SizedBox(height: 24, child: _buildLastMessage()),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   const SizedBox(height: 4),
//                   _buildLastMessageAt(),
//                   const SizedBox(height: 8),
//                   Center(child: UnreadIndicator(channel: channel)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLastMessage() {
//     return BetterStreamBuilder<int>(
//       stream: channel.state!.unreadCountStream,
//       initialData: channel.state?.unreadCount ?? 0,
//       builder: (context, count) {
//         return BetterStreamBuilder<Message>(
//           stream: channel.state!.lastMessageStream,
//           initialData: channel.state!.lastMessage,
//           builder: (context, lastMessage) {
//             return Text(
//               lastMessage.text ?? '',
//               overflow: TextOverflow.ellipsis,
//               style:
//                   (count > 0)
//                       ? const TextStyle(
//                         fontSize: 12,
//                         color: AppColors.secondary,
//                       )
//                       : const TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textFaded,
//                       ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildLastMessageAt() {
//     return BetterStreamBuilder<DateTime>(
//       stream: channel.lastMessageAtStream,
//       initialData: channel.lastMessageAt,
//       builder: (context, data) {
//         final lastMessageAt = data.toLocal();
//         String stringDate;
//         final now = DateTime.now();
//         final startOfDay = DateTime(now.year, now.month, now.day);

//         if (lastMessageAt.millisecondsSinceEpoch >=
//             startOfDay.millisecondsSinceEpoch) {
//           stringDate = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).jm;
//         } else if (lastMessageAt.millisecondsSinceEpoch >=
//             startOfDay
//                 .subtract(const Duration(days: 1))
//                 .millisecondsSinceEpoch) {
//           stringDate = 'Yesterday';
//         } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
//           stringDate = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).EEEE;
//         } else {
//           stringDate = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).yMd;
//         }
//         return Text(
//           stringDate,
//           style: const TextStyle(
//             fontSize: 11,
//             letterSpacing: -0.2,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textFaded,
//           ),
//         );
//       },
//     );
//   }
// }

// class _Stories extends StatelessWidget {
//   const _Stories();

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       child: SizedBox(
//         height: 146,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
//               child: Text(
//                 'Stories',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontSize: 15,
//                   color: AppColors.textFaded,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (BuildContext context, int index) {
//                   final faker = Faker();
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       width: 60,
//                       child: _StoryCard(
//                         storyData: StoryData(
//                           name: faker.person.name(),
//                           url: Helpers.randomPictureUrl(),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _StoryCard extends StatelessWidget {
//   const _StoryCard({required this.storyData});

//   final StoryData storyData;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Avatar.medium(url: storyData.url),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 16.0),
//             child: Text(
//               storyData.name,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 11,
//                 letterSpacing: 0.3,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
