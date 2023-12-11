import 'package:flutter/material.dart';
import 'package:irun/ranking/ranking_provider.dart';
import 'package:provider/provider.dart';

String getTier(int rank, int totalParticipants) {
  double percentile = (rank / totalParticipants) * 100;

  if (percentile <= 10) {
    return '다이아';
  } else if (percentile <= 30) {
    return '골드';
  } else if (percentile <= 60) {
    return '실버';
  } else if (percentile <= 90) {
    return '브론즈';
  } else {
    return '아이언';
  }
}

Color getTierColor(String tier) {
  switch (tier) {
    case '다이아':
      return Colors.blueAccent;
    case '골드':
      return Colors.amber;
    case '실버':
      return Colors.grey;
    case '브론즈':
      return Colors.brown;
    case '아이언':
      return Colors.black26;
    default:
      return Colors.white; // 기본 색상
  }
}

class RankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rankingProvider = Provider.of<RankingProvider>(context, listen: false);
    if (!rankingProvider.isInitialLoadDone) {
      rankingProvider.loadRankingData();
    }
    final viewMyRanking = rankingProvider.viewMyRanking;
    final myRankingIndex = rankingProvider.myRankingIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('시즌 2023', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => rankingProvider.loadRankingData(forceLoad: false),
          ),
        ],
      ),
      body: rankingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: rankingProvider.rankingData.length,
        itemBuilder: (context, index) {
          if (!viewMyRanking ||
              (index >= myRankingIndex - 2 && index <= myRankingIndex + 2)) {
            var user = rankingProvider.rankingData[index];
            bool isCurrentUser = index == myRankingIndex;
            String tier = getTier(index+1, rankingProvider.rankingData.length);
            Color tierColor = getTierColor(tier);

            return Card(
              color: tierColor.withOpacity(0.4),
              shape: isCurrentUser
                  ? RoundedRectangleBorder(
                side: const BorderSide(color: Colors.pink, width: 3),
                borderRadius: BorderRadius.circular(4),
              )
                  : null,
              child: ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text('${index + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    const SizedBox(width: 20),
                    user['photoURL'] != null
                        ? Image.network(user['photoURL'], width: 40, height: 40)
                        : const CircleAvatar(child: Icon(Icons.person)),
                  ],
                ),
                title: Text(user['displayName'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('티어 : $tier / 점수 : ${user['score'].toStringAsFixed(2)}'),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}