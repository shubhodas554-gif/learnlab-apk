import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  LeaderboardEntry({required this.uid, required this.xp});
  final String uid;
  final int xp;
}

class LeaderboardRepository {
  LeaderboardRepository(this._db);
  final FirebaseFirestore _db;

  Stream<List<LeaderboardEntry>> topUsers({int limit = 20}) {
    return _db
        .collection('leaderboard')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => LeaderboardEntry(uid: d.id, xp: (d.data()['xp'] ?? 0) as int))
            .toList());
  }
}
