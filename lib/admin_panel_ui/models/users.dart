import 'package:faker/faker.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String gender;
  final String phoneNumber;
  final String profileUrl;
  final String? status;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password = '12345678',
    required this.gender,
    required this.phoneNumber,
    required this.profileUrl,
    this.status,
  });
}

final List<User> users = [
  User(
    id: faker.guid.guid(),
    name: 'Gordon Amat',
    email: 'gordonamat@gmail.com',
    gender: 'Male',
    phoneNumber: '(320) 555 0104',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Jane Doe',
    email: 'janedoe@example.com',
    gender: 'Female',
    phoneNumber: '(555) 123 4567',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Alex Carter',
    email: 'alex.carter92@yahoo.com',
    gender: 'Male',
    phoneNumber: '(415) 789 1234',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Sofia Lopez',
    email: 'sofialopez@outlook.com',
    gender: 'Female',
    phoneNumber: '(213) 456 7890',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Liam Nguyen',
    email: 'liam.nguyen88@gmail.com',
    gender: 'Unknown',
    phoneNumber: '(702) 234 5678',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Emma Watson',
    email: 'emma.watson@icloud.com',
    gender: 'Female',
    phoneNumber: '(310) 987 6543',

    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'James Patel',
    email: 'jamespatel.work@gmail.com',
    gender: 'Male',
    phoneNumber: '(646) 555 0199',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Olivia Kim',
    email: 'olivia.kim23@hotmail.com',
    gender: 'Unknow',
    phoneNumber: '(858) 321 6547',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Noah Schmidt',
    email: 'noah.schmidt@proton.me',
    gender: 'Male',
    phoneNumber: '(503) 444 7777',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Isabella Rossi',
    email: 'isabella.rossi@gmail.com',
    gender: 'Female',
    phoneNumber: '(718) 999 1122',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Ethan Brooks',
    email: 'ethan.brooks@live.com',
    gender: 'Male',
    phoneNumber: '(206) 888 3344',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Mia Alvarez',
    email: 'mia.alvarez99@yahoo.com',
    gender: 'Female',
    phoneNumber: '(619) 777 2233',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Lucas Hayes',
    email: 'lucashayes@outlook.com',
    gender: 'Male',
    phoneNumber: '(404) 555 9988',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Ava Chen',
    email: 'ava.chen.work@gmail.com',
    gender: 'Female',
    phoneNumber: '(510) 333 4455',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Mason Rivera',
    email: 'mason.rivera@icloud.com',
    gender: 'Male',
    phoneNumber: '(312) 666 7788',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Harper Evans',
    email: 'harper.evans22@hotmail.com',
    gender: 'Female',
    phoneNumber: '(925) 222 3344',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Elijah Khan',
    email: 'elijah.khan@proton.me',
    gender: 'Male',
    phoneNumber: '(303) 444 5566',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Charlotte Wu',
    email: 'charlotte.wu@gmail.com',
    gender: 'Female',
    phoneNumber: '(415) 999 6677',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Benjamin Ortiz',
    email: 'ben.ortiz88@yahoo.com',
    gender: 'Male',
    phoneNumber: '(702) 111 2233',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
  User(
    id: faker.guid.guid(),
    name: 'Amelia Foster',
    email: 'amelia.foster@outlook.com',
    gender: 'Female',
    phoneNumber: '(818) 555 7788',
    profileUrl: 'https://picsum.photos/seed/${random.integer(100)}/300/300',
  ),
];
